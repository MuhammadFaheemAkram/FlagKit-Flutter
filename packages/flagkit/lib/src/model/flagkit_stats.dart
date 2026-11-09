import 'package:flagkit/src/model/cache_status.dart';
import 'package:flagkit/src/model/flag_source.dart';
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
    this.overrideCount = 0,
    this.online = true,
    this.refreshing = false,
    this.evaluations = const {},
    this.refreshCount = 0,
    this.failedRefreshCount = 0,
    this.skippedCount = 0,
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

  /// How many local overrides are set.
  final int overrideCount;

  /// Whether the device is online, as the network monitor says.
  final bool online;

  /// Whether a refresh is running.
  final bool refreshing;

  /// This session's reads, by where their value came from. Counted as the
  /// app reads; the stats carry the count as of their latest change.
  final Map<FlagSource, int> evaluations;

  /// Refreshes logged on this install, ever (the log keeps the newest 50).
  final int refreshCount;

  /// How many of them failed (an error, or a rejected key).
  final int failedRefreshCount;

  /// How many invalid definitions refreshes left out, in all.
  final int skippedCount;

  @override
  bool operator ==(Object other) =>
      other is FlagKitStats &&
      other.cacheStatus == cacheStatus &&
      other.flagCount == flagCount &&
      other.anonymousId == anonymousId &&
      other.fetchedAt == fetchedAt &&
      other.configVersion == configVersion &&
      other.lastRefresh == lastRefresh &&
      other.overrideCount == overrideCount &&
      other.online == online &&
      other.refreshing == refreshing &&
      mapEquals(other.evaluations, evaluations) &&
      other.refreshCount == refreshCount &&
      other.failedRefreshCount == failedRefreshCount &&
      other.skippedCount == skippedCount;

  @override
  int get hashCode => Object.hash(
    cacheStatus,
    flagCount,
    anonymousId,
    fetchedAt,
    configVersion,
    lastRefresh,
    overrideCount,
    online,
    refreshing,
    Object.hashAllUnordered(
      evaluations.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    refreshCount,
    failedRefreshCount,
    skippedCount,
  );

  @override
  String toString() =>
      'FlagKitStats(${cacheStatus.name}, $flagCount flags, '
      '$overrideCount overrides, fetched $fetchedAt, version $configVersion, '
      '${online ? 'online' : 'offline'}${refreshing ? ', refreshing' : ''})';
}
