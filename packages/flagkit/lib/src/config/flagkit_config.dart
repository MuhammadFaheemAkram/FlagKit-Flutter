import 'package:flutter/foundation.dart';

/// How an app configures the SDK, once, at `FlagKit.initialize`.
///
/// Every value has a default except the API key. A value out of range is a
/// developer's mistake, so `initialize` rejects it with an [ArgumentError]
/// at once, in development, rather than misbehaving later on a user's phone.
@immutable
final class FlagKitConfig {
  /// The configuration; see each field for its default and range.
  const FlagKitConfig({
    required this.apiKey,
    this.refreshInterval = const Duration(hours: 1),
    this.cacheExpiration = const Duration(hours: 24),
    this.startupWait = Duration.zero,
    this.debugMode = false,
  });

  /// The shortest [refreshInterval]: a refresh per minute is already far
  /// more than flags need, and every app on every phone would make them.
  static const Duration minRefreshInterval = Duration(minutes: 1);

  /// The longest [startupWait]: an app's first frame mustn't wait longer
  /// for flags than a user would for the app.
  static const Duration maxStartupWait = Duration(seconds: 10);

  /// Identifies the app to the remote config server. Must not be blank.
  final String apiKey;

  /// How long fetched flags stay **fresh**: no refresh is needed before
  /// then. At least [minRefreshInterval].
  final Duration refreshInterval;

  /// How long fetched flags take to become **expired**: they're still
  /// served, but the SDK refreshes at every chance. At least
  /// [refreshInterval].
  final Duration cacheExpiration;

  /// With nothing cached (a first launch), how long `initialize` waits for
  /// the first fetch, so the first screen can show real values. With any
  /// cache it never waits. Zero to [maxStartupWait].
  final Duration startupWait;

  /// Whether the SDK logs what it does. Off, it is silent.
  final bool debugMode;

  /// Every rule this configuration breaks, in words; empty when valid.
  List<String> get problems => [
    if (apiKey.trim().isEmpty) 'apiKey must not be blank',
    if (refreshInterval < minRefreshInterval)
      'refreshInterval must be at least 1 minute (was $refreshInterval)',
    if (cacheExpiration < refreshInterval)
      'cacheExpiration must be at least refreshInterval ($refreshInterval) '
          '(was $cacheExpiration)',
    if (startupWait < Duration.zero || startupWait > maxStartupWait)
      'startupWait must be 0–10 seconds (was $startupWait)',
  ];

  /// Throws an [ArgumentError] naming every broken rule.
  void validate() {
    final problems = this.problems;
    if (problems.isNotEmpty) {
      throw ArgumentError('Invalid FlagKitConfig: ${problems.join('; ')}.');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is FlagKitConfig &&
      other.apiKey == apiKey &&
      other.refreshInterval == refreshInterval &&
      other.cacheExpiration == cacheExpiration &&
      other.startupWait == startupWait &&
      other.debugMode == debugMode;

  @override
  int get hashCode => Object.hash(
    apiKey,
    refreshInterval,
    cacheExpiration,
    startupWait,
    debugMode,
  );

  // The key is masked: a config printed in a log or a crash report must not
  // leak it.
  @override
  String toString() =>
      'FlagKitConfig(apiKey: ${_masked(apiKey)}, '
      'refreshInterval: $refreshInterval, cacheExpiration: $cacheExpiration, '
      'startupWait: $startupWait, debugMode: $debugMode)';

  static String _masked(String key) =>
      key.length <= 4 ? '****' : '${key.substring(0, 4)}****';
}
