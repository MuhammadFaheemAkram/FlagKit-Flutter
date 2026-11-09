import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/evaluation/flag_evaluator.dart';
import 'package:flagkit/src/evaluation/rollout.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sdk.dart';

void main() {
  FlagDetail evaluate(
    FlagDefinition? definition, {
    FlagType? requested,
    FlagSource source = FlagSource.cache,
    EvaluationContext context = const EvaluationContext(),
    String unit = 'install-1',
  }) => evaluateFlag(
    key: 'k',
    definition: definition,
    source: source,
    requested: requested,
    context: context,
    unit: unit,
  );

  test('no definition: the caller\'s default (flagNotFound)', () {
    expect(
      evaluate(null),
      const FlagDetail.fallback('k', EvaluationReason.flagNotFound),
    );
  });

  test('on: the value, from where the snapshot came from (fallthrough)', () {
    final on = definition('k', value: const IntValue(30));

    expect(
      evaluate(on, requested: FlagType.integer, source: FlagSource.remote),
      const FlagDetail(
        key: 'k',
        value: IntValue(30),
        source: FlagSource.remote,
        reason: EvaluationReason.fallthrough,
      ),
    );
  });

  test('off: the off value (the kill switch)', () {
    final off = definition(
      'k',
      value: const StringValue('modern'),
      offValue: const StringValue('classic'),
      enabled: false,
    );

    expect(
      evaluate(off, requested: FlagType.string),
      const FlagDetail(
        key: 'k',
        value: StringValue('classic'),
        source: FlagSource.cache,
        reason: EvaluationReason.off,
      ),
    );
  });

  test('another type: the caller\'s default (typeMismatch), even when off', () {
    for (final enabled in [true, false]) {
      final flag = definition(
        'k',
        value: const StringValue('30'),
        enabled: enabled,
      );

      expect(
        evaluate(flag, requested: FlagType.integer),
        const FlagDetail.fallback('k', EvaluationReason.typeMismatch),
      );
    }
  });

  test('an int flag can be read as a double; not the other way', () {
    final integer = definition('k', value: const IntValue(10));
    final decimal = definition('k', value: const DoubleValue(10));

    expect(
      evaluate(integer, requested: FlagType.decimal).value,
      const IntValue(10),
    );
    expect(
      evaluate(decimal, requested: FlagType.integer).reason,
      EvaluationReason.typeMismatch,
    );
  });

  test('a read of any type (getValue, detail) takes the flag as it is', () {
    expect(
      evaluate(definition('k', value: const IntValue(1))).reason,
      EvaluationReason.fallthrough,
    );
  });

  group('targeting and rollouts', () {
    final inPakistan = TargetingRule(
      attribute: 'country',
      operator: TargetingOperator.isIn,
      values: const ['PK', 'AE'],
    );
    const pakistani = EvaluationContext(country: 'PK');
    const british = EvaluationContext(country: 'GB');
    final theme = definition(
      'k',
      value: const StringValue('modern'),
      offValue: const StringValue('classic'),
      rules: [inPakistan],
    );
    // bucketOf('k', unit) for these units: 'u-2' is 1644 (in a 25 % rollout),
    // 'u-1' is 4501 (outside it). Checked by the first test.
    const inside = 'u-2';
    const outside = 'u-1';

    test('the units the tests rely on fall where they say', () {
      expect(bucketOf('k', inside), 1644);
      expect(bucketOf('k', outside), 4501);
    });

    test('rules that match: the value (targetingMatch)', () {
      expect(
        evaluate(theme, context: pakistani),
        const FlagDetail(
          key: 'k',
          value: StringValue('modern'),
          source: FlagSource.cache,
          reason: EvaluationReason.targetingMatch,
        ),
      );
    });

    test('rules that don\'t: the off value (targetingMiss)', () {
      for (final context in [british, const EvaluationContext()]) {
        final detail = evaluate(theme, context: context);
        expect(detail.value, const StringValue('classic'));
        expect(detail.reason, EvaluationReason.targetingMiss);
      }
    });

    test('every rule must match', () {
      final both = definition(
        'k',
        rules: [
          inPakistan,
          TargetingRule(
            attribute: 'appVersion',
            operator: TargetingOperator.semverAtLeast,
            values: const ['2.0.0'],
          ),
        ],
      );

      expect(
        evaluate(both, context: pakistani).reason,
        EvaluationReason.targetingMiss,
        reason: 'no app version',
      );
      expect(
        evaluate(
          both,
          context: const EvaluationContext(country: 'PK', appVersion: '2.1.0'),
        ).reason,
        EvaluationReason.targetingMatch,
      );
    });

    test('off beats the rules: the kill switch, matched or not', () {
      final off = definition('k', enabled: false, rules: [inPakistan]);

      for (final context in [pakistani, british]) {
        expect(evaluate(off, context: context).reason, EvaluationReason.off);
      }
    });

    test('a rollout: the bucket decides (rolloutIncluded/Excluded)', () {
      final quarter = definition('k', rolloutBasisPoints: 2500);

      final included = evaluate(quarter, unit: inside);
      expect(included.value, const BoolValue(true));
      expect(included.reason, EvaluationReason.rolloutIncluded);
      expect(included.bucket, bucketOf('k', inside));
      expect(included.rolloutPercent, 25);

      final excluded = evaluate(quarter, unit: outside);
      expect(excluded.value, const BoolValue(false));
      expect(excluded.reason, EvaluationReason.rolloutExcluded);
      expect(excluded.bucket, bucketOf('k', outside));
      expect(excluded.rolloutPercent, 25);
    });

    test('0 % includes no one; 100 % everyone', () {
      for (final unit in [inside, outside]) {
        expect(
          evaluate(definition('k', rolloutBasisPoints: 0), unit: unit).reason,
          EvaluationReason.rolloutExcluded,
        );
        expect(
          evaluate(
            definition('k', rolloutBasisPoints: 10000),
            unit: unit,
          ).reason,
          EvaluationReason.rolloutIncluded,
        );
      }
    });

    test('rules first, then the rollout among the eligible', () {
      final targetedQuarter = definition(
        'k',
        rules: [inPakistan],
        rolloutBasisPoints: 2500,
      );

      final miss = evaluate(targetedQuarter, context: british, unit: inside);
      expect(miss.reason, EvaluationReason.targetingMiss);
      expect(miss.bucket, isNull, reason: 'never bucketed');

      final match = evaluate(targetedQuarter, context: pakistani, unit: inside);
      expect(match.reason, EvaluationReason.targetingMatch);
      expect(match.bucket, isNotNull);

      expect(
        evaluate(targetedQuarter, context: pakistani, unit: outside).reason,
        EvaluationReason.rolloutExcluded,
      );
    });

    test('no rollout: no bucket', () {
      final detail = evaluate(definition('k'));
      expect(detail.bucket, isNull);
      expect(detail.rolloutPercent, isNull);
    });

    test('a bucket shows in toString', () {
      expect(
        evaluate(
          definition('k', rolloutBasisPoints: 2500),
          unit: inside,
        ).toString(),
        contains('bucket ${bucketOf('k', inside)} of 25.0 %'),
      );
    });
  });
}
