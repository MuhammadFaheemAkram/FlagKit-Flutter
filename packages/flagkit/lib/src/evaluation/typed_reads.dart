import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:meta/meta.dart';

/// The typed reads, written once over [evaluate].
///
/// Every read is the same two steps: evaluate the flag (for the type the
/// caller asked for), then take the value if it has that type, else the
/// caller's default. Nothing here can throw: a pattern that doesn't match
/// falls through to the default.
@internal
mixin TypedReads {
  /// Evaluates [key] for a read of [requested] (`null`: any type).
  FlagDetail evaluate(String key, FlagType? requested);

  /// Whether the boolean flag [key] is on; [defaultValue] if FlagKit has
  /// no boolean for it.
  bool isEnabled(String key, [bool defaultValue = false]) =>
      switch (evaluate(key, FlagType.boolean).value) {
        BoolValue(:final value) => value,
        _ => defaultValue,
      };

  /// The string flag [key]; [defaultValue] if FlagKit has no string for it.
  String getString(String key, String defaultValue) =>
      switch (evaluate(key, FlagType.string).value) {
        StringValue(:final value) => value,
        _ => defaultValue,
      };

  /// The integer flag [key]; [defaultValue] if FlagKit has no integer for
  /// it.
  int getInt(String key, int defaultValue) =>
      switch (evaluate(key, FlagType.integer).value) {
        IntValue(:final value) => value,
        _ => defaultValue,
      };

  /// The decimal flag [key] (an integer flag widens); [defaultValue] if
  /// FlagKit has no number for it.
  double getDouble(String key, double defaultValue) =>
      switch (evaluate(key, FlagType.decimal).value) {
        DoubleValue(:final value) => value,
        IntValue(:final value) => value.toDouble(),
        _ => defaultValue,
      };

  /// The JSON flag [key] (unmodifiable); [defaultValue] if FlagKit has no
  /// JSON object for it.
  Map<String, Object?> getJson(String key, Map<String, Object?> defaultValue) =>
      switch (evaluate(key, FlagType.json).value) {
        JsonValue(:final value) => value,
        _ => defaultValue,
      };

  /// The flag [key]'s value, whatever its type, or `null` if FlagKit
  /// doesn't know it.
  FlagValue? getValue(String key) => evaluate(key, null).value;

  /// The flag [key]'s value with where it came from and why.
  FlagDetail detail(String key) => evaluate(key, null);
}
