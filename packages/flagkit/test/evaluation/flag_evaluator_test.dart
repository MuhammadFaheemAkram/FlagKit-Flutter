import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/evaluation/flag_evaluator.dart';
import 'package:flagkit/src/repository/flag_definition.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sdk.dart';

void main() {
  FlagDetail evaluate(
    FlagDefinition? definition, {
    FlagType? requested,
    FlagSource source = FlagSource.cache,
  }) => evaluateFlag(
    key: 'k',
    definition: definition,
    source: source,
    requested: requested,
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
}
