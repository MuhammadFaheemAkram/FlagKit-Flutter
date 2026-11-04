import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flagkit/src/util/json.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/log_recorder.dart';

void main() {
  group('the logger', () {
    test('is silent unless enabled: no lines in a host\'s release logs', () {
      final logs = LogRecorder();
      logs.logger(enabled: false)
        ..debug('a')
        ..warning('b')
        ..error('c', StateError('x'), StackTrace.empty);

      expect(logs.lines, isEmpty);
    });

    test('enabled, it writes every level', () {
      final logs = LogRecorder();
      logs.logger()
        ..debug('a')
        ..warning('b')
        ..error('c', StateError('x'), StackTrace.empty);

      expect(logs.lines, [
        (LogLevel.debug, 'a'),
        (LogLevel.warning, 'b'),
        (LogLevel.error, 'c'),
      ]);
    });
  });

  group('JSON helpers', () {
    test('equality and hashing agree, at every depth', () {
      final a = {
        'x': [
          1,
          {'y': null},
        ],
        'z': 'q',
      };
      final b = {
        'z': 'q',
        'x': [
          1,
          {'y': null},
        ],
      };

      expect(jsonEquals(a, b), isTrue);
      expect(jsonHash(a), jsonHash(b));
      expect(jsonEquals(a, {...b, 'w': 1}), isFalse);
      expect(jsonEquals([1, 2], [2, 1]), isFalse);
      expect(jsonEquals({'a': 1}, {'b': 1}), isFalse);
    });

    test('freezing names the path of what JSON can\'t carry', () {
      expect(
        () => freezeJson({
          'a': [1, Object()],
        }),
        throwsA(isA<ArgumentError>().having((e) => e.name, 'name', r'$.a[1]')),
      );
      expect(() => freezeJson(double.infinity), throwsArgumentError);
    });
  });
}
