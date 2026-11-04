import 'package:flagkit/src/model/flag_source.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:flagkit/src/repository/flag_snapshot.dart';
import 'package:flagkit/src/storage/flag_mapper.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/meta_keys.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:meta/meta.dart';

/// The cached definitions, in memory and on disk.
///
/// It holds the [snapshot] reads use, and keeps the database in step with
/// it: every change is written first, in one transaction, and only then
/// swapped in. A write that fails leaves the snapshot as it was, so memory
/// never claims what the disk doesn't have.
@internal
final class FlagRepository {
  FlagRepository._(
    this._database,
    this._logger,
    this._snapshot,
    this.anonymousId,
  );

  /// Loads the cache: this install's anonymous id (created, and stored, on
  /// the first start) and every definition that can still be read.
  static Future<FlagRepository> open(
    FlagKitDatabase database, {
    required FlagKitLogger logger,
    required String Function() newId,
  }) async {
    final meta = database.metaDao;
    var anonymousId = await meta.read(MetaKeys.anonymousId);
    if (anonymousId == null) {
      anonymousId = newId();
      await meta.write(MetaKeys.anonymousId, anonymousId);
    }
    final rows = await database.flagDao.all();
    final flags = <String, FlagDefinition>{};
    for (final row in rows) {
      if (row.toDefinition() case final definition?) {
        flags[definition.key] = definition;
      }
    }
    if (flags.length < rows.length) {
      logger.warning(
        '${rows.length - flags.length} cached definitions could not be read: '
        'skipped (the next refresh replaces them)',
      );
    }
    final snapshot = FlagSnapshot(
      flags: flags,
      source: FlagSource.cache,
      fetchedAt: _instant(await meta.read(MetaKeys.fetchedAt)),
      configVersion: int.tryParse(
        await meta.read(MetaKeys.configVersion) ?? '',
      ),
    );
    logger.debug('cache: ${flags.length} flags, fetched ${snapshot.fetchedAt}');
    return FlagRepository._(database, logger, snapshot, anonymousId);
  }

  final FlagKitDatabase _database;
  final FlagKitLogger _logger;
  FlagSnapshot _snapshot;

  /// This install's anonymous id.
  final String anonymousId;

  /// What reads see now.
  FlagSnapshot get snapshot => _snapshot;

  /// Makes the cache exactly [definitions], fetched at [fetchedAt] as the
  /// server's [configVersion]: the definitions, the deletion of the ones
  /// no longer sent, the version and the time, in one transaction. Then
  /// the new snapshot (source `remote`) is swapped in, and returned.
  Future<FlagSnapshot> replace({
    required List<FlagDefinition> definitions,
    required int configVersion,
    required DateTime fetchedAt,
  }) async {
    final at = fetchedAt.toUtc();
    await _database.transaction(() async {
      await _database.flagDao.replaceAll([
        for (final definition in definitions) definition.toRow(),
      ]);
      await _database.metaDao.write(MetaKeys.fetchedAt, at.toIso8601String());
      await _database.metaDao.write(MetaKeys.configVersion, '$configVersion');
    });
    return _snapshot = FlagSnapshot(
      flags: {for (final definition in definitions) definition.key: definition},
      source: FlagSource.remote,
      fetchedAt: at,
      configVersion: configVersion,
    );
  }

  /// Forgets the cached definitions, when they were fetched and their
  /// version. The anonymous id stays: clearing a cache isn't a new install.
  Future<FlagSnapshot> clear() async {
    await _database.transaction(() async {
      await _database.flagDao.clear();
      await _database.metaDao.remove(MetaKeys.fetchedAt);
      await _database.metaDao.remove(MetaKeys.configVersion);
    });
    _logger.debug('cache cleared');
    return _snapshot = FlagSnapshot.empty;
  }

  static DateTime? _instant(String? text) =>
      text == null ? null : DateTime.tryParse(text)?.toUtc();
}
