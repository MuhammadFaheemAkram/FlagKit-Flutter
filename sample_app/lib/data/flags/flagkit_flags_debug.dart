import 'dart:convert';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/data/flags/flag_reading_mapper.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:injectable/injectable.dart';

/// [FlagsDebug] with FlagKit's debug tools (`FlagKit.debug`): the readings,
/// the cache, the log, overrides and "try a user", in the app's words.
@LazySingleton(as: FlagsDebug)
class FlagKitFlagsDebug implements FlagsDebug {
  FlagKitFlagsDebug(this._flags);

  final FlagKitClient _flags;

  FlagKitDebug get _debug => _flags.debug;

  @override
  String get sdkVersion => FlagKit.version;

  /// The app's flags first, in the Dashboard's order, then any other flag
  /// the server sends.
  List<String> get _keys => [
    ...AppFlagKeys.all,
    for (final flag in _debug.definitions)
      if (!AppFlagKeys.all.contains(flag.key)) flag.key,
  ];

  @override
  List<FlagReading> readAll() => [
    for (final key in _keys) readingOf(_flags.detail(key)),
  ];

  // Every evaluation input (not only value changes): a new bucket or
  // reason shows too.
  @override
  Stream<void> watch() => _debug.watchFlags().map((_) {});

  @override
  Stream<CacheInfo> watchCache() => _debug.watchStats().map(
    (stats) => CacheInfo(
      state: switch (stats.cacheStatus) {
        CacheStatus.fresh => CacheState.fresh,
        CacheStatus.stale => CacheState.stale,
        CacheStatus.expired => CacheState.expired,
        CacheStatus.empty => CacheState.empty,
      },
      flagCount: stats.flagCount,
      installId: stats.anonymousId,
      fetchedAt: stats.fetchedAt,
      lastRefresh: switch (stats.lastRefresh) {
        final record? => _lastRefresh(record),
        null => null,
      },
      configVersion: stats.configVersion,
      overrideCount: stats.overrideCount,
      refreshing: stats.refreshing,
      reads: {
        for (final MapEntry(:key, :value) in stats.evaluations.entries)
          sourceOf(key): value,
      },
      refreshes: stats.refreshCount,
      failedRefreshes: stats.failedRefreshCount,
      skippedDefinitions: stats.skippedCount,
    ),
  );

  @override
  Stream<List<LastRefresh>> watchRefreshLog() => _debug.watchRefreshes().map(
    (records) => [for (final record in records) _lastRefresh(record)],
  );

  static LastRefresh _lastRefresh(RefreshRecord record) => LastRefresh(
    cause: switch (record.trigger) {
      RefreshTrigger.startup => RefreshCause.startup,
      RefreshTrigger.interval => RefreshCause.interval,
      RefreshTrigger.resumed => RefreshCause.resumed,
      RefreshTrigger.reconnect => RefreshCause.reconnect,
      RefreshTrigger.manual => RefreshCause.manual,
    },
    kind: switch (record.outcome) {
      RefreshOutcome.updated => RefreshKind.updated,
      RefreshOutcome.notModified => RefreshKind.upToDate,
      RefreshOutcome.offline => RefreshKind.offline,
      RefreshOutcome.failed => RefreshKind.failed,
      RefreshOutcome.unauthorized => RefreshKind.rejected,
    },
    at: record.finishedAt,
    error: record.error,
  );

  @override
  Future<RefreshSummary> refresh() async => switch (await _flags.refresh()) {
    Updated(:final added, :final changed, :final removed, :final skipped) =>
      RefreshSummary(
        RefreshKind.updated,
        changed: added.length + changed.length + removed.length,
        skipped: skipped,
      ),
    NotModified() => const RefreshSummary(RefreshKind.upToDate),
    Offline() => const RefreshSummary(RefreshKind.offline),
    Failed(:final reason) => RefreshSummary(RefreshKind.failed, reason: reason),
    Unauthorized() => const RefreshSummary(RefreshKind.rejected),
    NotInitialized() => const RefreshSummary(
      RefreshKind.failed,
      reason: 'FlagKit isn\'t running',
    ),
  };

  @override
  Future<void> clearCache() => _flags.clearCache();

  @override
  FlagInspection? inspect(String key) {
    final explanation = _debug.explain(key);
    final flag = explanation.flag;
    final overrideValue = explanation.overrideValue;
    if (flag == null && overrideValue == null) return null;
    final reading = readingOf(explanation.detail);
    return FlagInspection(
      reading: FlagReading(
        key: reading.key,
        value: reading.value,
        source: reading.source,
        reason: reading.reason,
        bucket: reading.bucket,
        rolloutPercent: flag?.rolloutPercent,
        kind: kindOf(flag?.type ?? overrideValue?.type),
      ),
      serverValue: flag?.value.toString(),
      offValue: flag?.offValue.toString(),
      enabled: flag?.enabled,
      rules: [
        for (final match in explanation.rules)
          RuleCheck(ruleWords(match.rule), matched: match.matched),
      ],
      overrideValue: overrideValue?.toString(),
    );
  }

  @override
  List<FlagReading> readFor(String userId) {
    final now = _flags.context;
    final user = EvaluationContext(
      userId: userId.trim(),
      country: now.country,
      appVersion: now.appVersion,
      attributes: now.attributes,
    );
    return [for (final key in _keys) readingOf(_debug.evaluateFor(key, user))];
  }

  @override
  Future<String?> setOverride(String key, String text) async {
    final explanation = _debug.explain(key);
    final type = explanation.flag?.type ?? explanation.overrideValue?.type;
    if (type == null) return 'FlagKit doesn\'t know this flag\'s type.';
    final value = parseOverride(type, text);
    if (value == null) return _expected(type);
    try {
      await _debug.setOverride(key, value);
      return null;
    } on ArgumentError catch (error) {
      return '${error.message}.';
    }
  }

  @override
  Future<void> clearOverride(String key) => _debug.clearOverride(key);

  @override
  Future<void> clearOverrides() => _debug.clearOverrides();

  static String _expected(FlagType type) => switch (type) {
    FlagType.boolean => 'Use true or false.',
    FlagType.string => 'Enter some text.',
    FlagType.integer => 'Enter a whole number.',
    FlagType.decimal => 'Enter a number.',
    FlagType.json => 'Enter a JSON object, like {"banner": "Sale"}.',
  };
}

/// [text] as a value of [type], or `null` if it isn't one. A string may be
/// typed with or without quotes (the Dashboard shows them).
FlagValue? parseOverride(FlagType type, String text) {
  final trimmed = text.trim();
  switch (type) {
    case FlagType.boolean:
      return switch (trimmed.toLowerCase()) {
        'true' || 'on' => const BoolValue(true),
        'false' || 'off' => const BoolValue(false),
        _ => null,
      };
    case FlagType.string:
      final unquoted =
          trimmed.length >= 2 &&
              trimmed.startsWith('"') &&
              trimmed.endsWith('"')
          ? trimmed.substring(1, trimmed.length - 1)
          : trimmed;
      return unquoted.isEmpty ? null : StringValue(unquoted);
    case FlagType.integer:
      return switch (int.tryParse(trimmed)) {
        final value? => IntValue(value),
        null => null,
      };
    case FlagType.decimal:
      return switch (double.tryParse(trimmed)) {
        final value? when value.isFinite => DoubleValue(value),
        _ => null,
      };
    case FlagType.json:
      try {
        return switch (jsonDecode(trimmed)) {
          final Map<String, Object?> map => JsonValue(map),
          _ => null,
        };
      } on FormatException {
        return null;
      }
  }
}

/// A targeting rule in words: "country is one of PK, AE".
String ruleWords(TargetingRule rule) {
  final verb = switch (rule.operator) {
    TargetingOperator.equals => 'is',
    TargetingOperator.notEquals => 'is not',
    TargetingOperator.isIn => 'is one of',
    TargetingOperator.notIn => 'is none of',
    TargetingOperator.startsWith => 'starts with',
    TargetingOperator.endsWith => 'ends with',
    TargetingOperator.contains => 'contains',
    TargetingOperator.greaterThan => 'is more than',
    TargetingOperator.lessThan => 'is less than',
    TargetingOperator.semverAtLeast => 'is at least version',
    TargetingOperator.semverBelow => 'is below version',
    TargetingOperator.unknown =>
      '"${rule.operatorName}" (unknown: never matches)',
  };
  return '${rule.attribute} $verb ${rule.values.join(', ')}';
}
