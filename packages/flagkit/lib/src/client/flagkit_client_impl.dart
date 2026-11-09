import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flagkit/src/cache/cache_policy.dart';
import 'package:flagkit/src/client/flagkit_client.dart';
import 'package:flagkit/src/config/flagkit_config.dart';
import 'package:flagkit/src/connectivity/network_monitor.dart';
import 'package:flagkit/src/debug/flagkit_debug.dart';
import 'package:flagkit/src/evaluation/flag_evaluator.dart';
import 'package:flagkit/src/evaluation/typed_reads.dart';
import 'package:flagkit/src/model/cache_status.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/evaluation_reason.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/refresh_record.dart';
import 'package:flagkit/src/model/refresh_result.dart';
import 'package:flagkit/src/network/fake_remote_config_server.dart';
import 'package:flagkit/src/refresh/refresh_manager.dart';
import 'package:flagkit/src/repository/flag_repository.dart';
import 'package:flagkit/src/repository/flag_snapshot.dart';
import 'package:flagkit/src/scheduling/app_lifecycle.dart';
import 'package:flagkit/src/scheduling/refresh_scheduler.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// How a first start names its install: a random UUID. Tests replace it
/// (`FlagKitTesting.useAnonymousId`) to put a rollout's user in a known
/// bucket.
@internal
String Function() newAnonymousId = randomAnonymousId;

/// A random UUID (v4): the default [newAnonymousId].
@internal
String randomAnonymousId() => const Uuid().v4();

/// The client behind the interface: it loads the cached definitions once,
/// at start, answers every read from them in memory, and refreshes them
/// from the server when they're no longer fresh.
@internal
final class FlagKitClientImpl with TypedReads implements FlagKitClient {
  FlagKitClientImpl._({
    required this.config,
    required this.logger,
    required this.database,
    required this.repository,
    required this.debug,
    required this.refreshes,
    required this._monitor,
    required this._ownsMonitor,
    required this._lifecycle,
    required this._clock,
  });

  /// Opens a client for [config] (already validated): its database, its
  /// anonymous id and the cached definitions; then starts its refreshes.
  ///
  /// [database], [logger], [clock], [newId] and [lifecycle] are for tests;
  /// by default the database is the file on the device, the time is now,
  /// ids are UUID v4s and the lifecycle is Flutter's.
  static Future<FlagKitClientImpl> open(
    FlagKitConfig config, {
    FlagKitDatabase? database,
    FlagKitLogger? logger,
    Clock? clock,
    String Function()? newId,
    AppLifecycle? lifecycle,
  }) async {
    final log = logger ?? FlagKitLogger(enabled: config.debugMode);
    final ids = newId ?? newAnonymousId;
    final time = clock ?? const Clock();

    Future<FlagKitClientImpl> start(FlagKitDatabase database) async {
      final repository = await FlagRepository.open(
        database,
        logger: log,
        newId: ids,
      );
      final ownsMonitor = config.networkMonitor == null;
      final monitor = config.networkMonitor ?? ConnectivityNetworkMonitor();
      if (monitor is ConnectivityNetworkMonitor && ownsMonitor) {
        // Not awaited: until the plugin answers, the monitor says online,
        // and `initialize` never waits on a platform channel.
        unawaited(monitor.start());
      }
      return FlagKitClientImpl._(
        config: config,
        logger: log,
        database: database,
        repository: repository,
        debug: DatabaseDebug(database, config, clock: time),
        refreshes: RefreshManager(
          database: database,
          repository: repository,
          transport: config.transport ?? FakeRemoteConfigServer(),
          monitor: monitor,
          apiKey: config.apiKey,
          logger: log,
          clock: time,
        ),
        monitor: monitor,
        ownsMonitor: ownsMonitor,
        lifecycle: lifecycle ?? createAppLifecycle(log.warning),
        clock: time,
      );
    }

    final onDisk = database ?? openFlagKitDatabase();
    FlagKitClientImpl client;
    try {
      client = await start(onDisk);
    } on Object catch (error, stackTrace) {
      // The file can't be opened (no space, a corrupt file). Failing
      // `initialize` would take the host down with it; instead, this
      // session runs on a database in memory: the callers' defaults until
      // a refresh, and nothing kept when the app quits.
      log.error(
        'opening the flag cache failed: this session keeps its flags in '
        'memory',
        error,
        stackTrace,
      );
      try {
        await onDisk.close();
      } on Object {
        // Already broken; nothing more to release.
      }
      client = await start(FlagKitDatabase.inMemory());
    }
    await client._startRefreshing();
    return client;
  }

  final FlagKitConfig config;
  final FlagKitLogger logger;
  final FlagKitDatabase database;
  final FlagRepository repository;
  final RefreshManager refreshes;
  final NetworkMonitor _monitor;
  final bool _ownsMonitor;
  final AppLifecycle _lifecycle;
  final Clock _clock;
  late final RefreshScheduler _scheduler = RefreshScheduler(
    refresh: _refresh,
    status: () => cacheStatus,
    untilStale: () => switch (repository.snapshot.fetchedAt) {
      final fetchedAt? =>
        fetchedAt.add(config.refreshInterval).difference(_clock.now().toUtc()),
      null => Duration.zero,
    },
    monitor: _monitor,
    lifecycle: _lifecycle,
    interval: config.refreshInterval,
    paused: () => refreshes.pausedByRejectedKey,
    logger: logger,
  );

  @override
  final FlagKitDebug debug;

  EvaluationContext _context = const EvaluationContext();
  final _changes = StreamController<Set<String>>.broadcast();
  bool _closed = false;

  // A screen reads its flags on every build: one log line per unknown key
  // (or wrong-typed read) per session, not one per frame.
  final _reportedUnknown = <String>{};
  final _reportedMismatch = <String>{};

  @override
  FlagDetail evaluate(String key, FlagType? requested) {
    if (_closed) {
      return FlagDetail.fallback(key, EvaluationReason.notInitialized);
    }
    final detail = _evaluate(repository.snapshot, key, requested);
    if (detail.reason == EvaluationReason.flagNotFound &&
        _reportedUnknown.add(key)) {
      logger.debug('"$key" is not a known flag: the caller\'s default');
    }
    if (detail.reason == EvaluationReason.typeMismatch &&
        _reportedMismatch.add(key)) {
      logger.warning(
        '"$key" is a ${repository.snapshot.flags[key]?.type.wireName} flag, '
        'read as ${requested?.wireName}: the caller\'s default',
      );
    }
    return detail;
  }

  FlagDetail _evaluate(
    FlagSnapshot snapshot,
    String key,
    FlagType? requested, {
    EvaluationContext? context,
  }) {
    final asking = context ?? _context;
    return evaluateFlag(
      key: key,
      definition: snapshot.flags[key],
      source: snapshot.source,
      requested: requested,
      context: asking,
      unit: _unitOf(asking),
    );
  }

  /// Who a rollout buckets: the signed-in user, so they keep their answer
  /// on every device; else this install, so a guest keeps theirs across
  /// launches.
  String _unitOf(EvaluationContext context) =>
      context.userId ?? repository.anonymousId;

  /// Runs [change], then tells [changes] which flags now evaluate to
  /// another value: not which definitions changed, which may change
  /// nothing a read returns.
  Future<void> _changing(Future<FlagSnapshot> Function() change) async {
    final before = repository.snapshot;
    final after = await change();
    final changed = {
      for (final key in {...before.flags.keys, ...after.flags.keys})
        if (_valueOf(before, key) != _valueOf(after, key)) key,
    };
    if (changed.isNotEmpty && !_changes.isClosed) _changes.add(changed);
  }

  FlagValue? _valueOf(
    FlagSnapshot snapshot,
    String key, [
    EvaluationContext? context,
  ]) => _evaluate(snapshot, key, null, context: context).value;

  @override
  EvaluationContext get context => _context;

  @override
  void setContext(EvaluationContext context) {
    if (_closed) {
      logger.warning('setContext() after shutdown: ignored');
      return;
    }
    if (context == _context) return;
    final before = _context;
    _context = context;
    logger.debug('context: $context');
    // Every flag re-evaluates for the new context: signing in moves a user
    // to their own bucket, a new country may match other rules.
    final snapshot = repository.snapshot;
    final changed = {
      for (final key in snapshot.flags.keys)
        if (_valueOf(snapshot, key, before) != _valueOf(snapshot, key)) key,
    };
    if (changed.isNotEmpty && !_changes.isClosed) _changes.add(changed);
  }

  @override
  Stream<Set<String>> get changes => _changes.stream;

  /// How fresh the cached flags are now.
  CacheStatus get cacheStatus => cacheStatusOf(
    fetchedAt: repository.snapshot.fetchedAt,
    now: _clock.now().toUtc(),
    refreshInterval: config.refreshInterval,
    cacheExpiration: config.cacheExpiration,
  );

  /// The startup refresh, then the scheduler.
  ///
  /// A cache that isn't fresh is refreshed at once. With nothing cached at
  /// all (a first launch), `initialize` waits for that refresh, up to
  /// `startupWait`, so the first screen can show real values instead of
  /// defaults; with any cache it never waits: the cached flags are already
  /// better than defaults, and the refresh lands when it lands.
  Future<void> _startRefreshing() async {
    _scheduler.start();
    if (cacheStatus == CacheStatus.fresh) return;
    final refreshing = _refresh(RefreshTrigger.startup);
    if (cacheStatus != CacheStatus.empty ||
        config.startupWait <= Duration.zero) {
      unawaited(refreshing);
      return;
    }
    // Whichever comes first: the refresh, or the end of the wait. The
    // timer is cancelled when the refresh wins, so none is left pending.
    final done = Completer<void>();
    final timer = Timer(config.startupWait, () {
      if (!done.isCompleted) {
        logger.debug('startup: no flags after ${config.startupWait}, going on');
        done.complete();
      }
    });
    unawaited(
      refreshing.whenComplete(() {
        timer.cancel();
        if (!done.isCompleted) done.complete();
      }),
    );
    await done.future;
  }

  Future<RefreshResult>? _refreshing;

  /// One refresh at a time, reporting the values it changed once, however
  /// many triggers (and `refresh()` calls) joined it.
  Future<RefreshResult> _refresh(RefreshTrigger trigger) =>
      _refreshing ??= _refreshAndReport(trigger)
          .whenComplete(() => _refreshing = null);

  Future<RefreshResult> _refreshAndReport(RefreshTrigger trigger) async {
    late RefreshResult result;
    await _changing(() async {
      result = await refreshes.refresh(trigger);
      return repository.snapshot;
    });
    return result;
  }

  @override
  Future<RefreshResult> refresh() async {
    if (_closed) return const NotInitialized();
    return _refresh(RefreshTrigger.manual);
  }

  @override
  Future<void> clearCache() async {
    if (_closed) {
      logger.warning('clearCache() after shutdown: ignored');
      return;
    }
    try {
      await _changing(repository.clear);
    } on Object catch (error, stackTrace) {
      // The cache stays as it was, in memory and on disk.
      logger.error('clearing the cache failed', error, stackTrace);
    }
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    await _scheduler.stop();
    _lifecycle.dispose();
    // A refresh in flight finishes first: its transaction mustn't meet a
    // closed database.
    await refreshes.close();
    if (_ownsMonitor && _monitor is ConnectivityNetworkMonitor) {
      await _monitor.dispose();
    }
    await _changes.close();
    await database.close();
    logger.debug('shut down');
  }
}
