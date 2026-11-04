import 'package:flagkit/flagkit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sdk.dart';

void main() {
  test('stats compare by value', () {
    FlagKitStats stats({int count = 2, int? version = 3}) => FlagKitStats(
      cacheStatus: CacheStatus.fresh,
      flagCount: count,
      anonymousId: 'a',
      fetchedAt: testNow,
      configVersion: version,
    );

    expect(stats(), stats());
    expect(stats().hashCode, stats().hashCode);
    expect(stats(), isNot(stats(count: 3)));
    expect(stats(), isNot(stats(version: null)));
    expect(stats().toString(), contains('fresh'));
  });
}
