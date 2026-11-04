import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flagkit/src/client/flagkit_client.dart';
import 'package:flagkit/src/config/flagkit_config.dart';
import 'package:flagkit/src/debug/flagkit_debug.dart';
import 'package:flagkit/src/evaluation/flag_evaluator.dart';
import 'package:flagkit/src/evaluation/typed_reads.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/evaluation_reason.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/refresh_result.dart';
import 'package:flagkit/src/repository/flag_repository.dart';
import 'package:flagkit/src/repository/flag_snapshot.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// The client behind the interface: it loads the cached definitions once,
/// at start, and answers every read from them, in memory.
///
/// It knows no server yet (0.3.0): the cache is filled by a refresh, so on
/// a device it stays empty until then, and reads return the callers'
/// defaults.
@internal
final class FlagKitClientImpl with TypedReads implements FlagKitClient {
  FlagKitClientImpl._({
    required this.config,
    required this.logger,
    required this.database,
    required this.repository,
    required this.debug,
  });

  /// Opens a client for [config] (already validated): its database, its
  /// anonymous id and the cached definitions.
  ///
  /// [database], [logger], [clock] and [newId] are for tests; by default
  /// the database is the file on the device, the time is now and ids are
  /// UUID v4s.
  static Future<FlagKitClientImpl> open(
    FlagKitConfig config, {
    FlagKitDatabase? database,
    FlagKitLogger? logger,
    Clock? clock,
    String Function()? newId,
  }) async {
    final log = logger ?? FlagKitLogger(enabled: config.debugMode);
    final ids = newId ?? const Uuid().v4;

    Future<FlagKitClientImpl> start(FlagKitDatabase database) async =>
        FlagKitClientImpl._(
          config: config,
          logger: log,
          database: database,
          repository: await FlagRepository.open(
            database,
            logger: log,
            newId: ids,
          ),
          debug: DatabaseDebug(database, config, clock: clock),
        );

    final onDisk = database ?? openFlagKitDatabase();
    try {
      return await start(onDisk);
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
      return start(FlagKitDatabase.inMemory());
    }
  }

  final FlagKitConfig config;
  final FlagKitLogger logger;
  final FlagKitDatabase database;
  final FlagRepository repository;

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
    FlagType? requested,
  ) => evaluateFlag(
    key: key,
    definition: snapshot.flags[key],
    source: snapshot.source,
    requested: requested,
  );

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

  FlagValue? _valueOf(FlagSnapshot snapshot, String key) =>
      _evaluate(snapshot, key, null).value;

  @override
  EvaluationContext get context => _context;

  @override
  void setContext(EvaluationContext context) {
    if (_closed) {
      logger.warning('setContext() after shutdown: ignored');
      return;
    }
    if (context == _context) return;
    _context = context;
    logger.debug('context: $context');
    // Every flag re-evaluates for the new context. No step looks at the
    // context yet (targeting is 0.4.0), so no value changes.
  }

  @override
  Stream<Set<String>> get changes => _changes.stream;

  @override
  Future<RefreshResult> refresh() async {
    if (_closed) return const NotInitialized();
    logger.debug('refresh(): no remote config in this version (0.3.0)');
    return const Failed(reason: 'no remote config in this version');
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
    await _changes.close();
    await database.close();
    logger.debug('shut down');
  }
}
