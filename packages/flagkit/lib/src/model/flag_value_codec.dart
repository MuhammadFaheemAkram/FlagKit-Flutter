import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:meta/meta.dart';

/// The largest integer a JSON number carries exactly (2^53): beyond it, a
/// server's `int` may already have lost digits on the way.
const _maxSafeInteger = 9007199254740992;

/// [json] as a value of [type], or `null` if it isn't one.
///
/// The one conversion is the one JSON forces: a number. A server (or a
/// language without integers) may send `20.0` for an `int` flag, so an
/// integral, safe `double` is an `int`; an `int` is always a `double`.
/// Nothing else converts: `"30"` is not an `int`.
@internal
FlagValue? flagValueFromJson(FlagType type, Object? json) {
  switch (type) {
    case FlagType.boolean:
      return json is bool ? BoolValue(json) : null;
    case FlagType.string:
      return json is String ? StringValue(json) : null;
    case FlagType.integer:
      return switch (json) {
        final int value when value.abs() <= _maxSafeInteger => IntValue(value),
        final double value
            when value.isFinite &&
                value == value.truncateToDouble() &&
                value.abs() <= _maxSafeInteger =>
          IntValue(value.toInt()),
        _ => null,
      };
    case FlagType.decimal:
      return json is num && json.isFinite ? DoubleValue(json.toDouble()) : null;
    case FlagType.json:
      if (json is! Map<String, Object?>) return null;
      try {
        return JsonValue(json);
      } on ArgumentError {
        return null;
      }
  }
}
