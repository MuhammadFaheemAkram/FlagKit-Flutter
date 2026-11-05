import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/refresh/config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/sdk.dart';

void main() {
  ParsedConfig parse(Map<String, Object?> json) =>
      parseConfig(json, fetchedAt: testNow);

  test('a valid config: every flag, the version, nothing skipped', () {
    final config = parse(
      wireConfig(version: 7, [
        wireFlag('new_home_screen'),
        wireFlag('feed_page_size', type: 'int', value: 30, offValue: 20),
        wireFlag(
          'home_config',
          type: 'json',
          value: {'banner': 'Sale'},
          offValue: <String, Object?>{},
          enabled: false,
        ),
      ]),
    );

    expect(config.version, 7);
    expect(config.skipped, isEmpty);
    expect(config.flags.map((f) => f.key), [
      'new_home_screen',
      'feed_page_size',
      'home_config',
    ]);
    expect(config.flags[1].value, const IntValue(30));
    expect(config.flags[1].offValue, const IntValue(20));
    expect(config.flags[2].enabled, isFalse);
    expect(config.flags.first.updatedAt, testNow);
  });

  test('"enabled" absent: on', () {
    expect(parse(wireConfig([wireFlag('a')])).flags.single.enabled, isTrue);
  });

  test('a malformed payload is refused whole', () {
    for (final json in <Map<String, Object?>>[
      {'flags': <Object?>[]},
      {'version': '7', 'flags': <Object?>[]},
      {'version': 7},
      {'version': 7, 'flags': <String, Object?>{}},
    ]) {
      expect(() => parse(json), throwsFormatException, reason: '$json');
    }
  });

  group('a bad flag is skipped; the rest apply', () {
    for (final (name, Object? flag, reason) in [
      ('not an object', 'new_home_screen', 'not an object'),
      ('a key with capitals', wireFlag('NewHome'), 'a key must be'),
      ('a blank key', wireFlag(''), 'a key must be'),
      ('a 65-character key', wireFlag('k' * 65), 'a key must be'),
      ('an unknown type', wireFlag('k', type: 'date'), 'an unknown type'),
      ('a value of another type', wireFlag('k', value: 'yes'), 'its value'),
      (
        'an off value of another type',
        wireFlag('k', offValue: 0),
        'its offValue',
      ),
      ('"enabled" not a bool', {...wireFlag('k'), 'enabled': 1}, 'enabled'),
      ('a rollout', {...wireFlag('k'), 'rollout': 25}, '0.4.0'),
      (
        'rules',
        {
          ...wireFlag('k'),
          'rules': [
            {'attribute': 'country'},
          ],
        },
        '0.4.0',
      ),
    ]) {
      test(name, () {
        final config = parse({
          'version': 1,
          'flags': [flag, wireFlag('good')],
        });

        expect(config.flags.map((f) => f.key), ['good']);
        expect(config.skipped.single, contains(reason));
      });
    }

    test('a second definition of a key: the first wins', () {
      final config = parse(
        wireConfig([wireFlag('k'), wireFlag('k', value: false)]),
      );

      expect(config.flags.single.value, const BoolValue(true));
      expect(config.skipped.single, contains('a second definition'));
    });

    test('empty rules and a null rollout are no rules at all', () {
      final config = parse(
        wireConfig([
          {...wireFlag('k'), 'rules': <Object?>[], 'rollout': null},
        ]),
      );

      expect(config.skipped, isEmpty);
    });
  });
}
