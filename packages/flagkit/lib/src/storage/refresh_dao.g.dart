// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'refresh_dao.dart';

// ignore_for_file: type=lint
mixin _$RefreshDaoMixin on DatabaseAccessor<FlagKitDatabase> {
  $RefreshesTable get refreshes => attachedDatabase.refreshes;
  RefreshDaoManager get managers => RefreshDaoManager(this);
}

class RefreshDaoManager {
  final _$RefreshDaoMixin _db;
  RefreshDaoManager(this._db);
  $$RefreshesTableTableManager get refreshes =>
      $$RefreshesTableTableManager(_db.attachedDatabase, _db.refreshes);
}
