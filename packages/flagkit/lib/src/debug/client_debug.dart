import 'dart:async';

import 'package:flagkit/src/cache/cache_policy.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/debug/flagkit_debug.dart';
import 'package:flagkit/src/evaluation/targeting.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/feature_flag.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_explanation.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/flagkit_stats.dart';
import 'package:flagkit/src/model/refresh_record.dart';
import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:flagkit/src/storage/refresh_mapper.dart';
import 'package:flagkit/src/util/start_with.dart';
import 'package:flutter/foundation.dart';

/// [FlagKitDebug] over a running client: the stats from one watched query
/// of the database plus the client's live state (online, refreshing, the
/// reads counted), the rest from the client's memory.
@internal
final class ClientDebug implements FlagKitDebug {
  ClientDebug(this._client);

  final FlagKitClientImpl _client;

  @override
  Stream<FlagKitStats> watchStats() {
    late final StreamController<FlagKitStats> out;
    final subscriptions = <StreamSubscription<Object?>>[];
    Map<String, Object?>? row;
    FlagKitStats? last;
    // One stats build at a time, in order: the last refresh is a lookup.
    var building = Future<void>.value();

    void emit() {
      final latest = row;
      if (latest == null) return;
      building = building.then((_) async {
        final stats = await _stats(latest);
        // A tick that changed nothing the stats show is no new event.
        if (stats == last || out.isClosed) return;
        out.add(last = stats);
      });
    }

    out = StreamController<FlagKitStats>(
      onListen: () {
        subscriptions
          ..add(
            _client.database.watchStatsRow().listen((value) {
              row = value.data;
              emit();
            }, onError: out.addError),
          )
          ..add(_client.ticks.listen((_) => emit()))
          ..add(_client.monitor.watch().skip(1).listen((_) => emit()));
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        await building;
        await out.close();
      },
    );
    return out.stream;
  }

  Future<FlagKitStats> _stats(Map<String, Object?> row) async {
    int count(String column) => int.tryParse('${row[column] ?? ''}') ?? 0;
    final fetchedAt = DateTime.tryParse('${row['fetched_at'] ?? ''}')?.toUtc();
    final lastId = row['last_refresh'] as int?;
    final config = _client.config;
    return FlagKitStats(
      cacheStatus: cacheStatusOf(
        fetchedAt: fetchedAt,
        now: _client.now().toUtc(),
        refreshInterval: config.refreshInterval,
        cacheExpiration: config.cacheExpiration,
      ),
      flagCount: count('flag_count'),
      anonymousId: '${row['anonymous_id'] ?? ''}',
      fetchedAt: fetchedAt,
      configVersion: int.tryParse('${row['config_version'] ?? ''}'),
      lastRefresh: lastId == null
          ? null
          : (await _client.database.refreshDao.byId(lastId))?.toRecord(),
      overrideCount: count('override_count'),
      online: _client.monitor.isOnline,
      refreshing: _client.refreshing,
      evaluations: Map.unmodifiable(_client.evaluations),
      refreshCount: count('refresh_total'),
      failedRefreshCount: count('refresh_failed_total'),
      skippedCount: count('skipped_total'),
    );
  }

  @override
  Stream<List<RefreshRecord>> watchRefreshes({int limit = 10}) => _client
      .database
      .refreshDao
      .watchNewest(limit: limit)
      .map((rows) => [for (final row in rows) row.toRecord()]);

  @override
  Stream<List<FlagDetail>> watchFlags() =>
      startWith(_all, _client.ticks.map((_) => _all())).distinct(listEquals);

  List<FlagDetail> _all() => [
    for (final key in _client.knownKeys.toList()..sort())
      _client.evaluateFor(key, _client.context),
  ];

  @override
  List<FeatureFlag> get definitions => [
    for (final definition
        in _client.repository.snapshot.flags.values.toList()
          ..sort((a, b) => a.key.compareTo(b.key)))
      definition.toFeatureFlag(),
  ];

  @override
  FlagDetail evaluateFor(String key, EvaluationContext context) =>
      _client.evaluateFor(key, context);

  @override
  FlagExplanation explain(String key, {EvaluationContext? context}) {
    final asking = context ?? _client.context;
    final definition = _client.repository.snapshot.flags[key];
    return FlagExplanation(
      detail: _client.evaluateFor(key, asking),
      context: asking,
      flag: definition?.toFeatureFlag(),
      overrideValue: _client.repository.overrides[key],
      rules: [
        for (final rule in definition?.rules ?? const <TargetingRule>[])
          RuleMatch(rule, matched: matchesRule(rule, asking)),
      ],
    );
  }

  @override
  Future<void> setOverride(String key, FlagValue value) =>
      _client.setOverride(key, value);

  @override
  Future<void> clearOverride(String key) => _client.clearOverride(key);

  @override
  Future<void> clearOverrides() => _client.clearOverrides();
}

/// A definition as the public view of it.
@internal
extension FeatureFlagView on FlagDefinition {
  FeatureFlag toFeatureFlag() => FeatureFlag(
    key: key,
    value: value,
    offValue: offValue,
    enabled: enabled,
    updatedAt: updatedAt,
    rolloutPercent: switch (rolloutBasisPoints) {
      final basisPoints? => basisPoints / 100,
      null => null,
    },
    rules: rules,
  );
}
