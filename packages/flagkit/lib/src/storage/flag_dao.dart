import 'package:drift/drift.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/tables.dart';
import 'package:meta/meta.dart';

part 'flag_dao.g.dart';

/// Reads and writes the cached definitions.
@internal
@DriftAccessor(tables: [Flags])
class FlagDao extends DatabaseAccessor<FlagKitDatabase> with _$FlagDaoMixin {
  FlagDao(super.attachedDatabase);

  /// Every cached definition, by key.
  Future<List<FlagRow>> all() =>
      (select(flags)..orderBy([(row) => OrderingTerm.asc(row.key)])).get();

  /// The definition of [key], if cached.
  Future<FlagRow?> byKey(String key) =>
      (select(flags)..where((row) => row.key.equals(key))).getSingleOrNull();

  /// Saves [row], replacing the definition with its key if there is one.
  ///
  /// `INSERT OR REPLACE` on purpose: the row is a whole definition, every
  /// column written (an upsert from a data class leaves `NULL`s unwritten,
  /// so a rollout removed on the server would survive, conventions §11.57),
  /// and nothing references this table, so a replace cascades nowhere.
  Future<void> save(FlagRow row) =>
      into(flags).insert(row, mode: InsertMode.insertOrReplace);

  /// Makes the cache exactly [rows]: saves each, and deletes the
  /// definitions the server no longer sends. Call it inside a transaction.
  Future<void> replaceAll(List<FlagRow> rows) async {
    await (delete(
      flags,
    )..where((row) => row.key.isNotIn([for (final r in rows) r.key]))).go();
    for (final row in rows) {
      await save(row);
    }
  }

  /// Deletes every cached definition.
  Future<int> clear() => delete(flags).go();
}
