import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';

/// What the app gets for each flag when FlagKit has no value: the
/// defaults in [AppFlagDefaults], as the readings print them.
final _defaults = <String, String>{
  AppFlagKeys.newHomeScreen: '${AppFlagDefaults.newHomeScreen}',
  AppFlagKeys.newCheckout: '${AppFlagDefaults.newCheckout}',
  AppFlagKeys.homeTheme: '"${AppFlagDefaults.homeTheme}"',
  AppFlagKeys.feedPageSize: '${AppFlagDefaults.feedPageSize}',
  AppFlagKeys.discountPercentage: '${AppFlagDefaults.discountPercentage}',
  AppFlagKeys.homeConfig: '${AppFlagDefaults.homeConfig}',
};

/// [detail], FlagKit's explanation of a read, in the app's words: shared
/// by the Dashboard and the screens' "Why am I seeing this?" lines.
FlagReading readingOf(FlagDetail detail) => FlagReading(
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
  bucket: detail.bucket,
  rolloutPercent: detail.rolloutPercent,
);
