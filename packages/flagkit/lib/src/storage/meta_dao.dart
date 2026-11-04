import 'package:drift/drift.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/tables.dart';
import 'package:meta/meta.dart';

part 'meta_dao.g.dart';

/// Reads and writes the `meta` table: named strings.
@internal
@DriftAccessor(tables: [MetaEntries])
class MetaDao extends DatabaseAccessor<FlagKitDatabase> with _$MetaDaoMixin {
  MetaDao(super.attachedDatabase);

  Future<String?> read(String name) =>
      (select(metaEntries)..where((row) => row.name.equals(name)))
          .map((row) => row.value)
          .getSingleOrNull();

  Future<void> write(String name, String value) =>
      into(metaEntries)
          .insertOnConflictUpdate(MetaRow(name: name, value: value));

  Future<void> remove(String name) =>
      (delete(metaEntries)..where((row) => row.name.equals(name))).go();
}
