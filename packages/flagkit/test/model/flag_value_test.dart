import 'package:flagkit/flagkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each value knows its type and its JSON', () {
    for (final (value, type, json) in <(FlagValue, FlagType, Object)>[
      (const BoolValue(true), FlagType.boolean, true),
      (const StringValue('modern'), FlagType.string, 'modern'),
      (const IntValue(30), FlagType.integer, 30),
      (const DoubleValue(15.5), FlagType.decimal, 15.5),
      (JsonValue(const {'banner': 'Sale'}), FlagType.json, {'banner': 'Sale'}),
    ]) {
      expect(value.type, type);
      expect(value.toJson(), json);
    }
  });

  test('values compare by type and value', () {
    expect(const IntValue(1), const IntValue(1));
    expect(const IntValue(1).hashCode, const IntValue(1).hashCode);
    // The same number in another type is another value.
    expect(const IntValue(1), isNot(const DoubleValue(1)));
    expect(const StringValue('true'), isNot(const BoolValue(true)));
    expect(const BoolValue(true), isNot(const BoolValue(false)));
  });

  group('JsonValue', () {
    test('compares deeply, whatever the key order', () {
      final a = JsonValue(const {
        'sections': ['deals', 'new'],
        'banner': {'text': 'Sale', 'color': 1},
      });
      final b = JsonValue(const {
        'banner': {'color': 1, 'text': 'Sale'},
        'sections': ['deals', 'new'],
      });

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(
          JsonValue(const {
            'sections': ['new', 'deals'],
            'banner': {'text': 'Sale', 'color': 1},
          }),
        ),
      );
    });

    test('is a frozen copy: the caller\'s map and the value are apart', () {
      final source = <String, Object?>{
        'sections': ['deals'],
      };
      final value = JsonValue(source);
      (source['sections']! as List<Object?>).add('new');
      source['extra'] = true;

      expect(value.value, {
        'sections': ['deals'],
      });
      expect(() => value.value['x'] = 1, throwsUnsupportedError);
      expect(
        () => (value.value['sections']! as List<Object?>).add('x'),
        throwsUnsupportedError,
      );
    });

    test('refuses what JSON can\'t carry', () {
      expect(() => JsonValue({'when': DateTime(2026)}), throwsArgumentError);
      expect(() => JsonValue(const {'n': double.nan}), throwsArgumentError);
      expect(
        () => JsonValue(const {
          'nested': {1: 'a non-string key'},
        }),
        throwsArgumentError,
      );
    });

    test('prints as JSON', () {
      expect(
        JsonValue(const {
          'banner': 'Sale',
          'sections': ['deals'],
        }).toString(),
        '{"banner":"Sale","sections":["deals"]}',
      );
    });

    test('keeps null, bools, numbers, strings, lists and maps', () {
      final value = JsonValue(const {
        'a': null,
        'b': true,
        'c': 1.5,
        'd': 'text',
        'e': [1, 2],
        'f': {'g': <Object?>[]},
      });

      expect(value.value['e'], [1, 2]);
      expect(value.value['f'], {'g': <Object?>[]});
    });
  });

  test('FlagType maps to and from the wire\'s names', () {
    expect(FlagType.values.map((t) => t.wireName), [
      'boolean',
      'string',
      'int',
      'double',
      'json',
    ]);
    for (final type in FlagType.values) {
      expect(FlagType.fromWireName(type.wireName), type);
    }
    // A newer server's type: unknown here, not a crash.
    expect(FlagType.fromWireName('date'), isNull);
  });
}
