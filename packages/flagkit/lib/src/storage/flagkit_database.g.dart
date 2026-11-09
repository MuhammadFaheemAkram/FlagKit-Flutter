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

class $RefreshesTable extends Refreshes
    with TableInfo<$RefreshesTable, RefreshRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefreshesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedMeta = const VerificationMeta('added');
  @override
  late final GeneratedColumn<int> added = GeneratedColumn<int>(
    'added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _changedMeta = const VerificationMeta(
    'changed',
  );
  @override
  late final GeneratedColumn<int> changed = GeneratedColumn<int>(
    'changed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _removedMeta = const VerificationMeta(
    'removed',
  );
  @override
  late final GeneratedColumn<int> removed = GeneratedColumn<int>(
    'removed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<int> skipped = GeneratedColumn<int>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _configVersionMeta = const VerificationMeta(
    'configVersion',
  );
  @override
  late final GeneratedColumn<int> configVersion = GeneratedColumn<int>(
    'config_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trigger,
    startedAt,
    finishedAt,
    outcome,
    added,
    changed,
    removed,
    skipped,
    configVersion,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refreshes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefreshRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('added')) {
      context.handle(
        _addedMeta,
        added.isAcceptableOrUnknown(data['added']!, _addedMeta),
      );
    }
    if (data.containsKey('changed')) {
      context.handle(
        _changedMeta,
        changed.isAcceptableOrUnknown(data['changed']!, _changedMeta),
      );
    }
    if (data.containsKey('removed')) {
      context.handle(
        _removedMeta,
        removed.isAcceptableOrUnknown(data['removed']!, _removedMeta),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    if (data.containsKey('config_version')) {
      context.handle(
        _configVersionMeta,
        configVersion.isAcceptableOrUnknown(
          data['config_version']!,
          _configVersionMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefreshRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefreshRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      added: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added'],
      )!,
      changed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}changed'],
      )!,
      removed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}removed'],
      )!,
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped'],
      )!,
      configVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}config_version'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $RefreshesTable createAlias(String alias) {
    return $RefreshesTable(attachedDatabase, alias);
  }
}

class RefreshRow extends DataClass implements Insertable<RefreshRow> {
  final int id;
  final String trigger;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String outcome;
  final int added;
  final int changed;
  final int removed;
  final int skipped;
  final int? configVersion;
  final String? error;
  const RefreshRow({
    required this.id,
    required this.trigger,
    required this.startedAt,
    required this.finishedAt,
    required this.outcome,
    required this.added,
    required this.changed,
    required this.removed,
    required this.skipped,
    this.configVersion,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trigger'] = Variable<String>(trigger);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['finished_at'] = Variable<DateTime>(finishedAt);
    map['outcome'] = Variable<String>(outcome);
    map['added'] = Variable<int>(added);
    map['changed'] = Variable<int>(changed);
    map['removed'] = Variable<int>(removed);
    map['skipped'] = Variable<int>(skipped);
    if (!nullToAbsent || configVersion != null) {
      map['config_version'] = Variable<int>(configVersion);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  RefreshesCompanion toCompanion(bool nullToAbsent) {
    return RefreshesCompanion(
      id: Value(id),
      trigger: Value(trigger),
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      outcome: Value(outcome),
      added: Value(added),
      changed: Value(changed),
      removed: Value(removed),
      skipped: Value(skipped),
      configVersion: configVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(configVersion),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory RefreshRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefreshRow(
      id: serializer.fromJson<int>(json['id']),
      trigger: serializer.fromJson<String>(json['trigger']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime>(json['finishedAt']),
      outcome: serializer.fromJson<String>(json['outcome']),
      added: serializer.fromJson<int>(json['added']),
      changed: serializer.fromJson<int>(json['changed']),
      removed: serializer.fromJson<int>(json['removed']),
      skipped: serializer.fromJson<int>(json['skipped']),
      configVersion: serializer.fromJson<int?>(json['configVersion']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trigger': serializer.toJson<String>(trigger),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime>(finishedAt),
      'outcome': serializer.toJson<String>(outcome),
      'added': serializer.toJson<int>(added),
      'changed': serializer.toJson<int>(changed),
      'removed': serializer.toJson<int>(removed),
      'skipped': serializer.toJson<int>(skipped),
      'configVersion': serializer.toJson<int?>(configVersion),
      'error': serializer.toJson<String?>(error),
    };
  }

  RefreshRow copyWith({
    int? id,
    String? trigger,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? outcome,
    int? added,
    int? changed,
    int? removed,
    int? skipped,
    Value<int?> configVersion = const Value.absent(),
    Value<String?> error = const Value.absent(),
  }) => RefreshRow(
    id: id ?? this.id,
    trigger: trigger ?? this.trigger,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    outcome: outcome ?? this.outcome,
    added: added ?? this.added,
    changed: changed ?? this.changed,
    removed: removed ?? this.removed,
    skipped: skipped ?? this.skipped,
    configVersion: configVersion.present
        ? configVersion.value
        : this.configVersion,
    error: error.present ? error.value : this.error,
  );
  RefreshRow copyWithCompanion(RefreshesCompanion data) {
    return RefreshRow(
      id: data.id.present ? data.id.value : this.id,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      added: data.added.present ? data.added.value : this.added,
      changed: data.changed.present ? data.changed.value : this.changed,
      removed: data.removed.present ? data.removed.value : this.removed,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
      configVersion: data.configVersion.present
          ? data.configVersion.value
          : this.configVersion,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefreshRow(')
          ..write('id: $id, ')
          ..write('trigger: $trigger, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('outcome: $outcome, ')
          ..write('added: $added, ')
          ..write('changed: $changed, ')
          ..write('removed: $removed, ')
          ..write('skipped: $skipped, ')
          ..write('configVersion: $configVersion, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trigger,
    startedAt,
    finishedAt,
    outcome,
    added,
    changed,
    removed,
    skipped,
    configVersion,
    error,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefreshRow &&
          other.id == this.id &&
          other.trigger == this.trigger &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.outcome == this.outcome &&
          other.added == this.added &&
          other.changed == this.changed &&
          other.removed == this.removed &&
          other.skipped == this.skipped &&
          other.configVersion == this.configVersion &&
          other.error == this.error);
}

class RefreshesCompanion extends UpdateCompanion<RefreshRow> {
  final Value<int> id;
  final Value<String> trigger;
  final Value<DateTime> startedAt;
  final Value<DateTime> finishedAt;
  final Value<String> outcome;
  final Value<int> added;
  final Value<int> changed;
  final Value<int> removed;
  final Value<int> skipped;
  final Value<int?> configVersion;
  final Value<String?> error;
  const RefreshesCompanion({
    this.id = const Value.absent(),
    this.trigger = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.added = const Value.absent(),
    this.changed = const Value.absent(),
    this.removed = const Value.absent(),
    this.skipped = const Value.absent(),
    this.configVersion = const Value.absent(),
    this.error = const Value.absent(),
  });
  RefreshesCompanion.insert({
    this.id = const Value.absent(),
    required String trigger,
    required DateTime startedAt,
    required DateTime finishedAt,
    required String outcome,
    this.added = const Value.absent(),
    this.changed = const Value.absent(),
    this.removed = const Value.absent(),
    this.skipped = const Value.absent(),
    this.configVersion = const Value.absent(),
    this.error = const Value.absent(),
  }) : trigger = Value(trigger),
       startedAt = Value(startedAt),
       finishedAt = Value(finishedAt),
       outcome = Value(outcome);
  static Insertable<RefreshRow> custom({
    Expression<int>? id,
    Expression<String>? trigger,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? outcome,
    Expression<int>? added,
    Expression<int>? changed,
    Expression<int>? removed,
    Expression<int>? skipped,
    Expression<int>? configVersion,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trigger != null) 'trigger': trigger,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (outcome != null) 'outcome': outcome,
      if (added != null) 'added': added,
      if (changed != null) 'changed': changed,
      if (removed != null) 'removed': removed,
      if (skipped != null) 'skipped': skipped,
      if (configVersion != null) 'config_version': configVersion,
      if (error != null) 'error': error,
    });
  }

  RefreshesCompanion copyWith({
    Value<int>? id,
    Value<String>? trigger,
    Value<DateTime>? startedAt,
    Value<DateTime>? finishedAt,
    Value<String>? outcome,
    Value<int>? added,
    Value<int>? changed,
    Value<int>? removed,
    Value<int>? skipped,
    Value<int?>? configVersion,
    Value<String?>? error,
  }) {
    return RefreshesCompanion(
      id: id ?? this.id,
      trigger: trigger ?? this.trigger,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      outcome: outcome ?? this.outcome,
      added: added ?? this.added,
      changed: changed ?? this.changed,
      removed: removed ?? this.removed,
      skipped: skipped ?? this.skipped,
      configVersion: configVersion ?? this.configVersion,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (added.present) {
      map['added'] = Variable<int>(added.value);
    }
    if (changed.present) {
      map['changed'] = Variable<int>(changed.value);
    }
    if (removed.present) {
      map['removed'] = Variable<int>(removed.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<int>(skipped.value);
    }
    if (configVersion.present) {
      map['config_version'] = Variable<int>(configVersion.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefreshesCompanion(')
          ..write('id: $id, ')
          ..write('trigger: $trigger, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('outcome: $outcome, ')
          ..write('added: $added, ')
          ..write('changed: $changed, ')
          ..write('removed: $removed, ')
          ..write('skipped: $skipped, ')
          ..write('configVersion: $configVersion, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $OverridesTable extends Overrides
    with TableInfo<$OverridesTable, OverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OverridesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, type, value, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<OverrideRow> instance, {
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  OverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OverrideRow(
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
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OverridesTable createAlias(String alias) {
    return $OverridesTable(attachedDatabase, alias);
  }
}

class OverrideRow extends DataClass implements Insertable<OverrideRow> {
  final String key;
  final String type;

  /// The value, as JSON.
  final String value;
  final DateTime createdAt;
  const OverrideRow({
    required this.key,
    required this.type,
    required this.value,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OverridesCompanion toCompanion(bool nullToAbsent) {
    return OverridesCompanion(
      key: Value(key),
      type: Value(type),
      value: Value(value),
      createdAt: Value(createdAt),
    );
  }

  factory OverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OverrideRow(
      key: serializer.fromJson<String>(json['key']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OverrideRow copyWith({
    String? key,
    String? type,
    String? value,
    DateTime? createdAt,
  }) => OverrideRow(
    key: key ?? this.key,
    type: type ?? this.type,
    value: value ?? this.value,
    createdAt: createdAt ?? this.createdAt,
  );
  OverrideRow copyWithCompanion(OverridesCompanion data) {
    return OverrideRow(
      key: data.key.present ? data.key.value : this.key,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OverrideRow(')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, type, value, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OverrideRow &&
          other.key == this.key &&
          other.type == this.type &&
          other.value == this.value &&
          other.createdAt == this.createdAt);
}

class OverridesCompanion extends UpdateCompanion<OverrideRow> {
  final Value<String> key;
  final Value<String> type;
  final Value<String> value;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OverridesCompanion({
    this.key = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OverridesCompanion.insert({
    required String key,
    required String type,
    required String value,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       type = Value(type),
       value = Value(value),
       createdAt = Value(createdAt);
  static Insertable<OverrideRow> custom({
    Expression<String>? key,
    Expression<String>? type,
    Expression<String>? value,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OverridesCompanion copyWith({
    Value<String>? key,
    Value<String>? type,
    Value<String>? value,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OverridesCompanion(
      key: key ?? this.key,
      type: type ?? this.type,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OverridesCompanion(')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt, ')
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
  late final $RefreshesTable refreshes = $RefreshesTable(this);
  late final $OverridesTable overrides = $OverridesTable(this);
  late final FlagDao flagDao = FlagDao(this as FlagKitDatabase);
  late final MetaDao metaDao = MetaDao(this as FlagKitDatabase);
  late final RefreshDao refreshDao = RefreshDao(this as FlagKitDatabase);
  late final OverrideDao overrideDao = OverrideDao(this as FlagKitDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    flags,
    metaEntries,
    refreshes,
    overrides,
  ];
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
typedef $$RefreshesTableCreateCompanionBuilder = RefreshesCompanion Function({
  Value<int> id,
  required String trigger,
  required DateTime startedAt,
  required DateTime finishedAt,
  required String outcome,
  Value<int> added,
  Value<int> changed,
  Value<int> removed,
  Value<int> skipped,
  Value<int?> configVersion,
  Value<String?> error,
});
typedef $$RefreshesTableUpdateCompanionBuilder = RefreshesCompanion Function({
  Value<int> id,
  Value<String> trigger,
  Value<DateTime> startedAt,
  Value<DateTime> finishedAt,
  Value<String> outcome,
  Value<int> added,
  Value<int> changed,
  Value<int> removed,
  Value<int> skipped,
  Value<int?> configVersion,
  Value<String?> error,
});

class $$RefreshesTableFilterComposer
    extends Composer<_$FlagKitDatabase, $RefreshesTable> {
  $$RefreshesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changed => $composableBuilder(
    column: $table.changed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get removed => $composableBuilder(
    column: $table.removed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configVersion => $composableBuilder(
    column: $table.configVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RefreshesTableOrderingComposer
    extends Composer<_$FlagKitDatabase, $RefreshesTable> {
  $$RefreshesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changed => $composableBuilder(
    column: $table.changed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get removed => $composableBuilder(
    column: $table.removed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configVersion => $composableBuilder(
    column: $table.configVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RefreshesTableAnnotationComposer
    extends Composer<_$FlagKitDatabase, $RefreshesTable> {
  $$RefreshesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get added =>
      $composableBuilder(column: $table.added, builder: (column) => column);

  GeneratedColumn<int> get changed =>
      $composableBuilder(column: $table.changed, builder: (column) => column);

  GeneratedColumn<int> get removed =>
      $composableBuilder(column: $table.removed, builder: (column) => column);

  GeneratedColumn<int> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  GeneratedColumn<int> get configVersion => $composableBuilder(
    column: $table.configVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$RefreshesTableTableManager
    extends
        RootTableManager<
          _$FlagKitDatabase,
          $RefreshesTable,
          RefreshRow,
          $$RefreshesTableFilterComposer,
          $$RefreshesTableOrderingComposer,
          $$RefreshesTableAnnotationComposer,
          $$RefreshesTableCreateCompanionBuilder,
          $$RefreshesTableUpdateCompanionBuilder,
          (
            RefreshRow,
            BaseReferences<_$FlagKitDatabase, $RefreshesTable, RefreshRow>,
          ),
          RefreshRow,
          PrefetchHooks Function()
        > {
  $$RefreshesTableTableManager(_$FlagKitDatabase db, $RefreshesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefreshesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefreshesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefreshesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> finishedAt = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int> added = const Value.absent(),
                Value<int> changed = const Value.absent(),
                Value<int> removed = const Value.absent(),
                Value<int> skipped = const Value.absent(),
                Value<int?> configVersion = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => RefreshesCompanion(
                id: id,
                trigger: trigger,
                startedAt: startedAt,
                finishedAt: finishedAt,
                outcome: outcome,
                added: added,
                changed: changed,
                removed: removed,
                skipped: skipped,
                configVersion: configVersion,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trigger,
                required DateTime startedAt,
                required DateTime finishedAt,
                required String outcome,
                Value<int> added = const Value.absent(),
                Value<int> changed = const Value.absent(),
                Value<int> removed = const Value.absent(),
                Value<int> skipped = const Value.absent(),
                Value<int?> configVersion = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => RefreshesCompanion.insert(
                id: id,
                trigger: trigger,
                startedAt: startedAt,
                finishedAt: finishedAt,
                outcome: outcome,
                added: added,
                changed: changed,
                removed: removed,
                skipped: skipped,
                configVersion: configVersion,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RefreshesTable, RefreshRow>(table),
                  BaseReferences<
                    _$FlagKitDatabase,
                    $RefreshesTable,
                    RefreshRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RefreshesTableProcessedTableManager =
    ProcessedTableManager<
      _$FlagKitDatabase,
      $RefreshesTable,
      RefreshRow,
      $$RefreshesTableFilterComposer,
      $$RefreshesTableOrderingComposer,
      $$RefreshesTableAnnotationComposer,
      $$RefreshesTableCreateCompanionBuilder,
      $$RefreshesTableUpdateCompanionBuilder,
      (
        RefreshRow,
        BaseReferences<_$FlagKitDatabase, $RefreshesTable, RefreshRow>,
      ),
      RefreshRow,
      PrefetchHooks Function()
    >;
typedef $$OverridesTableCreateCompanionBuilder = OverridesCompanion Function({
  required String key,
  required String type,
  required String value,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$OverridesTableUpdateCompanionBuilder = OverridesCompanion Function({
  Value<String> key,
  Value<String> type,
  Value<String> value,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$OverridesTableFilterComposer
    extends Composer<_$FlagKitDatabase, $OverridesTable> {
  $$OverridesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OverridesTableOrderingComposer
    extends Composer<_$FlagKitDatabase, $OverridesTable> {
  $$OverridesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OverridesTableAnnotationComposer
    extends Composer<_$FlagKitDatabase, $OverridesTable> {
  $$OverridesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OverridesTableTableManager
    extends
        RootTableManager<
          _$FlagKitDatabase,
          $OverridesTable,
          OverrideRow,
          $$OverridesTableFilterComposer,
          $$OverridesTableOrderingComposer,
          $$OverridesTableAnnotationComposer,
          $$OverridesTableCreateCompanionBuilder,
          $$OverridesTableUpdateCompanionBuilder,
          (
            OverrideRow,
            BaseReferences<_$FlagKitDatabase, $OverridesTable, OverrideRow>,
          ),
          OverrideRow,
          PrefetchHooks Function()
        > {
  $$OverridesTableTableManager(_$FlagKitDatabase db, $OverridesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OverridesCompanion(
                key: key,
                type: type,
                value: value,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String type,
                required String value,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OverridesCompanion.insert(
                key: key,
                type: type,
                value: value,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OverridesTable, OverrideRow>(table),
                  BaseReferences<
                    _$FlagKitDatabase,
                    $OverridesTable,
                    OverrideRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$FlagKitDatabase,
      $OverridesTable,
      OverrideRow,
      $$OverridesTableFilterComposer,
      $$OverridesTableOrderingComposer,
      $$OverridesTableAnnotationComposer,
      $$OverridesTableCreateCompanionBuilder,
      $$OverridesTableUpdateCompanionBuilder,
      (
        OverrideRow,
        BaseReferences<_$FlagKitDatabase, $OverridesTable, OverrideRow>,
      ),
      OverrideRow,
      PrefetchHooks Function()
    >;

class $FlagKitDatabaseManager {
  final _$FlagKitDatabase _db;
  $FlagKitDatabaseManager(this._db);
  $$FlagsTableTableManager get flags =>
      $$FlagsTableTableManager(_db, _db.flags);
  $$MetaEntriesTableTableManager get metaEntries =>
      $$MetaEntriesTableTableManager(_db, _db.metaEntries);
  $$RefreshesTableTableManager get refreshes =>
      $$RefreshesTableTableManager(_db, _db.refreshes);
  $$OverridesTableTableManager get overrides =>
      $$OverridesTableTableManager(_db, _db.overrides);
}
