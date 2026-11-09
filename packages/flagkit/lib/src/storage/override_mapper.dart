import 'dart:convert';

import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/flag_value_codec.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:meta/meta.dart';

/// An override row as its value, or `null` if it can't be read (a type
/// this version doesn't know): skipped, never fatal.
@internal
extension OverrideRowMapper on OverrideRow {
  FlagValue? toValue() {
    final flagType = FlagType.fromWireName(type);
    if (flagType == null) return null;
    try {
      return flagValueFromJson(flagType, jsonDecode(value));
    } on FormatException {
      return null;
    }
  }
}

/// [value], overriding [key] since [createdAt], as a row.
@internal
OverrideRow overrideRow(String key, FlagValue value, DateTime createdAt) =>
    OverrideRow(
      key: key,
      type: value.type.wireName,
      value: jsonEncode(value.toJson()),
      createdAt: createdAt.toUtc(),
    );
