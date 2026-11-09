import 'package:flagkit/flagkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EvaluationContext', () {
    const context = EvaluationContext(
      userId: 'user_123',
      country: 'PK',
      appVersion: '2.1.0',
      attributes: {'plan': 'pro', 'beta': true},
    );

    test('a rule reads the fields and the attributes by name', () {
      expect(context.valueOf('userId'), 'user_123');
      expect(context.valueOf('country'), 'PK');
      expect(context.valueOf('appVersion'), '2.1.0');
      expect(context.valueOf('plan'), 'pro');
      expect(context.valueOf('beta'), true);
      expect(context.valueOf('cohort'), isNull);
      expect(const EvaluationContext().valueOf('userId'), isNull);
    });

    test('compares by value, attributes included', () {
      expect(
        context,
        const EvaluationContext(
          userId: 'user_123',
          country: 'PK',
          appVersion: '2.1.0',
          attributes: {'beta': true, 'plan': 'pro'},
        ),
      );
      expect(
        context.hashCode,
        const EvaluationContext(
          userId: 'user_123',
          country: 'PK',
          appVersion: '2.1.0',
          attributes: {'beta': true, 'plan': 'pro'},
        ).hashCode,
      );
      expect(
        context,
        isNot(
          const EvaluationContext(
            userId: 'user_123',
            country: 'PK',
            appVersion: '2.1.0',
            attributes: {'plan': 'free', 'beta': true},
          ),
        ),
      );
      expect(context, isNot(const EvaluationContext(userId: 'user_123')));
    });
  });

  group('FlagDetail', () {
    test('a fallback is the caller\'s default, for its reason', () {
      const detail = FlagDetail.fallback(
        'new_home_screen',
        EvaluationReason.flagNotFound,
      );

      expect(detail.value, isNull);
      expect(detail.source, FlagSource.defaultValue);
      expect(detail.isDefault, isTrue);
      expect(detail.toString(), contains('the default'));
    });

    test('compares by value', () {
      const a = FlagDetail(
        key: 'k',
        value: BoolValue(true),
        source: FlagSource.remote,
        reason: EvaluationReason.fallthrough,
      );

      expect(
        a,
        const FlagDetail(
          key: 'k',
          value: BoolValue(true),
          source: FlagSource.remote,
          reason: EvaluationReason.fallthrough,
        ),
      );
      expect(a.isDefault, isFalse);
      expect(
        a,
        isNot(
          const FlagDetail(
            key: 'k',
            value: BoolValue(true),
            source: FlagSource.cache,
            reason: EvaluationReason.fallthrough,
          ),
        ),
      );
    });

    test('a rollout\'s bucket and percentage are part of the value', () {
      FlagDetail rolledOut({int bucket = 404, double percent = 25}) =>
          FlagDetail(
            key: 'k',
            value: const BoolValue(true),
            source: FlagSource.remote,
            reason: EvaluationReason.rolloutIncluded,
            bucket: bucket,
            rolloutPercent: percent,
          );

      expect(rolledOut(), rolledOut());
      expect(rolledOut().hashCode, rolledOut().hashCode);
      expect(rolledOut(), isNot(rolledOut(bucket: 405)));
      expect(rolledOut(), isNot(rolledOut(percent: 50)));
    });
  });

  group('RefreshResult', () {
    test('compares by value', () {
      expect(
        const Updated(added: {'a', 'b'}, skipped: 1),
        const Updated(added: {'b', 'a'}, skipped: 1),
      );
      expect(
        const Updated(added: {'a'}).hashCode,
        const Updated(added: {'a'}).hashCode,
      );
      expect(const Updated(added: {'a'}), isNot(const Updated(changed: {'a'})));
      expect(const Updated(skipped: 1), isNot(const Updated(skipped: 2)));
      expect(const Failed(reason: 'x'), const Failed(reason: 'x'));
      expect(const Failed(reason: 'x'), isNot(const Failed(reason: 'y')));
      expect(const NotModified(), const NotModified());
      expect(const Offline(), isNot(const NotModified()));
      expect(const Unauthorized().hashCode, const Unauthorized().hashCode);
      expect(const NotInitialized(), const NotInitialized());
    });

    test('says what it is', () {
      for (final result in const <RefreshResult>[
        Updated(added: {'a'}),
        NotModified(),
        Offline(),
        Failed(reason: 'server error 503'),
        Unauthorized(),
        NotInitialized(),
      ]) {
        expect(result.toString(), isNot(startsWith('Instance of')));
      }
    });
  });

  group('FeatureFlag, FlagExplanation, RuleMatch', () {
    final rule = TargetingRule(
      attribute: 'country',
      operator: TargetingOperator.isIn,
      values: const ['PK'],
    );
    FeatureFlag flag({double? rollout = 25, bool enabled = true}) =>
        FeatureFlag(
          key: 'k',
          value: const BoolValue(true),
          offValue: const BoolValue(false),
          enabled: enabled,
          updatedAt: DateTime.utc(2026, 11, 9),
          rolloutPercent: rollout,
          rules: [rule],
        );

    test('a definition compares by value; its type is its value\'s', () {
      expect(flag(), flag());
      expect(flag().hashCode, flag().hashCode);
      expect(flag(), isNot(flag(rollout: 50)));
      expect(flag(), isNot(flag(enabled: false)));
      expect(flag().type, FlagType.boolean);
      expect(() => flag().rules.add(rule), throwsUnsupportedError);
      expect(flag().toString(), contains('25.0 %'));
    });

    test('an explanation and its rules compare by value', () {
      FlagExplanation explanation({bool matched = true}) => FlagExplanation(
        detail: const FlagDetail.fallback('k', EvaluationReason.flagNotFound),
        context: const EvaluationContext(country: 'PK'),
        flag: flag(),
        overrideValue: const BoolValue(true),
        rules: [RuleMatch(rule, matched: matched)],
      );

      expect(explanation(), explanation());
      expect(explanation().hashCode, explanation().hashCode);
      expect(explanation(), isNot(explanation(matched: false)));
      expect(RuleMatch(rule, matched: true).toString(), contains('matches'));
      expect(RuleMatch(rule, matched: false).toString(), contains('no match'));
    });
  });
}
