// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'flag_dao.dart';

// ignore_for_file: type=lint
mixin _$FlagDaoMixin on DatabaseAccessor<FlagKitDatabase> {
  $FlagsTable get flags => attachedDatabase.flags;
  FlagDaoManager get managers => FlagDaoManager(this);
}

class FlagDaoManager {
  final _$FlagDaoMixin _db;
  FlagDaoManager(this._db);
  $$FlagsTableTableManager get flags =>
      $$FlagsTableTableManager(_db.attachedDatabase, _db.flags);
}
