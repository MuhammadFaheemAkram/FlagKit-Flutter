import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/feature_flag.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:flutter/foundation.dart';

/// Everything behind one read, for a debug screen's detail view:
/// `FlagKit.debug.explain(key)`.
@immutable
final class FlagExplanation {
  /// An explanation.
  FlagExplanation({
    required this.detail,
    required this.context,
    this.flag,
    this.overrideValue,
    List<RuleMatch> rules = const [],
  }) : rules = List.unmodifiable(rules);

  /// The read's answer, as `FlagKit.detail` gives it.
  final FlagDetail detail;

  /// Who it was evaluated for.
  final EvaluationContext context;

  /// The server's definition, if the SDK has one.
  final FeatureFlag? flag;

  /// The local override, if one is set: it wins over [flag].
  final FlagValue? overrideValue;

  /// Each of the flag's rules, and whether [context] matches it.
  final List<RuleMatch> rules;

  @override
  bool operator ==(Object other) =>
      other is FlagExplanation &&
      other.detail == detail &&
      other.context == context &&
      other.flag == flag &&
      other.overrideValue == overrideValue &&
      listEquals(other.rules, rules);

  @override
  int get hashCode =>
      Object.hash(detail, context, flag, overrideValue, Object.hashAll(rules));

  @override
  String toString() => 'FlagExplanation($detail, rules $rules)';
}

/// One targeting rule, and whether a context matches it.
@immutable
final class RuleMatch {
  /// A rule's result.
  const RuleMatch(this.rule, {required this.matched});

  /// The rule.
  final TargetingRule rule;

  /// Whether the context matches it.
  final bool matched;

  @override
  bool operator ==(Object other) =>
      other is RuleMatch && other.rule == rule && other.matched == matched;

  @override
  int get hashCode => Object.hash(rule, matched);

  @override
  String toString() => '$rule: ${matched ? 'matches' : 'no match'}';
}
