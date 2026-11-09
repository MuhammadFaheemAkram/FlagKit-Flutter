import 'package:flagkit/src/model/flag_type.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:flutter/foundation.dart';

/// A flag as the server defined it: what `FlagKit.debug.definitions`
/// lists, for a debug screen. Reads never need it: they return the
/// evaluated value.
@immutable
final class FeatureFlag {
  /// A definition.
  FeatureFlag({
    required this.key,
    required this.value,
    required this.offValue,
    required this.enabled,
    required this.updatedAt,
    this.rolloutPercent,
    List<TargetingRule> rules = const [],
  }) : rules = List.unmodifiable(rules);

  /// The flag's key.
  final String key;

  /// Served when the flag applies to the user.
  final FlagValue value;

  /// Served when it doesn't: switched off, the rules missed, outside the
  /// rollout.
  final FlagValue offValue;

  /// The kill switch: off, every user gets [offValue].
  final bool enabled;

  /// The share of eligible users who get [value] (0–100), or `null` for
  /// all of them.
  final double? rolloutPercent;

  /// Who is eligible: every rule must match. Empty: everyone.
  final List<TargetingRule> rules;

  /// When the server last changed it (UTC).
  final DateTime updatedAt;

  /// The flag's type: its [value]'s.
  FlagType get type => value.type;

  @override
  bool operator ==(Object other) =>
      other is FeatureFlag &&
      other.key == key &&
      other.value == value &&
      other.offValue == offValue &&
      other.enabled == enabled &&
      other.rolloutPercent == rolloutPercent &&
      listEquals(other.rules, rules) &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    key,
    value,
    offValue,
    enabled,
    rolloutPercent,
    Object.hashAll(rules),
    updatedAt,
  );

  @override
  String toString() =>
      'FeatureFlag($key: $value / $offValue, '
      '${enabled ? 'on' : 'off'}'
      '${rolloutPercent == null ? '' : ', $rolloutPercent %'}'
      '${rules.isEmpty ? '' : ', rules $rules'})';
}
