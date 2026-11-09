import 'package:flutter/foundation.dart';

/// How a rule compares a context's attribute with its values.
enum TargetingOperator {
  /// The attribute equals the value.
  equals('equals'),

  /// The attribute is known and differs from the value.
  notEquals('notEquals'),

  /// The attribute is one of the values.
  isIn('in'),

  /// The attribute is known and none of the values.
  notIn('notIn'),

  /// The attribute (text) starts with the value.
  startsWith('startsWith'),

  /// The attribute (text) ends with the value: `userId` ending in `5`.
  endsWith('endsWith'),

  /// The attribute (text) contains the value.
  contains('contains'),

  /// The attribute (a number) is greater than the value.
  greaterThan('greaterThan'),

  /// The attribute (a number) is less than the value.
  lessThan('lessThan'),

  /// The attribute (a version) is the value's version or later:
  /// `appVersion` 2.10.0 is at least 2.9.0.
  semverAtLeast('semverAtLeast'),

  /// The attribute (a version) is before the value's version.
  semverBelow('semverBelow'),

  /// An operator this SDK doesn't know (a newer server's): the rule never
  /// matches. Failing closed keeps the flag's off value for everyone,
  /// rather than guessing.
  unknown('unknown');

  const TargetingOperator(this.wireName);

  /// The operator's name in the server's JSON.
  final String wireName;

  /// The operator named [wireName], or [unknown].
  static TargetingOperator fromWireName(String wireName) => values.firstWhere(
    (operator) => operator.wireName == wireName && operator != unknown,
    orElse: () => unknown,
  );
}

/// One condition on who a flag applies to: an [attribute] of the
/// evaluation context, an [operator], and the [values] to compare with.
///
/// A flag's rules must **all** match. A context that doesn't have the
/// attribute never matches, whatever the operator: an unknown user isn't
/// "not in Pakistan", only unknown.
@immutable
final class TargetingRule {
  /// A rule; [values] are `String`, `num` or `bool`.
  TargetingRule({
    required this.attribute,
    required this.operator,
    required List<Object> values,
    String? operatorName,
  }) : values = List.unmodifiable(values),
       operatorName = operatorName ?? operator.wireName;

  /// The context attribute it looks at: `userId`, `country`, `appVersion`,
  /// or a custom one.
  final String attribute;

  /// How it compares.
  final TargetingOperator operator;

  /// The operator as the server named it (for an [TargetingOperator.unknown]
  /// one, its real name, for the logs and the debug screen).
  final String operatorName;

  /// What it compares with.
  final List<Object> values;

  /// The rule in the server's JSON.
  Map<String, Object?> toJson() => {
    'attribute': attribute,
    'operator': operatorName,
    'values': values,
  };

  @override
  bool operator ==(Object other) =>
      other is TargetingRule &&
      other.attribute == attribute &&
      other.operatorName == operatorName &&
      listEquals(other.values, values);

  @override
  int get hashCode =>
      Object.hash(attribute, operatorName, Object.hashAll(values));

  @override
  String toString() => '$attribute $operatorName $values';
}
