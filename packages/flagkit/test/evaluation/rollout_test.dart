import 'package:flagkit/src/evaluation/fnv1a.dart';
import 'package:flagkit/src/evaluation/rollout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FNV-1a (32-bit)', () {
    // The reference vectors (Fowler, Noll, Vo): any port of the SDK, on any
    // platform, must hash to these, or users change buckets between apps.
    test('matches the reference vectors', () {
      expect(fnv1a32(''), 0x811c9dc5);
      expect(fnv1a32('a'), 0xe40c292c);
      expect(fnv1a32('foobar'), 0xbf9cf968);
    });

    test('hashes UTF-8 bytes, not UTF-16 code units', () {
      // 'é' is two bytes (0xc3 0xa9) in UTF-8.
      var hash = 0x811c9dc5;
      for (final byte in [0xc3, 0xa9]) {
        hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
      }
      expect(fnv1a32('é'), hash);
    });

    test('stays within 32 bits', () {
      for (final text in ['x' * 1000, 'new_checkout:user_123', '🙂']) {
        expect(fnv1a32(text), inInclusiveRange(0, 0xffffffff));
      }
    });
  });

  group('buckets', () {
    final units = [for (var i = 0; i < 10000; i++) 'install-$i'];

    test('are 0–9999 and the same every time', () {
      for (final unit in units.take(100)) {
        final bucket = bucketOf('new_checkout', unit);
        expect(bucket, inInclusiveRange(0, rolloutBuckets - 1));
        expect(bucketOf('new_checkout', unit), bucket);
      }
    });

    test('are the hash of "key:unit"', () {
      expect(
        bucketOf('new_checkout', 'user_123'),
        fnv1a32('new_checkout:user_123') % 10000,
      );
    });

    test('differ per flag: one user isn\'t first in every rollout', () {
      final inBoth = units
          .where(
            (unit) =>
                rolloutIncludes(1000, bucketOf('a', unit)) &&
                rolloutIncludes(1000, bucketOf('b', unit)),
          )
          .length;
      // Independent 10 % rollouts share about 1 % of users, not 10 %.
      expect(inBoth, inInclusiveRange(50, 150));
    });

    for (final (percent, low, high) in [
      (0, 0.0, 0.0),
      (10, 9.0, 11.0),
      (25, 23.5, 26.5),
      (50, 48.5, 51.5),
      (100, 100.0, 100.0),
    ]) {
      test('$percent % includes about $percent % of 10,000 users', () {
        final included = units
            .where(
              (unit) => rolloutIncludes(
                percent * 100,
                bucketOf('new_checkout', unit),
              ),
            )
            .length;
        expect(included / units.length * 100, inInclusiveRange(low, high));
      });
    }

    test('are monotonic: raising a rollout never drops anyone', () {
      final included = <String>{};
      for (var basisPoints = 0; basisPoints <= 10000; basisPoints += 500) {
        final now = {
          for (final unit in units)
            if (rolloutIncludes(basisPoints, bucketOf('new_checkout', unit)))
              unit,
        };
        expect(now.containsAll(included), isTrue, reason: '$basisPoints bp');
        included
          ..clear()
          ..addAll(now);
      }
      expect(included, hasLength(units.length));
    });

    test('a bucket is included below the threshold, not at it', () {
      expect(rolloutIncludes(2500, 2499), isTrue);
      expect(rolloutIncludes(2500, 2500), isFalse);
      expect(rolloutIncludes(0, 0), isFalse);
      expect(rolloutIncludes(10000, 9999), isTrue);
    });
  });
}
