import 'package:flagkit/src/evaluation/semver.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:meta/meta.dart';

/// Whether [context] matches [rule]: pure, total, never throws.
///
/// - **A missing attribute never matches,** `notEquals` and `notIn`
///   included: "not in Pakistan" can't be said of a user whose country
///   isn't known.
/// - **Comparisons are typed:** strings as strings (a country's code
///   without regard to case), numbers as numbers, versions as versions,
///   booleans as booleans. A value of another kind never matches.
/// - **An unknown operator, or no values, never matches** (fail closed).
@internal
bool matchesRule(TargetingRule rule, EvaluationContext context) {
  final actual = context.valueOf(rule.attribute);
  if (actual == null || rule.values.isEmpty) return false;
  final caseless = rule.attribute == 'country';
  bool same(Object expected) => _equal(actual, expected, caseless: caseless);
  final first = rule.values.first;
  return switch (rule.operator) {
    TargetingOperator.equals => same(first),
    TargetingOperator.notEquals => _comparable(actual, first) && !same(first),
    TargetingOperator.isIn => rule.values.any(same),
    TargetingOperator.notIn =>
      rule.values.every((v) => _comparable(actual, v)) &&
          !rule.values.any(same),
    TargetingOperator.startsWith => _text(
      actual,
      first,
      (a, b) => a.startsWith(b),
    ),
    TargetingOperator.endsWith => _text(actual, first, (a, b) => a.endsWith(b)),
    TargetingOperator.contains => _text(actual, first, (a, b) => a.contains(b)),
    TargetingOperator.greaterThan => _number(actual, first, (a, b) => a > b),
    TargetingOperator.lessThan => _number(actual, first, (a, b) => a < b),
    TargetingOperator.semverAtLeast => _version(actual, first, (c) => c >= 0),
    TargetingOperator.semverBelow => _version(actual, first, (c) => c < 0),
    TargetingOperator.unknown => false,
  };
}

/// Whether [context] matches every one of [rules] (AND).
@internal
bool matchesAll(List<TargetingRule> rules, EvaluationContext context) =>
    rules.every((rule) => matchesRule(rule, context));

bool _equal(Object actual, Object expected, {required bool caseless}) =>
    switch ((actual, expected)) {
      (final String a, final String b) =>
        caseless ? a.toUpperCase() == b.toUpperCase() : a == b,
      (final num a, final num b) => a == b,
      (final bool a, final bool b) => a == b,
      _ => false,
    };

/// Whether [actual] and [expected] are of one kind: "not equal" is only
/// said of values that could have been equal.
bool _comparable(Object actual, Object expected) =>
    switch ((actual, expected)) {
      (String(), String()) || (num(), num()) || (bool(), bool()) => true,
      _ => false,
    };

bool _text(
  Object actual,
  Object expected,
  bool Function(String, String) test,
) => actual is String && expected is String && test(actual, expected);

bool _number(Object actual, Object expected, bool Function(num, num) test) =>
    actual is num && expected is num && test(actual, expected);

bool _version(Object actual, Object expected, bool Function(int) test) {
  if (actual is! String || expected is! String) return false;
  final (a, b) = (SemVer.tryParse(actual), SemVer.tryParse(expected));
  return a != null && b != null && test(a.compareTo(b));
}
