import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/data/flags/flag_reading_mapper.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:injectable/injectable.dart';

/// [FlagsDebug] with FlagKit: each of the app's flags with its value,
/// source and reason, as `FlagKit.detail` explains it.
@LazySingleton(as: FlagsDebug)
class FlagKitFlagsDebug implements FlagsDebug {
  FlagKitFlagsDebug(this._flags);

  final FlagKitClient _flags;

  @override
  String get sdkVersion => FlagKit.version;

  @override
  List<FlagReading> readAll() => [
    for (final key in AppFlagKeys.all) readingOf(_flags.detail(key)),
  ];

  @override
  Stream<void> watch() => _flags.changes.map((_) {});

  @override
  Stream<CacheInfo> watchCache() => _flags.debug.watchStats().map(
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
        final record? => LastRefresh(
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
        ),
        null => null,
      },
    ),
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
}
