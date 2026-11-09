import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/model/flag_value_codec.dart';
import 'package:flagkit/src/storage/flag_mapper.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sdk.dart';

void main() {
  group('a JSON value as a flag value', () {
    test('each type takes its own JSON', () {
      expect(flagValueFromJson(FlagType.boolean, true), const BoolValue(true));
      expect(flagValueFromJson(FlagType.string, 'x'), const StringValue('x'));
      expect(flagValueFromJson(FlagType.integer, 30), const IntValue(30));
      expect(
        flagValueFromJson(FlagType.decimal, 15.5),
        const DoubleValue(15.5),
      );
      expect(
        flagValueFromJson(FlagType.json, const {'a': 1}),
        JsonValue(const {'a': 1}),
      );
    });

    test('numbers: what JSON forces, and nothing more', () {
      // A server may send 20.0 for an int, and 10 for a double.
      expect(flagValueFromJson(FlagType.integer, 20.0), const IntValue(20));
      expect(flagValueFromJson(FlagType.decimal, 10), const DoubleValue(10));
      // A fraction isn't an int; past 2^53 it may already have lost digits.
      expect(flagValueFromJson(FlagType.integer, 20.5), isNull);
      expect(flagValueFromJson(FlagType.integer, 9007199254740993), isNull);
      expect(flagValueFromJson(FlagType.integer, 9007199254740992), isNotNull);
    });

    test('nothing else converts', () {
      for (final (type, json) in <(FlagType, Object?)>[
        (FlagType.boolean, 'true'),
        (FlagType.boolean, 1),
        (FlagType.string, 30),
        (FlagType.integer, '30'),
        (FlagType.decimal, '15.5'),
        (FlagType.json, const ['a']),
        (FlagType.json, null),
      ]) {
        expect(flagValueFromJson(type, json), isNull, reason: '$type $json');
      }
    });
  });

  group('rows and definitions', () {
    test('every type round-trips', () {
      for (final value in <FlagValue>[
        const BoolValue(true),
        const StringValue('modern'),
        const IntValue(30),
        const DoubleValue(15.5),
        JsonValue(const {
          'sections': ['deals'],
        }),
      ]) {
        final original = definition('k', value: value, enabled: false);

        expect(original.toRow().toDefinition(), original);
      }
    });

    test('rules and a rollout round-trip', () {
      final original = definition(
        'k',
        rolloutBasisPoints: 2550,
        rules: [
          TargetingRule(
            attribute: 'country',
            operator: TargetingOperator.isIn,
            values: const ['PK', 'AE'],
          ),
          TargetingRule(
            attribute: 'email',
            operator: TargetingOperator.unknown,
            operatorName: 'matchesRegex',
            values: const ['.*'],
          ),
        ],
      );
      final row = original.toRow();

      expect(row.rolloutBp, 2550);
      expect(row.rules, contains('"operator":"in"'));
      expect(row.toDefinition(), original);
      expect(row.toDefinition()!.rules.last.operatorName, 'matchesRegex');
    });

    test('a row whose rules can\'t be read is no definition', () {
      final row = definition('k').toRow().copyWith(rules: '{"not":"a list"}');
      expect(row.toDefinition(), isNull);
    });

    test('a row is written as the wire would carry it', () {
      final row = definition(
        'feed_page_size',
        value: const IntValue(30),
        offValue: const IntValue(20),
      ).toRow();

      expect(row.type, 'int');
      expect(row.value, '30');
      expect(row.offValue, '20');
      expect(row.rules, '[]');
      expect(row.rolloutBp, isNull);
    });

    test('a row that can\'t be read is no definition, not a crash', () {
      FlagRow row({
        String type = 'int',
        String value = '30',
        String off = '20',
      }) => FlagRow(
        key: 'k',
        type: type,
        value: value,
        offValue: off,
        enabled: true,
        rules: '[]',
        updatedAt: testNow,
      );

      expect(row().toDefinition(), isNotNull);
      expect(row(type: 'date').toDefinition(), isNull);
      // An unknown type is skipped even when its values would pass as
      // another type's.
      expect(
        row(type: 'date', value: 'true', off: 'false').toDefinition(),
        isNull,
      );
      expect(row(value: '"thirty"').toDefinition(), isNull);
      expect(row(off: 'true').toDefinition(), isNull);
      expect(row(value: 'not json').toDefinition(), isNull);
    });
  });
}
