import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/evaluation/typed_reads.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every read with one value, and records what was asked.
final class _Reads with TypedReads {
  _Reads(this.answer);

  final FlagValue? answer;
  final asked = <(String, FlagType?)>[];

  @override
  FlagDetail evaluate(String key, FlagType? requested) {
    asked.add((key, requested));
    return answer == null
        ? FlagDetail.fallback(key, EvaluationReason.flagNotFound)
        : FlagDetail(
            key: key,
            value: answer,
            source: FlagSource.remote,
            reason: EvaluationReason.fallthrough,
          );
  }
}

void main() {
  test('each read asks for its own type', () {
    final reads = _Reads(null)
      ..isEnabled('a')
      ..getString('b', '')
      ..getInt('c', 0)
      ..getDouble('d', 0)
      ..getJson('e', const {})
      ..getValue('f')
      ..detail('g');

    expect(reads.asked, [
      ('a', FlagType.boolean),
      ('b', FlagType.string),
      ('c', FlagType.integer),
      ('d', FlagType.decimal),
      ('e', FlagType.json),
      ('f', null),
      ('g', null),
    ]);
  });

  test('a value of the asked type is returned', () {
    expect(_Reads(const BoolValue(true)).isEnabled('k'), isTrue);
    expect(_Reads(const StringValue('modern')).getString('k', 'x'), 'modern');
    expect(_Reads(const IntValue(30)).getInt('k', 20), 30);
    expect(_Reads(const DoubleValue(15.5)).getDouble('k', 0), 15.5);
    expect(_Reads(JsonValue(const {'banner': 'Sale'})).getJson('k', const {}), {
      'banner': 'Sale',
    });
  });

  test('getDouble widens an int; nothing else converts', () {
    expect(_Reads(const IntValue(20)).getDouble('k', 0), 20.0);
    // A double isn't an int, a string isn't a number, a number isn't a bool.
    expect(_Reads(const DoubleValue(20)).getInt('k', 7), 7);
    expect(_Reads(const StringValue('30')).getInt('k', 7), 7);
    expect(_Reads(const IntValue(1)).isEnabled('k'), isFalse);
    expect(_Reads(const StringValue('true')).isEnabled('k', true), isTrue);
  });

  test('no value: the caller\'s default, every type', () {
    final reads = _Reads(null);

    expect(reads.isEnabled('k'), isFalse);
    expect(reads.isEnabled('k', true), isTrue);
    expect(reads.getString('k', 'classic'), 'classic');
    expect(reads.getInt('k', 20), 20);
    expect(reads.getDouble('k', 0.5), 0.5);
    expect(reads.getJson('k', const {'a': 1}), {'a': 1});
    expect(reads.getValue('k'), isNull);
    expect(reads.detail('k').reason, EvaluationReason.flagNotFound);
  });
}
