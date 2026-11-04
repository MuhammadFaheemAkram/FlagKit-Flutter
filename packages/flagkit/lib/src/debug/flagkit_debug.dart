import 'package:clock/clock.dart';
import 'package:flagkit/src/cache/cache_policy.dart';
import 'package:flagkit/src/config/flagkit_config.dart';
import 'package:flagkit/src/model/flagkit_stats.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:meta/meta.dart';

/// Tools for a debug screen and for support: what the SDK holds, and why.
/// Kept apart from the everyday API (`FlagKit.debug`), so an app's screens
/// never depend on them.
abstract interface class FlagKitDebug {
  /// The SDK's state now, then again after every change to the cache.
  Stream<FlagKitStats> watchStats();
}

/// [FlagKitDebug] over the database: one watched query, so the stats
/// update with every write.
@internal
final class DatabaseDebug implements FlagKitDebug {
  DatabaseDebug(this._database, this._config, {Clock? clock})
    : _clock = clock ?? const Clock();

  final FlagKitDatabase _database;
  final FlagKitConfig _config;
  final Clock _clock;

  @override
  Stream<FlagKitStats> watchStats() => _database.watchStatsRow().map((row) {
    final fetchedAt = DateTime.tryParse(
      row.readNullable<String>('fetched_at') ?? '',
    )?.toUtc();
    return FlagKitStats(
      cacheStatus: cacheStatusOf(
        fetchedAt: fetchedAt,
        now: _clock.now().toUtc(),
        refreshInterval: _config.refreshInterval,
        cacheExpiration: _config.cacheExpiration,
      ),
      flagCount: row.read<int>('flag_count'),
      anonymousId: row.readNullable<String>('anonymous_id') ?? '',
      fetchedAt: fetchedAt,
      configVersion: int.tryParse(
        row.readNullable<String>('config_version') ?? '',
      ),
    );
  });
}
