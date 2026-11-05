import 'package:flagkit/src/model/cache_status.dart';
import 'package:flagkit/src/model/refresh_record.dart';
import 'package:flutter/foundation.dart';

/// The SDK's state, for a debug screen: `FlagKit.debug.watchStats()`.
@immutable
final class FlagKitStats {
  /// The SDK's state at one moment.
  const FlagKitStats({
    required this.cacheStatus,
    required this.flagCount,
    required this.anonymousId,
    this.fetchedAt,
    this.configVersion,
    this.lastRefresh,
  });

  /// How fresh the cached flags are.
  final CacheStatus cacheStatus;

  /// How many definitions are cached.
  final int flagCount;

  /// This install's anonymous id: the rollout unit when no user is signed
  /// in.
  final String anonymousId;

  /// When the flags were last fetched, if ever (UTC).
  final DateTime? fetchedAt;

  /// The server's version of the cached flags, if known.
  final int? configVersion;

  /// The latest refresh in the log, if any.
  final RefreshRecord? lastRefresh;

  @override
  bool operator ==(Object other) =>
      other is FlagKitStats &&
      other.cacheStatus == cacheStatus &&
      other.flagCount == flagCount &&
      other.anonymousId == anonymousId &&
      other.fetchedAt == fetchedAt &&
      other.configVersion == configVersion;

  @override
  int get hashCode => Object.hash(
    cacheStatus,
    flagCount,
    anonymousId,
    fetchedAt,
    configVersion,
  );

  @override
  String toString() =>
      'FlagKitStats(${cacheStatus.name}, $flagCount flags, fetched $fetchedAt, '
      'version $configVersion)';
}
