import 'dart:async';

import 'package:flagkit_sample/core/common/money.dart';
import 'package:flagkit_sample/core/common/start_with.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prices and percentages for people', () {
    expect(formatPrice(1250, 'USD'), r'$12.50');
    expect(formatPercent(15.5), '15.5 %');
    expect(formatPercent(10), '10 %');
  });

  group('startWith', () {
    test('the current value, then the changes', () async {
      final changes = StreamController<int>.broadcast();
      addTearDown(changes.close);
      final values = <int>[];
      final subscription = startWith(
        () => 1,
        changes.stream,
      ).listen(values.add);
      addTearDown(subscription.cancel);

      changes.add(2);
      await pumpEventQueue();

      expect(values, [1, 2]);
    });

    test('a change right after listening isn\'t lost (§11.99)', () async {
      final changes = StreamController<int>.broadcast();
      addTearDown(changes.close);
      final values = <int>[];
      final subscription = startWith(
        () => 1,
        changes.stream,
      ).listen(values.add);
      addTearDown(subscription.cancel);
      changes.add(2); // before any event is delivered

      await pumpEventQueue();

      expect(values, [1, 2]);
    });
  });
}
