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

  test('every field of the stats is part of the value', () {
    FlagKitStats stats({
      int overrides = 0,
      bool online = true,
      bool refreshing = false,
      Map<FlagSource, int> evaluations = const {FlagSource.cache: 2},
      int refreshes = 1,
      int failed = 0,
      int skipped = 0,
    }) => FlagKitStats(
      cacheStatus: CacheStatus.fresh,
      flagCount: 2,
      anonymousId: 'a',
      overrideCount: overrides,
      online: online,
      refreshing: refreshing,
      evaluations: evaluations,
      refreshCount: refreshes,
      failedRefreshCount: failed,
      skippedCount: skipped,
    );

    expect(stats(), stats());
    expect(stats().hashCode, stats().hashCode);
    for (final other in [
      stats(overrides: 1),
      stats(online: false),
      stats(refreshing: true),
      stats(evaluations: const {FlagSource.cache: 3}),
      stats(refreshes: 2),
      stats(failed: 1),
      stats(skipped: 1),
    ]) {
      expect(stats(), isNot(other));
    }
    expect(
      stats(online: false, refreshing: true).toString(),
      contains('offline, refreshing'),
    );
  });
}
