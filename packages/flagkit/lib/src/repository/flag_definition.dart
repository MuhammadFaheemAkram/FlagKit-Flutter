import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:flutter/foundation.dart';

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
    this.rolloutBasisPoints,
    List<TargetingRule> rules = const [],
  }) : rules = List.unmodifiable(rules),
       assert(value.type == offValue.type, 'both values have one type'),
       assert(
         rolloutBasisPoints == null ||
             (rolloutBasisPoints >= 0 && rolloutBasisPoints <= 10000),
         'a rollout is 0–10000 basis points',
       );

  final String key;

  /// Served when the flag applies.
  final FlagValue value;

  /// Served when it doesn't: switched off, a rule missed, or the rollout
  /// excluded the user.
  final FlagValue offValue;

  /// The kill switch: `false` serves [offValue] whatever else applies.
  final bool enabled;

  /// When this definition was stored.
  final DateTime updatedAt;

  /// The share of eligible users it applies to, in basis points (2500 is
  /// 25 %), or `null` for all of them.
  final int? rolloutBasisPoints;

  /// Who is eligible: every rule must match. Empty: everyone.
  final List<TargetingRule> rules;

  FlagType get type => value.type;

  /// Whether [other] defines the flag the same way (whenever it was
  /// stored): a refresh that brings the same definition changes nothing.
  bool sameAs(FlagDefinition other) =>
      other.key == key &&
      other.value == value &&
      other.offValue == offValue &&
      other.enabled == enabled &&
      other.rolloutBasisPoints == rolloutBasisPoints &&
      listEquals(other.rules, rules);

  @override
  bool operator ==(Object other) =>
      other is FlagDefinition && sameAs(other) && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    key,
    value,
    offValue,
    enabled,
    updatedAt,
    rolloutBasisPoints,
    Object.hashAll(rules),
  );

  @override
  String toString() =>
      'FlagDefinition($key: $value / off $offValue, '
      '${enabled ? 'on' : 'off'}'
      '${rolloutBasisPoints == null ? '' : ', rollout ${rolloutBasisPoints! / 100} %'}'
      '${rules.isEmpty ? '' : ', rules $rules'})';
}
