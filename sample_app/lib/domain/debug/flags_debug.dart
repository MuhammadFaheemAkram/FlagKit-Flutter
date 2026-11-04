import 'package:flutter/foundation.dart';

/// What the Dashboard knows about the SDK: the port its Cubit uses (the
/// adapter reads FlagKit).
abstract interface class FlagsDebug {
  /// The SDK's version.
  String get sdkVersion;

  /// The app's flags, each as FlagKit evaluates it right now.
  List<FlagReading> readAll();

  /// Emits whenever a reading may have changed.
  Stream<void> watch();
}

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
  });

  /// The flag's key.
  final String key;

  /// The value the app gets, as text.
  final String value;

  final ReadingSource source;
  final ReadingReason reason;

  @override
  bool operator ==(Object other) =>
      other is FlagReading &&
      other.key == key &&
      other.value == value &&
      other.source == source &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(key, value, source, reason);

  @override
  String toString() => 'FlagReading($key: $value, $source, $reason)';
}
