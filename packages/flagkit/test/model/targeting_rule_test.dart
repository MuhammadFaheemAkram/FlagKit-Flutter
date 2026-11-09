import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/model/targeting_rule_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('operators by their wire names; an unknown one is unknown', () {
    for (final operator in TargetingOperator.values) {
      if (operator == TargetingOperator.unknown) continue;
      expect(TargetingOperator.fromWireName(operator.wireName), operator);
    }
    expect(TargetingOperator.fromWireName('in'), TargetingOperator.isIn);
    expect(TargetingOperator.fromWireName('regex'), TargetingOperator.unknown);
    expect(
      TargetingOperator.fromWireName('unknown'),
      TargetingOperator.unknown,
    );
  });

  test('a rule round-trips through JSON, an unknown operator by name', () {
    final rules = rulesFromJson([
      {
        'attribute': 'country',
        'operator': 'in',
        'values': ['PK', 'AE'],
      },
      {
        'attribute': 'score',
        'operator': 'regex',
        'values': [1, 2.5, true],
      },
    ])!;

    expect(rules, hasLength(2));
    expect(rules.first.operator, TargetingOperator.isIn);
    expect(rules.last.operator, TargetingOperator.unknown);
    expect(rules.last.operatorName, 'regex');
    expect(rulesFromJson([for (final r in rules) r.toJson()]), rules);
    expect(rules.first.toString(), 'country in [PK, AE]');
  });

  test('no rules is none; anything unreadable is null', () {
    expect(rulesFromJson(null), isEmpty);
    expect(rulesFromJson(const <Object?>[]), isEmpty);
    for (final bad in <Object?>[
      'country in PK',
      ['rule'],
      [
        {
          'operator': 'in',
          'values': ['PK'],
        },
      ],
      [
        {
          'attribute': ' ',
          'operator': 'in',
          'values': ['PK'],
        },
      ],
      [
        {
          'attribute': 'country',
          'values': ['PK'],
        },
      ],
      [
        {
          'attribute': 'country',
          'operator': 3,
          'values': ['PK'],
        },
      ],
      [
        {'attribute': 'country', 'operator': 'in', 'values': <Object?>[]},
      ],
      [
        {'attribute': 'country', 'operator': 'in', 'values': 'PK'},
      ],
      [
        {
          'attribute': 'country',
          'operator': 'in',
          'values': [null],
        },
      ],
      [
        {
          'attribute': 'age',
          'operator': 'in',
          'values': [double.nan],
        },
      ],
      [
        {
          'attribute': 'age',
          'operator': 'in',
          'values': [<String, Object?>{}],
        },
      ],
    ]) {
      expect(rulesFromJson(bad), isNull, reason: '$bad');
    }
  });

  test('values are read-only; equality is by content', () {
    final countries = <Object>['PK'];
    final rule = TargetingRule(
      attribute: 'country',
      operator: TargetingOperator.isIn,
      values: countries,
    );
    countries.add('AE');
    expect(rule.values, ['PK'], reason: 'a copy');
    expect(() => rule.values.add('AE'), throwsUnsupportedError);
    final same = TargetingRule(
      attribute: 'country',
      operator: TargetingOperator.isIn,
      values: const ['PK'],
    );
    expect(rule, same);
    expect(rule.hashCode, same.hashCode);
    expect(
      rule,
      isNot(
        TargetingRule(
          attribute: 'country',
          operator: TargetingOperator.notIn,
          values: const ['PK'],
        ),
      ),
    );
  });
}
