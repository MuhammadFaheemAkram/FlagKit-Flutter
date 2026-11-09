import 'package:flutter/foundation.dart';

/// Where a reading's value came from, in the app's words.
enum ReadingSource { override, server, cache, appDefault }

/// Why a reading has its value, in the app's words.
enum ReadingReason {
  override,
  switchedOff,
  rulesMatched,
  rulesMissed,
  inRollout,
  outsideRollout,
  onForEveryone,
  notRunning,
  unknownFlag,
  wrongType,
}

/// One flag, as the Dashboard shows it.
@immutable
final class FlagReading {
  const FlagReading({
    required this.key,
    required this.value,
    required this.source,
    required this.reason,
    this.bucket,
    this.rolloutPercent,
  });

  /// The flag's key.
  final String key;

  /// The value the app gets, as text.
  final String value;

  final ReadingSource source;
  final ReadingReason reason;

  /// For a rolled-out flag: the user's bucket, 0–9999. They get the flag
  /// when it's below [rolloutPercent] × 100.
  final int? bucket;

  /// For a rolled-out flag: the share of eligible users who get it.
  final double? rolloutPercent;

  @override
  bool operator ==(Object other) =>
      other is FlagReading &&
      other.key == key &&
      other.value == value &&
      other.source == source &&
      other.reason == reason &&
      other.bucket == bucket &&
      other.rolloutPercent == rolloutPercent;

  @override
  int get hashCode =>
      Object.hash(key, value, source, reason, bucket, rolloutPercent);

  @override
  String toString() =>
      'FlagReading($key: $value, $source, $reason'
      '${bucket == null ? '' : ', bucket $bucket of $rolloutPercent %'})';
}
