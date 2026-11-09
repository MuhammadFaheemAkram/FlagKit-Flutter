import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/evaluation/targeting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool matches(
    String attribute,
    TargetingOperator operator,
    List<Object> values,
    EvaluationContext context,
  ) => matchesRule(
    TargetingRule(attribute: attribute, operator: operator, values: values),
    context,
  );

  const pakistani = EvaluationContext(
    userId: 'user_125',
    country: 'PK',
    appVersion: '2.10.0',
    attributes: {'plan': 'pro', 'age': 30, 'beta': true},
  );
  const nobody = EvaluationContext();

  group('every operator', () {
    for (final (operator, attribute, values, yes, no) in [
      (TargetingOperator.equals, 'country', ['PK'], true, ['AE']),
      (TargetingOperator.notEquals, 'country', ['AE'], true, ['PK']),
      (TargetingOperator.isIn, 'country', ['AE', 'PK'], true, ['AE', 'GB']),
      (TargetingOperator.notIn, 'country', ['AE', 'GB'], true, ['PK']),
      (TargetingOperator.startsWith, 'userId', ['user_'], true, ['admin_']),
      (TargetingOperator.endsWith, 'userId', ['5'], true, ['4']),
      (TargetingOperator.contains, 'userId', ['_12'], true, ['_13']),
      (TargetingOperator.greaterThan, 'age', [18], true, [30]),
      (TargetingOperator.lessThan, 'age', [31], true, [30]),
      (
        TargetingOperator.semverAtLeast,
        'appVersion',
        ['2.9.0'],
        true,
        ['2.11'],
      ),
      (
        TargetingOperator.semverBelow,
        'appVersion',
        ['2.11.0'],
        true,
        ['2.10.0'],
      ),
    ]) {
      test(operator.wireName, () {
        expect(matches(attribute, operator, values, pakistani), yes);
        expect(matches(attribute, operator, no, pakistani), isFalse);
      });
    }

    test('semverAtLeast includes the version itself', () {
      expect(
        matches('appVersion', TargetingOperator.semverAtLeast, [
          '2.10',
        ], pakistani),
        isTrue,
      );
    });

    test('equals on numbers and booleans', () {
      expect(
        matches('age', TargetingOperator.equals, [30.0], pakistani),
        isTrue,
      );
      expect(
        matches('beta', TargetingOperator.equals, [true], pakistani),
        isTrue,
      );
      expect(
        matches('plan', TargetingOperator.isIn, ['free', 'pro'], pakistani),
        isTrue,
      );
    });
  });

  test('a missing attribute never matches, whatever the operator', () {
    for (final operator in TargetingOperator.values) {
      for (final attribute in ['country', 'userId', 'appVersion', 'plan']) {
        expect(
          matches(attribute, operator, ['PK', '2.0.0'], nobody),
          isFalse,
          reason: '$attribute ${operator.wireName}',
        );
      }
    }
  });

  test('notEquals and notIn need a value of the same kind', () {
    expect(
      matches('age', TargetingOperator.notEquals, ['thirty'], pakistani),
      isFalse,
    );
    expect(
      matches('age', TargetingOperator.notIn, [18, 'thirty'], pakistani),
      isFalse,
    );
    expect(
      matches('age', TargetingOperator.notIn, [18, 21], pakistani),
      isTrue,
    );
  });

  test('a value of another kind never matches', () {
    expect(matches('age', TargetingOperator.equals, ['30'], pakistani), false);
    expect(
      matches('country', TargetingOperator.greaterThan, [1], pakistani),
      false,
    );
    expect(
      matches('age', TargetingOperator.startsWith, ['3'], pakistani),
      false,
    );
    expect(
      matches('age', TargetingOperator.semverAtLeast, ['1'], pakistani),
      false,
    );
    expect(
      matches('appVersion', TargetingOperator.semverAtLeast, [2], pakistani),
      isFalse,
    );
  });

  test('a version that isn\'t one never matches', () {
    for (final operator in [
      TargetingOperator.semverAtLeast,
      TargetingOperator.semverBelow,
    ]) {
      expect(
        matches('appVersion', operator, [
          '2.0.0',
        ], const EvaluationContext(appVersion: '2.0.0-beta')),
        isFalse,
      );
      expect(matches('appVersion', operator, ['latest'], pakistani), isFalse);
    }
  });

  test('countries compare without regard to case; other text with it', () {
    expect(
      matches('country', TargetingOperator.isIn, ['pk'], pakistani),
      isTrue,
    );
    expect(
      matches('country', TargetingOperator.notEquals, ['pk'], pakistani),
      isFalse,
    );
    expect(
      matches('plan', TargetingOperator.equals, ['PRO'], pakistani),
      isFalse,
    );
  });

  test('an unknown operator never matches (fail closed)', () {
    final rule = TargetingRule(
      attribute: 'country',
      operator: TargetingOperator.unknown,
      operatorName: 'regex',
      values: const ['.*'],
    );
    expect(matchesRule(rule, pakistani), isFalse);
  });

  test('no values never match', () {
    expect(matches('country', TargetingOperator.notIn, [], pakistani), false);
  });

  test('matchesAll: every rule (none is everyone)', () {
    final inPakistan = TargetingRule(
      attribute: 'country',
      operator: TargetingOperator.equals,
      values: const ['PK'],
    );
    final pro = TargetingRule(
      attribute: 'plan',
      operator: TargetingOperator.equals,
      values: const ['free'],
    );
    expect(matchesAll(const [], nobody), isTrue);
    expect(matchesAll([inPakistan], pakistani), isTrue);
    expect(matchesAll([inPakistan, pro], pakistani), isFalse);
  });
}
