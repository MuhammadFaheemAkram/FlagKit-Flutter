import 'dart:convert';

import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value_codec.dart';
import 'package:flagkit/src/model/targeting_rule_codec.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:meta/meta.dart';

/// A row as a definition, or `null` if it can't be read (a type this
/// version doesn't know, a value that isn't of its type): such a row is
/// skipped, never fatal.
@internal
extension FlagRowMapper on FlagRow {
  FlagDefinition? toDefinition() {
    final flagType = FlagType.fromWireName(type);
    if (flagType == null) return null;
    try {
      final value = flagValueFromJson(flagType, jsonDecode(this.value));
      final off = flagValueFromJson(flagType, jsonDecode(offValue));
      final rules = rulesFromJson(jsonDecode(this.rules));
      if (value == null || off == null || rules == null) return null;
      return FlagDefinition(
        key: key,
        value: value,
        offValue: off,
        enabled: enabled,
        updatedAt: updatedAt.toUtc(),
        rolloutBasisPoints: rolloutBp,
        rules: rules,
      );
    } on FormatException {
      return null;
    }
  }
}

/// A definition as a row.
@internal
extension FlagDefinitionMapper on FlagDefinition {
  FlagRow toRow() => FlagRow(
    key: key,
    type: type.wireName,
    value: jsonEncode(value.toJson()),
    offValue: jsonEncode(offValue.toJson()),
    enabled: enabled,
    rolloutBp: rolloutBasisPoints,
    rules: jsonEncode([for (final rule in rules) rule.toJson()]),
    updatedAt: updatedAt.toUtc(),
  );
}
