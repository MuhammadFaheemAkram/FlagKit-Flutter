import 'package:drift/drift.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/tables.dart';
import 'package:meta/meta.dart';

part 'override_dao.g.dart';

/// Reads and writes the local overrides.
@internal
@DriftAccessor(tables: [Overrides])
class OverrideDao extends DatabaseAccessor<FlagKitDatabase>
    with _$OverrideDaoMixin {
  OverrideDao(super.attachedDatabase);

  Future<List<OverrideRow>> all() => select(overrides).get();

  /// Sets the override for its key, replacing any.
  Future<void> save(OverrideRow row) =>
      into(overrides).insertOnConflictUpdate(row);

  Future<void> remove(String key) =>
      (delete(overrides)..where((row) => row.key.equals(key))).go();

  Future<void> clear() => delete(overrides).go();
}
