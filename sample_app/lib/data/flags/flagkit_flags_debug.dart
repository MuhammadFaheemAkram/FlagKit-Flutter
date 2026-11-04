import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:injectable/injectable.dart';

/// [FlagsDebug] with FlagKit: each of the app's flags with its value,
/// source and reason, as `FlagKit.detail` explains it.
@LazySingleton(as: FlagsDebug)
class FlagKitFlagsDebug implements FlagsDebug {
  FlagKitFlagsDebug(this._flags);

  final FlagKitClient _flags;

  /// What the app gets for each flag when FlagKit has no value: the
  /// defaults in [AppFlagDefaults], as the Dashboard prints them.
  static final _defaults = <String, String>{
    AppFlagKeys.newHomeScreen: '${AppFlagDefaults.newHomeScreen}',
    AppFlagKeys.newCheckout: '${AppFlagDefaults.newCheckout}',
    AppFlagKeys.homeTheme: '"${AppFlagDefaults.homeTheme}"',
    AppFlagKeys.feedPageSize: '${AppFlagDefaults.feedPageSize}',
    AppFlagKeys.discountPercentage: '${AppFlagDefaults.discountPercentage}',
    AppFlagKeys.homeConfig: '${AppFlagDefaults.homeConfig}',
  };

  @override
  String get sdkVersion => FlagKit.version;

  @override
  List<FlagReading> readAll() => [
    for (final key in AppFlagKeys.all) _reading(_flags.detail(key)),
  ];

  @override
  Stream<void> watch() => _flags.changes.map((_) {});

  FlagReading _reading(FlagDetail detail) => FlagReading(
    key: detail.key,
    value: detail.value?.toString() ?? _defaults[detail.key] ?? '—',
    source: switch (detail.source) {
      FlagSource.override => ReadingSource.override,
      FlagSource.remote => ReadingSource.server,
      FlagSource.cache => ReadingSource.cache,
      FlagSource.defaultValue => ReadingSource.appDefault,
    },
    reason: switch (detail.reason) {
      EvaluationReason.override => ReadingReason.override,
      EvaluationReason.off => ReadingReason.switchedOff,
      EvaluationReason.targetingMatch => ReadingReason.rulesMatched,
      EvaluationReason.targetingMiss => ReadingReason.rulesMissed,
      EvaluationReason.rolloutIncluded => ReadingReason.inRollout,
      EvaluationReason.rolloutExcluded => ReadingReason.outsideRollout,
      EvaluationReason.fallthrough => ReadingReason.onForEveryone,
      EvaluationReason.notInitialized => ReadingReason.notRunning,
      EvaluationReason.flagNotFound => ReadingReason.unknownFlag,
      EvaluationReason.typeMismatch => ReadingReason.wrongType,
    },
  );
}
