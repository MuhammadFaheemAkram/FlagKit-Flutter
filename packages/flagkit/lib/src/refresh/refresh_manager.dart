import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flagkit/src/connectivity/network_monitor.dart';
import 'package:flagkit/src/model/refresh_record.dart';
import 'package:flagkit/src/model/refresh_result.dart';
import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:flagkit/src/network/remote_config_transport.dart';
import 'package:flagkit/src/refresh/config_parser.dart';
import 'package:flagkit/src/repository/flag_repository.dart';
import 'package:flagkit/src/repository/flag_snapshot.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flagkit/src/util/start_with.dart';
import 'package:flagkit/src/version.dart';
import 'package:meta/meta.dart';

/// Fetches the flags' definitions and puts them in the cache.
///
/// One refresh at a time: a [refresh] while one runs joins it. A refresh:
/// 1. offline (the monitor says so): nothing is attempted;
/// 2. asks the server, sending the cached config version, so an unchanged
///    config comes back as "not modified" with no body;
/// 3. validates what came (a malformed payload changes nothing; an invalid
///    flag is skipped, the rest apply);
/// 4. replaces the cache in one transaction, then the snapshot reads see;
/// 5. logs the run.
///
/// A failure of any kind leaves the cache and the snapshot as they were:
/// reads go on with the last known flags. A rejected key also pauses the
/// automatic refreshes ([pausedByRejectedKey]) until the next start.
@internal
final class RefreshManager {
  RefreshManager({
    required this._database,
    required this._repository,
    required this._transport,
    required this._monitor,
    required this.apiKey,
    required this._logger,
    Clock? clock,
  }) : _clock = clock ?? const Clock();

  final FlagKitDatabase _database;
  final FlagRepository _repository;
  final RemoteConfigTransport _transport;
  final NetworkMonitor _monitor;
  final String apiKey;
  final FlagKitLogger _logger;
  final Clock _clock;

  Future<RefreshResult>? _running;
  bool _keyRejected = false;
  final _refreshingChanges = StreamController<bool>.broadcast();

  /// Whether a refresh is running.
  bool get isRefreshing => _running != null;

  /// Whether the server rejected the API key: automatic refreshes stop
  /// until the next `initialize` (a new client), since every one would be
  /// rejected the same way. An explicit `refresh()` still tries.
  bool get pausedByRejectedKey => _keyRejected;

  /// Whether a refresh is running: now, then each start and end.
  Stream<bool> watchRefreshing() =>
      startWith(() => isRefreshing, _refreshingChanges.stream);

  /// Runs a refresh for [trigger], or joins the one already running.
  Future<RefreshResult> refresh(RefreshTrigger trigger) {
    if (_running case final running?) return running;
    _refreshingChanges.add(true);
    return _running = _run(trigger).whenComplete(() {
      _running = null;
      _refreshingChanges.add(false);
    });
  }

  /// Completes once no refresh is running, then stops reporting.
  Future<void> close() async {
    await _running;
    await _refreshingChanges.close();
  }

  DateTime _now() => _clock.now().toUtc();

  Future<RefreshResult> _run(RefreshTrigger trigger) async {
    final startedAt = _now();
    if (!_monitor.isOnline) {
      _logger.debug('${trigger.name} refresh: offline, nothing attempted');
      // An automatic trigger offline isn't worth a line in the log (the
      // scheduler doesn't even ask while offline); a refresh the app asked
      // for is.
      if (trigger == RefreshTrigger.manual) {
        await _log(trigger, startedAt, RefreshOutcome.offline);
      }
      return const Offline();
    }
    final before = _repository.snapshot;
    final FetchResponse response;
    try {
      response = await _transport.fetch(
        FetchRequest(
          apiKey: apiKey,
          sdkVersion: flagKitVersion,
          ifVersion: before.configVersion,
        ),
      );
    } on TransportException catch (error) {
      return _failed(trigger, startedAt, error);
    } on Object catch (error, stackTrace) {
      // A transport that broke its contract (threw something else): as if
      // the server were unreachable. The cache stays.
      _logger.error('the transport failed', error, stackTrace);
      return _fail(trigger, startedAt, 'transport error: $error');
    }

    try {
      switch (response) {
        case ConfigNotModified():
          await _repository.markFetched(_now());
          _logger.debug('${trigger.name} refresh: not modified');
          await _log(
            trigger,
            startedAt,
            RefreshOutcome.notModified,
            configVersion: before.configVersion,
          );
          return const NotModified();
        case FetchedConfig(:final json):
          return await _apply(trigger, startedAt, before, json);
      }
    } on Object catch (error, stackTrace) {
      // The database failed: nothing was swapped in, the cache stays.
      _logger.error('storing the config failed', error, stackTrace);
      return _fail(trigger, startedAt, 'storage error: $error');
    }
  }

  Future<RefreshResult> _apply(
    RefreshTrigger trigger,
    DateTime startedAt,
    FlagSnapshot before,
    Map<String, Object?> json,
  ) async {
    final ParsedConfig config;
    try {
      config = parseConfig(json, fetchedAt: _now());
    } on FormatException catch (error) {
      _logger.warning('the server sent a malformed config: ${error.message}');
      return _fail(trigger, startedAt, 'malformed config: ${error.message}');
    }
    for (final reason in config.skipped) {
      _logger.warning('skipped a definition: $reason');
    }
    // A newer server's operator: kept, so the flag still applies its kill
    // switch and other rules, but the rule never matches (fail closed).
    for (final flag in config.flags) {
      for (final rule in flag.rules) {
        if (rule.operator == TargetingOperator.unknown) {
          _logger.warning(
            '"${flag.key}": unknown operator "${rule.operatorName}" '
            'never matches',
          );
        }
      }
    }

    final old = before.flags;
    final added = {
      for (final flag in config.flags)
        if (!old.containsKey(flag.key)) flag.key,
    };
    final changed = {
      for (final flag in config.flags)
        if (old[flag.key] case final previous? when !previous.sameAs(flag))
          flag.key,
    };
    final kept = {for (final flag in config.flags) flag.key};
    final removed = {
      for (final key in old.keys)
        if (!kept.contains(key)) key,
    };

    await _repository.replace(
      definitions: config.flags,
      configVersion: config.version,
      fetchedAt: _now(),
    );
    _logger.debug(
      '${trigger.name} refresh: version ${config.version}, '
      '${added.length} new, ${changed.length} changed, ${removed.length} '
      'removed, ${config.skipped.length} skipped',
    );
    await _log(
      trigger,
      startedAt,
      RefreshOutcome.updated,
      added: added.length,
      changed: changed.length,
      removed: removed.length,
      skipped: config.skipped.length,
      configVersion: config.version,
    );
    return Updated(
      added: added,
      changed: changed,
      removed: removed,
      skipped: config.skipped.length,
    );
  }

  Future<RefreshResult> _failed(
    RefreshTrigger trigger,
    DateTime startedAt,
    TransportException error,
  ) async {
    switch (error) {
      case ApiKeyRejected():
        _keyRejected = true;
        _logger.warning(
          'the server rejected the API key: automatic refreshes pause until '
          'the next initialize()',
        );
        await _log(
          trigger,
          startedAt,
          RefreshOutcome.unauthorized,
          error: error.message,
        );
        return const Unauthorized();
      case ServerUnreachable() || ServerFailure():
        _logger.warning('${trigger.name} refresh failed: ${error.message}');
        return _fail(trigger, startedAt, error.message);
    }
  }

  Future<RefreshResult> _fail(
    RefreshTrigger trigger,
    DateTime startedAt,
    String reason,
  ) async {
    await _log(trigger, startedAt, RefreshOutcome.failed, error: reason);
    return Failed(reason: reason);
  }

  Future<void> _log(
    RefreshTrigger trigger,
    DateTime startedAt,
    RefreshOutcome outcome, {
    int added = 0,
    int changed = 0,
    int removed = 0,
    int skipped = 0,
    int? configVersion,
    String? error,
  }) async {
    try {
      await _database.refreshDao.add(
        RefreshesCompanion.insert(
          trigger: trigger.name,
          startedAt: startedAt,
          finishedAt: _now(),
          outcome: outcome.name,
          added: Value(added),
          changed: Value(changed),
          removed: Value(removed),
          skipped: Value(skipped),
          configVersion: Value(configVersion),
          error: Value(error),
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.error('logging the refresh failed', error, stackTrace);
    }
  }
}
