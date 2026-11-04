// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'flagkit_database.dart';

// ignore_for_file: type=lint
class $FlagsTable extends Flags with TableInfo<$FlagsTable, FlagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offValueMeta = const VerificationMeta(
    'offValue',
  );
  @override
  late final GeneratedColumn<String> offValue = GeneratedColumn<String>(
    'off_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _rolloutBpMeta = const VerificationMeta(
    'rolloutBp',
  );
  @override
  late final GeneratedColumn<int> rolloutBp = GeneratedColumn<int>(
    'rollout_bp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rulesMeta = const VerificationMeta('rules');
  @override
  late final GeneratedColumn<String> rules = GeneratedColumn<String>(
    'rules',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    type,
    value,
    offValue,
    enabled,
    rolloutBp,
    rules,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flags';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('off_value')) {
      context.handle(
        _offValueMeta,
        offValue.isAcceptableOrUnknown(data['off_value']!, _offValueMeta),
      );
    } else if (isInserting) {
      context.missing(_offValueMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('rollout_bp')) {
      context.handle(
        _rolloutBpMeta,
        rolloutBp.isAcceptableOrUnknown(data['rollout_bp']!, _rolloutBpMeta),
      );
    }
    if (data.containsKey('rules')) {
      context.handle(
        _rulesMeta,
        rules.isAcceptableOrUnknown(data['rules']!, _rulesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  FlagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlagRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      offValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}off_value'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      rolloutBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rollout_bp'],
      ),
      rules: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FlagsTable createAlias(String alias) {
    return $FlagsTable(attachedDatabase, alias);
  }
}

class FlagRow extends DataClass implements Insertable<FlagRow> {
  final String key;
  final String type;

  /// The value served when the flag applies, as JSON.
  final String value;

  /// The value served when it doesn't (switched off, a rule missed, outside
  /// the rollout), as JSON.
  final String offValue;
  final bool enabled;

  /// The rollout in basis points (0–10000: 12.5 % is 1250), or `null` for
  /// everyone.
  final int? rolloutBp;

  /// The targeting rules, as a JSON array.
  final String rules;
  final DateTime updatedAt;
  const FlagRow({
    required this.key,
    required this.type,
    required this.value,
    required this.offValue,
    required this.enabled,
    this.rolloutBp,
    required this.rules,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    map['off_value'] = Variable<String>(offValue);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || rolloutBp != null) {
      map['rollout_bp'] = Variable<int>(rolloutBp);
    }
    map['rules'] = Variable<String>(rules);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FlagsCompanion toCompanion(bool nullToAbsent) {
    return FlagsCompanion(
      key: Value(key),
      type: Value(type),
      value: Value(value),
      offValue: Value(offValue),
      enabled: Value(enabled),
      rolloutBp: rolloutBp == null && nullToAbsent
          ? const Value.absent()
          : Value(rolloutBp),
      rules: Value(rules),
      updatedAt: Value(updatedAt),
    );
  }

  factory FlagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlagRow(
      key: serializer.fromJson<String>(json['key']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      offValue: serializer.fromJson<String>(json['offValue']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      rolloutBp: serializer.fromJson<int?>(json['rolloutBp']),
      rules: serializer.fromJson<String>(json['rules']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'offValue': serializer.toJson<String>(offValue),
      'enabled': serializer.toJson<bool>(enabled),
      'rolloutBp': serializer.toJson<int?>(rolloutBp),
      'rules': serializer.toJson<String>(rules),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FlagRow copyWith({
    String? key,
    String? type,
    String? value,
    String? offValue,
    bool? enabled,
    Value<int?> rolloutBp = const Value.absent(),
    String? rules,
    DateTime? updatedAt,
  }) => FlagRow(
    key: key ?? this.key,
    type: type ?? this.type,
    value: value ?? this.value,
    offValue: offValue ?? this.offValue,
    enabled: enabled ?? this.enabled,
    rolloutBp: rolloutBp.present ? rolloutBp.value : this.rolloutBp,
    rules: rules ?? this.rules,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FlagRow copyWithCompanion(FlagsCompanion data) {
    return FlagRow(
      key: data.key.present ? data.key.value : this.key,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      offValue: data.offValue.present ? data.offValue.value : this.offValue,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      rolloutBp: data.rolloutBp.present ? data.rolloutBp.value : this.rolloutBp,
      rules: data.rules.present ? data.rules.value : this.rules,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlagRow(')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('offValue: $offValue, ')
          ..write('enabled: $enabled, ')
          ..write('rolloutBp: $rolloutBp, ')
          ..write('rules: $rules, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    type,
    value,
    offValue,
    enabled,
    rolloutBp,
    rules,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlagRow &&
          other.key == this.key &&
          other.type == this.type &&
          other.value == this.value &&
          other.offValue == this.offValue &&
          other.enabled == this.enabled &&
          other.rolloutBp == this.rolloutBp &&
          other.rules == this.rules &&
          other.updatedAt == this.updatedAt);
}

class FlagsCompanion extends UpdateCompanion<FlagRow> {
  final Value<String> key;
  final Value<String> type;
  final Value<String> value;
  final Value<String> offValue;
  final Value<bool> enabled;
  final Value<int?> rolloutBp;
  final Value<String> rules;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FlagsCompanion({
    this.key = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.offValue = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rolloutBp = const Value.absent(),
    this.rules = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlagsCompanion.insert({
    required String key,
    required String type,
    required String value,
    required String offValue,
    required bool enabled,
    this.rolloutBp = const Value.absent(),
    this.rules = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       type = Value(type),
       value = Value(value),
       offValue = Value(offValue),
       enabled = Value(enabled),
       updatedAt = Value(updatedAt);
  static Insertable<FlagRow> custom({
    Expression<String>? key,
    Expression<String>? type,
    Expression<String>? value,
    Expression<String>? offValue,
    Expression<bool>? enabled,
    Expression<int>? rolloutBp,
    Expression<String>? rules,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (offValue != null) 'off_value': offValue,
      if (enabled != null) 'enabled': enabled,
      if (rolloutBp != null) 'rollout_bp': rolloutBp,
      if (rules != null) 'rules': rules,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlagsCompanion copyWith({
    Value<String>? key,
    Value<String>? type,
    Value<String>? value,
    Value<String>? offValue,
    Value<bool>? enabled,
    Value<int?>? rolloutBp,
    Value<String>? rules,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FlagsCompanion(
      key: key ?? this.key,
      type: type ?? this.type,
      value: value ?? this.value,
      offValue: offValue ?? this.offValue,
      enabled: enabled ?? this.enabled,
      rolloutBp: rolloutBp ?? this.rolloutBp,
      rules: rules ?? this.rules,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (offValue.present) {
      map['off_value'] = Variable<String>(offValue.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rolloutBp.present) {
      map['rollout_bp'] = Variable<int>(rolloutBp.value);
    }
    if (rules.present) {
      map['rules'] = Variable<String>(rules.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlagsCompanion(')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('offValue: $offValue, ')
          ..write('enabled: $enabled, ')
          ..write('rolloutBp: $rolloutBp, ')
          ..write('rules: $rules, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaEntriesTable extends MetaEntries
    with TableInfo<$MetaEntriesTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaEntriesTable createAlias(String alias) {
    return $MetaEntriesTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String name;
  final String value;
  const MetaRow({required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaEntriesCompanion toCompanion(bool nullToAbsent) {
    return MetaEntriesCompanion(name: Value(name), value: Value(value));
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? name, String? value}) =>
      MetaRow(name: name ?? this.name, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaEntriesCompanion data) {
    return MetaRow(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow &&
          other.name == this.name &&
          other.value == this.value);
}

class MetaEntriesCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> name;
  final Value<String> value;
  final Value<int> rowid;
  const MetaEntriesCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaEntriesCompanion.insert({
    required String name,
    required String value,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaEntriesCompanion copyWith({
    Value<String>? name,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaEntriesCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntriesCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FlagKitDatabase extends GeneratedDatabase {
  _$FlagKitDatabase(QueryExecutor e) : super(e);
  $FlagKitDatabaseManager get managers => $FlagKitDatabaseManager(this);
  late final $FlagsTable flags = $FlagsTable(this);
  late final $MetaEntriesTable metaEntries = $MetaEntriesTable(this);
  late final FlagDao flagDao = FlagDao(this as FlagKitDatabase);
  late final MetaDao metaDao = MetaDao(this as FlagKitDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [flags, metaEntries];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$FlagsTableCreateCompanionBuilder = FlagsCompanion Function({
  required String key,
  required String type,
  required String value,
  required String offValue,
  required bool enabled,
  Value<int?> rolloutBp,
  Value<String> rules,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FlagsTableUpdateCompanionBuilder = FlagsCompanion Function({
  Value<String> key,
  Value<String> type,
  Value<String> value,
  Value<String> offValue,
  Value<bool> enabled,
  Value<int?> rolloutBp,
  Value<String> rules,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FlagsTableFilterComposer
    extends Composer<_$FlagKitDatabase, $FlagsTable> {
  $$FlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offValue => $composableBuilder(
    column: $table.offValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rolloutBp => $composableBuilder(
    column: $table.rolloutBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlagsTableOrderingComposer
    extends Composer<_$FlagKitDatabase, $FlagsTable> {
  $$FlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offValue => $composableBuilder(
    column: $table.offValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rolloutBp => $composableBuilder(
    column: $table.rolloutBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlagsTableAnnotationComposer
    extends Composer<_$FlagKitDatabase, $FlagsTable> {
  $$FlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get offValue =>
      $composableBuilder(column: $table.offValue, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get rolloutBp =>
      $composableBuilder(column: $table.rolloutBp, builder: (column) => column);

  GeneratedColumn<String> get rules =>
      $composableBuilder(column: $table.rules, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FlagsTableTableManager
    extends
        RootTableManager<
          _$FlagKitDatabase,
          $FlagsTable,
          FlagRow,
          $$FlagsTableFilterComposer,
          $$FlagsTableOrderingComposer,
          $$FlagsTableAnnotationComposer,
          $$FlagsTableCreateCompanionBuilder,
          $$FlagsTableUpdateCompanionBuilder,
          (FlagRow, BaseReferences<_$FlagKitDatabase, $FlagsTable, FlagRow>),
          FlagRow,
          PrefetchHooks Function()
        > {
  $$FlagsTableTableManager(_$FlagKitDatabase db, $FlagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> offValue = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int?> rolloutBp = const Value.absent(),
                Value<String> rules = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlagsCompanion(
                key: key,
                type: type,
                value: value,
                offValue: offValue,
                enabled: enabled,
                rolloutBp: rolloutBp,
                rules: rules,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String type,
                required String value,
                required String offValue,
                required bool enabled,
                Value<int?> rolloutBp = const Value.absent(),
                Value<String> rules = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FlagsCompanion.insert(
                key: key,
                type: type,
                value: value,
                offValue: offValue,
                enabled: enabled,
                rolloutBp: rolloutBp,
                rules: rules,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlagsTable, FlagRow>(table),
                  BaseReferences<_$FlagKitDatabase, $FlagsTable, FlagRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlagKitDatabase,
      $FlagsTable,
      FlagRow,
      $$FlagsTableFilterComposer,
      $$FlagsTableOrderingComposer,
      $$FlagsTableAnnotationComposer,
      $$FlagsTableCreateCompanionBuilder,
      $$FlagsTableUpdateCompanionBuilder,
      (FlagRow, BaseReferences<_$FlagKitDatabase, $FlagsTable, FlagRow>),
      FlagRow,
      PrefetchHooks Function()
    >;
typedef $$MetaEntriesTableCreateCompanionBuilder =
    MetaEntriesCompanion Function({
      required String name,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaEntriesTableUpdateCompanionBuilder =
    MetaEntriesCompanion Function({
      Value<String> name,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaEntriesTableFilterComposer
    extends Composer<_$FlagKitDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaEntriesTableOrderingComposer
    extends Composer<_$FlagKitDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaEntriesTableAnnotationComposer
    extends Composer<_$FlagKitDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaEntriesTableTableManager
    extends
        RootTableManager<
          _$FlagKitDatabase,
          $MetaEntriesTable,
          MetaRow,
          $$MetaEntriesTableFilterComposer,
          $$MetaEntriesTableOrderingComposer,
          $$MetaEntriesTableAnnotationComposer,
          $$MetaEntriesTableCreateCompanionBuilder,
          $$MetaEntriesTableUpdateCompanionBuilder,
          (
            MetaRow,
            BaseReferences<_$FlagKitDatabase, $MetaEntriesTable, MetaRow>,
          ),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaEntriesTableTableManager(_$FlagKitDatabase db, $MetaEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaEntriesCompanion(name: name, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaEntriesCompanion.insert(
                name: name,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaEntriesTable, MetaRow>(table),
                  BaseReferences<_$FlagKitDatabase, $MetaEntriesTable, MetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FlagKitDatabase,
      $MetaEntriesTable,
      MetaRow,
      $$MetaEntriesTableFilterComposer,
      $$MetaEntriesTableOrderingComposer,
      $$MetaEntriesTableAnnotationComposer,
      $$MetaEntriesTableCreateCompanionBuilder,
      $$MetaEntriesTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$FlagKitDatabase, $MetaEntriesTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;

class $FlagKitDatabaseManager {
  final _$FlagKitDatabase _db;
  $FlagKitDatabaseManager(this._db);
  $$FlagsTableTableManager get flags =>
      $$FlagsTableTableManager(_db, _db.flags);
  $$MetaEntriesTableTableManager get metaEntries =>
      $$MetaEntriesTableTableManager(_db, _db.metaEntries);
}
