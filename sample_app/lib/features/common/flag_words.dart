import 'package:flagkit_sample/core/common/money.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';

/// Why a reading has its value, in words.
String reasonWords(ReadingReason reason) => switch (reason) {
  ReadingReason.override => 'overridden on this device',
  ReadingReason.switchedOff => 'switched off on the server',
  ReadingReason.rulesMatched => 'the targeting rules match you',
  ReadingReason.rulesMissed => 'the targeting rules don\'t match you',
  ReadingReason.inRollout => 'you\'re in the rollout',
  ReadingReason.outsideRollout => 'you\'re outside the rollout',
  ReadingReason.onForEveryone => 'on for everyone',
  ReadingReason.notRunning => 'FlagKit isn\'t running',
  ReadingReason.unknownFlag => 'FlagKit doesn\'t know this flag yet',
  ReadingReason.wrongType => 'the server sends another type',
};

/// Why the user sees [subject] (what [reading]'s flag decided), as a
/// sentence or two: the screens' "Why am I seeing this?" lines.
String whyWords(String subject, FlagReading reading) {
  final because = switch (reading) {
    FlagReading(reason: ReadingReason.override) =>
      'it\'s overridden on this device.',
    FlagReading(reason: ReadingReason.switchedOff) =>
      'the flag is switched off on the server.',
    FlagReading(reason: ReadingReason.rulesMissed) =>
      'the flag targets other users: its rules don\'t match you.',
    FlagReading(reason: ReadingReason.rulesMatched, bucket: null) =>
      'the flag\'s targeting rules match you.',
    FlagReading(reason: ReadingReason.rulesMatched) =>
      'the flag\'s rules match you, and you\'re in its '
          '${_rollout(reading)}.',
    FlagReading(reason: ReadingReason.inRollout) =>
      'you\'re in its ${_rollout(reading)}.',
    FlagReading(reason: ReadingReason.outsideRollout) =>
      'you\'re outside its ${_rollout(reading)}.',
    FlagReading(reason: ReadingReason.onForEveryone) =>
      'the flag is on for everyone.',
    FlagReading(
      reason: ReadingReason.notRunning ||
          ReadingReason.unknownFlag ||
          ReadingReason.wrongType,
    ) =>
      'FlagKit has no value for the flag, so the app uses its own default.',
  };
  final from = switch (reading.source) {
    ReadingSource.server => ' From the server.',
    ReadingSource.cache => ' From the flags saved on this device.',
    ReadingSource.override || ReadingSource.appDefault => '',
  };
  return 'You see $subject because $because$from';
}

/// "25 % rollout (bucket 404 of 10,000, below 2500)".
String _rollout(FlagReading reading) {
  final percent = reading.rolloutPercent ?? 0;
  final threshold = (percent * 100).round();
  final bucket = reading.bucket;
  final side = bucket != null && bucket < threshold ? 'below' : 'not below';
  return '${formatPercent(percent)} rollout '
      '(bucket $bucket of 10,000, $side $threshold)';
}
