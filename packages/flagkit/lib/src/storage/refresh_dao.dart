import 'package:drift/drift.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/tables.dart';
import 'package:meta/meta.dart';

part 'refresh_dao.g.dart';

/// The refresh log.
@internal
@DriftAccessor(tables: [Refreshes])
class RefreshDao extends DatabaseAccessor<FlagKitDatabase>
    with _$RefreshDaoMixin {
  RefreshDao(super.attachedDatabase);

  /// How many refreshes the log keeps.
  static const keep = 50;

  /// Adds a refresh, then trims the log to the newest [keep].
  Future<void> add(RefreshesCompanion row) => transaction(() async {
    await into(refreshes).insert(row);
    await customStatement(
      'DELETE FROM refreshes WHERE id NOT IN '
      '(SELECT id FROM refreshes ORDER BY id DESC LIMIT ?)',
      [keep],
    );
  });

  SimpleSelectStatement<$RefreshesTable, RefreshRow> _newest(int limit) =>
      select(refreshes)
        ..orderBy([(row) => OrderingTerm.desc(row.id)])
        ..limit(limit);

  /// The refresh [id], if still kept.
  Future<RefreshRow?> byId(int id) =>
      (select(refreshes)..where((row) => row.id.equals(id))).getSingleOrNull();

  /// The newest [limit] refreshes, newest first.
  Future<List<RefreshRow>> newest({int limit = keep}) => _newest(limit).get();

  /// The newest [limit] refreshes, now and after every change.
  Stream<List<RefreshRow>> watchNewest({int limit = keep}) =>
      _newest(limit).watch();
}
