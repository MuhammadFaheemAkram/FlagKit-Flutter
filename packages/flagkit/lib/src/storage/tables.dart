import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

// The SDK's tables, in its own database file (never the host's). They store
// rows and know nothing of the public models: the mapper turns a row into a
// `FlagDefinition`. The `CHECK`s are the last line of defence: a bug that
// slips past validation fails loudly at the write, instead of storing a
// definition every later read would have to work around.
//
// Instants are UTC ISO-8601 text (conventions §11.14): each one must end in
// `Z`. Values are JSON text: the same shape the server sends.
//
// The constraints are written out as literals: drift_dev checks only those.

/// The cached definitions: one row per flag the server sent.
///
/// The columns are the definition's final shape (the rollout and the
/// rules too, which the SDK evaluates from 0.4.0), so adding targeting
/// needs no migration of this table.
@internal
@DataClassName('FlagRow')
class Flags extends Table {
  TextColumn get key => text()();

  TextColumn get type => text()();

  /// The value served when the flag applies, as JSON.
  TextColumn get value => text()();

  /// The value served when it doesn't (switched off, a rule missed, outside
  /// the rollout), as JSON.
  TextColumn get offValue => text()();

  BoolColumn get enabled => boolean()();

  /// The rollout in basis points (0–10000: 12.5 % is 1250), or `null` for
  /// everyone.
  IntColumn get rolloutBp => integer().nullable()();

  /// The targeting rules, as a JSON array.
  TextColumn get rules => text().withDefault(const Constant('[]'))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  List<String> get customConstraints => [
    'CHECK (length(key) BETWEEN 1 AND 64)',
    "CHECK (type IN ('boolean', 'string', 'int', 'double', 'json'))",
    'CHECK (json_valid(value))',
    'CHECK (json_valid(off_value))',
    'CHECK (rollout_bp IS NULL OR rollout_bp BETWEEN 0 AND 10000)',
    "CHECK (json_type(rules) = 'array')",
    "CHECK (updated_at GLOB '*Z')",
  ];
}

/// Named strings: the anonymous id, when the flags were fetched, the
/// server's config version.
@internal
@DataClassName('MetaRow')
class MetaEntries extends Table {
  @override
  String get tableName => 'meta';

  TextColumn get name => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
