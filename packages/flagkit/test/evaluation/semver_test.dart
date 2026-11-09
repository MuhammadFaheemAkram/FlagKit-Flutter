import 'package:flagkit/src/evaluation/semver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SemVer v(String text) => SemVer.tryParse(text)!;

  test('parses major.minor.patch; missing parts are 0', () {
    expect(v('2.1.3'), const SemVer(2, 1, 3));
    expect(v('2.1'), const SemVer(2, 1, 0));
    expect(v('2'), const SemVer(2, 0, 0));
    expect(v(' 2.0.0 '), const SemVer(2, 0, 0), reason: 'trimmed');
    expect(v('2.0').toString(), '2.0.0');
  });

  test('anything else isn\'t a version', () {
    for (final text in [
      '',
      'v2.0.0',
      '2.0.0-beta',
      '2.0.0+5',
      '2..0',
      '2.0.0.1',
      '2.x',
      '-1.0.0',
      '1234567890.0.0',
    ]) {
      expect(SemVer.tryParse(text), isNull, reason: text);
    }
  });

  test('compares as numbers, part by part', () {
    expect(v('2.10.0').compareTo(v('2.9.0')), greaterThan(0));
    expect(v('2.0.10').compareTo(v('2.0.9')), greaterThan(0));
    expect(v('10.0.0').compareTo(v('9.99.99')), greaterThan(0));
    expect(v('1.9.0').compareTo(v('2.0.0')), lessThan(0));
    expect(v('2.1.0').compareTo(v('2.0.5')), greaterThan(0));
    expect(v('2.0').compareTo(v('2.0.0')), 0);
    expect(v('2.0'), v('2.0.0'));
    expect(v('2.0').hashCode, v('2.0.0').hashCode);
  });
}
