import 'package:flutter/foundation.dart';

/// The demo's remote config server, as the Dashboard's console sees it:
/// what an admin would change on a real backend. Changes reach the app at
/// the next refresh, never at once: that's the point of the demo.
abstract interface class DemoServer {
  /// The server's flags now, then after every change.
  Stream<List<ServerFlag>> watchFlags();

  /// Switches the flag [key] on or off (its kill switch).
  void setEnabled(String key, bool enabled);

  /// Rolls the flag [key] out to [percent] of its users; `null` for all.
  void setRollout(String key, double? percent);

  /// Sets the look the server serves (`home_theme`'s value).
  void setTheme(String theme);

  /// The server's knobs now, then after every change.
  Stream<ServerKnobs> watchKnobs();

  /// How often its answers fail.
  void setFailures(ServerFailures failures);

  /// How long its answers take.
  void setSpeed(ServerSpeed speed);
}

/// A flag on the server.
@immutable
final class ServerFlag {
  const ServerFlag({
    required this.key,
    required this.enabled,
    required this.value,
    this.rolloutPercent,
    this.isTheme = false,
  });

  final String key;
  final bool enabled;

  /// The value it serves when it applies, as text.
  final String value;

  /// Its rollout, or `null` for everyone.
  final double? rolloutPercent;

  /// Whether it's the app's look (`setTheme` changes its value).
  final bool isTheme;

  @override
  bool operator ==(Object other) =>
      other is ServerFlag &&
      other.key == key &&
      other.enabled == enabled &&
      other.value == value &&
      other.rolloutPercent == rolloutPercent &&
      other.isTheme == isTheme;

  @override
  int get hashCode => Object.hash(key, enabled, value, rolloutPercent, isTheme);

  @override
  String toString() => 'ServerFlag($key, $enabled, $value, $rolloutPercent)';
}

/// How often the server fails: never, half the time, always.
enum ServerFailures { none, half, all }

/// How long the server takes: fast (no wait), normal (0.6 s), slow (3 s).
enum ServerSpeed { fast, normal, slow }

/// The server's knobs.
@immutable
final class ServerKnobs {
  const ServerKnobs({
    this.failures = ServerFailures.none,
    this.speed = ServerSpeed.normal,
  });

  final ServerFailures failures;
  final ServerSpeed speed;

  @override
  bool operator ==(Object other) =>
      other is ServerKnobs &&
      other.failures == failures &&
      other.speed == speed;

  @override
  int get hashCode => Object.hash(failures, speed);
}
