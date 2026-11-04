import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/util/json.dart';
import 'package:meta/meta.dart';

/// A flag's value, typed.
///
/// The native editions keep every value as a `String` and parse it at each
/// read. Here a value is parsed once, when a definition arrives, so a read
/// only picks the right case: no parsing, no failure, on the hot path.
/// Sealed, so a `switch` over the cases is exhaustive.
@immutable
sealed class FlagValue {
  const FlagValue();

  /// The type of this value.
  FlagType get type;

  /// The value as JSON: what the server sends and the cache stores.
  Object toJson();
}

/// A `bool` flag value.
final class BoolValue extends FlagValue {
  /// A `bool` flag value.
  const BoolValue(this.value);

  /// The value.
  final bool value;

  @override
  FlagType get type => FlagType.boolean;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) => other is BoolValue && other.value == value;

  @override
  int get hashCode => Object.hash(BoolValue, value);

  @override
  String toString() => '$value';
}

/// A `String` flag value.
final class StringValue extends FlagValue {
  /// A `String` flag value.
  const StringValue(this.value);

  /// The value.
  final String value;

  @override
  FlagType get type => FlagType.string;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      other is StringValue && other.value == value;

  @override
  int get hashCode => Object.hash(StringValue, value);

  @override
  String toString() => '"$value"';
}

/// An `int` flag value.
final class IntValue extends FlagValue {
  /// An `int` flag value.
  const IntValue(this.value);

  /// The value.
  final int value;

  @override
  FlagType get type => FlagType.integer;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) => other is IntValue && other.value == value;

  @override
  int get hashCode => Object.hash(IntValue, value);

  @override
  String toString() => '$value';
}

/// A `double` flag value: always finite (JSON has no NaN or infinity).
final class DoubleValue extends FlagValue {
  /// A `double` flag value; [value] must be finite.
  const DoubleValue(this.value)
    : assert(
        value == value &&
            value != double.infinity &&
            value != double.negativeInfinity,
        'a finite double',
      );

  /// The value.
  final double value;

  @override
  FlagType get type => FlagType.decimal;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      other is DoubleValue && other.value == value;

  @override
  int get hashCode => Object.hash(DoubleValue, value);

  @override
  String toString() => '$value';
}

/// A JSON object flag value: several settings that change together.
final class JsonValue extends FlagValue {
  /// A JSON object flag value.
  ///
  /// The map is copied, deeply and unmodifiably: every read shares it, so
  /// no caller can change it for the others. Throws an [ArgumentError] if
  /// it holds anything JSON can't carry.
  JsonValue(Map<String, Object?> value)
    : value = freezeJson(value)! as Map<String, Object?>;

  /// The value: unmodifiable, at every depth.
  final Map<String, Object?> value;

  @override
  FlagType get type => FlagType.json;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      other is JsonValue && jsonEquals(other.value, value);

  @override
  int get hashCode => Object.hash(JsonValue, jsonHash(value));

  @override
  String toString() => '$value';
}
