// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'override_dao.dart';

// ignore_for_file: type=lint
mixin _$OverrideDaoMixin on DatabaseAccessor<FlagKitDatabase> {
  $OverridesTable get overrides => attachedDatabase.overrides;
  OverrideDaoManager get managers => OverrideDaoManager(this);
}

class OverrideDaoManager {
  final _$OverrideDaoMixin _db;
  OverrideDaoManager(this._db);
  $$OverridesTableTableManager get overrides =>
      $$OverridesTableTableManager(_db.attachedDatabase, _db.overrides);
}
