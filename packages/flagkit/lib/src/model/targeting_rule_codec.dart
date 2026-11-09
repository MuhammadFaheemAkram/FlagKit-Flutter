import 'package:flagkit/src/model/targeting_rule.dart';
import 'package:meta/meta.dart';

/// [json] (a JSON list of rules) as rules, or `null` if it isn't one.
///
/// Each rule needs an `attribute` (a non-blank string), an `operator` (a
/// string: an unknown one is kept as [TargetingOperator.unknown], so it
/// never matches) and `values` (a non-empty list of strings, finite numbers
/// or booleans). One bad rule makes the whole list unreadable: a flag with
/// rules half-understood would be served to the wrong people.
@internal
List<TargetingRule>? rulesFromJson(Object? json) {
  if (json == null) return const [];
  if (json is! List<Object?>) return null;
  final rules = <TargetingRule>[];
  for (final entry in json) {
    if (entry is! Map<String, Object?>) return null;
    final (attribute, operator, values) = (
      entry['attribute'],
      entry['operator'],
      entry['values'],
    );
    if (attribute is! String || attribute.trim().isEmpty) return null;
    if (operator is! String) return null;
    if (values is! List<Object?> || values.isEmpty) return null;
    final checked = <Object>[];
    for (final value in values) {
      switch (value) {
        case String() || bool():
          checked.add(value!);
        case final num n when n.isFinite:
          checked.add(n);
        default:
          return null;
      }
    }
    rules.add(
      TargetingRule(
        attribute: attribute,
        operator: TargetingOperator.fromWireName(operator),
        operatorName: operator,
        values: checked,
      ),
    );
  }
  return rules;
}
