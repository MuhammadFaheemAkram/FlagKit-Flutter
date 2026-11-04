import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/cache/cache_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sdk.dart';

void main() {
  const interval = Duration(hours: 1);
  const expiry = Duration(hours: 24);

  CacheStatus at(Duration age, {bool never = false}) => cacheStatusOf(
    fetchedAt: never ? null : testNow.subtract(age),
    now: testNow,
    refreshInterval: interval,
    cacheExpiration: expiry,
  );

  test('never fetched: empty', () {
    expect(at(Duration.zero, never: true), CacheStatus.empty);
  });

  test('every boundary: exactly at one is the later status', () {
    const ms = Duration(milliseconds: 1);
    for (final (age, status) in [
      (Duration.zero, CacheStatus.fresh),
      (interval - ms, CacheStatus.fresh),
      (interval, CacheStatus.stale),
      (expiry - ms, CacheStatus.stale),
      (expiry, CacheStatus.expired),
      (const Duration(days: 30), CacheStatus.expired),
    ]) {
      expect(at(age), status, reason: '$age old');
    }
  });

  test('a fetch time in the future (the clock moved back) is fresh', () {
    expect(at(const Duration(days: -2)), CacheStatus.fresh);
  });

  test('refresh interval and expiry equal: no stale state at all', () {
    CacheStatus status(Duration age) => cacheStatusOf(
      fetchedAt: testNow.subtract(age),
      now: testNow,
      refreshInterval: interval,
      cacheExpiration: interval,
    );

    expect(
      status(interval - const Duration(milliseconds: 1)),
      CacheStatus.fresh,
    );
    expect(status(interval), CacheStatus.expired);
  });
}
