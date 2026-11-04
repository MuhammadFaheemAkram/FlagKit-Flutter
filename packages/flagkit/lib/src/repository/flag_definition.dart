import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:meta/meta.dart';

/// A flag as the server defines it: what to serve, and when.
///
/// The server sends definitions, not answers: the device evaluates them,
/// so targeting and rollouts work offline and a context change needs no
/// request. Every flag has two values: [value] when it applies, [offValue]
/// when it doesn't. A string flag can then be "modern" for some users and
/// "classic" for the rest, which a single value and the caller's default
/// couldn't express.
@internal
@immutable
final class FlagDefinition {
  FlagDefinition({
    required this.key,
    required this.value,
    required this.offValue,
    required this.enabled,
    required this.updatedAt,
  }) : assert(value.type == offValue.type, 'both values have one type');

  final String key;

  /// Served when the flag applies.
  final FlagValue value;

  /// Served when it doesn't: switched off (or, from 0.4.0, a rule missed or
  /// the rollout excluded the user).
  final FlagValue offValue;

  /// The kill switch: `false` serves [offValue] whatever else applies.
  final bool enabled;

  /// When this definition was stored.
  final DateTime updatedAt;

  FlagType get type => value.type;

  /// Whether [other] defines the flag the same way (whenever it was
  /// stored): a refresh that brings the same definition changes nothing.
  bool sameAs(FlagDefinition other) =>
      other.key == key &&
      other.value == value &&
      other.offValue == offValue &&
      other.enabled == enabled;

  @override
  bool operator ==(Object other) =>
      other is FlagDefinition && sameAs(other) && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(key, value, offValue, enabled, updatedAt);

  @override
  String toString() =>
      'FlagDefinition($key: $value / off $offValue, '
      '${enabled ? 'on' : 'off'})';
}
