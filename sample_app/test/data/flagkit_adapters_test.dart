import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/context/flagkit_user_context.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/data/flags/flagkit_flags_debug.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_flagkit_client.dart';

void main() {
  late FakeFlagKitClient client;

  setUp(() => client = FakeFlagKitClient());
  tearDown(() => client.shutdown());

  group('FlagKitUserContext', () {
    late FlagKitUserContext user;

    setUp(() => user = FlagKitUserContext(client));
    tearDown(() => user.dispose());

    test('gives the SDK the starting user at once', () {
      expect(client.contexts, [const EvaluationContext(appVersion: '2.1.0')]);
    });

    test('every change becomes the SDK\'s context', () {
      user
        ..signIn('  alex ')
        ..setCountry('PK')
        ..setAppVersion('1.9.0')
        ..signOut();

      expect(client.contexts.skip(1), [
        const EvaluationContext(userId: 'alex', appVersion: '2.1.0'),
        const EvaluationContext(
          userId: 'alex',
          country: 'PK',
          appVersion: '2.1.0',
        ),
        const EvaluationContext(
          userId: 'alex',
          country: 'PK',
          appVersion: '1.9.0',
        ),
        const EvaluationContext(country: 'PK', appVersion: '1.9.0'),
      ]);
    });

    test('a blank sign-in, or no change, sets nothing', () {
      user
        ..signIn('   ')
        ..setAppVersion('2.1.0')
        ..setCountry(null);

      expect(client.contexts, hasLength(1));
      expect(user.current, AppUser.initial);
    });

    test('watch() gives the user now, then each change', () async {
      final users = <AppUser>[];
      final subscription = user.watch().listen(users.add);
      addTearDown(subscription.cancel);

      user.setCountry('GB');
      await pumpEventQueue();

      expect(users, [
        AppUser.initial,
        const AppUser(country: 'GB', appVersion: '2.1.0'),
      ]);
    });
  });

  group('FlagKitFlagsDebug', () {
    late FlagKitFlagsDebug debug;

    setUp(() => debug = FlagKitFlagsDebug(client));

    test('the SDK\'s version', () {
      expect(debug.sdkVersion, FlagKit.version);
    });

    test(
      'every app flag, in order; an unknown one shows the app\'s default',
      () {
        final readings = debug.readAll();

        expect(readings.map((r) => r.key), AppFlagKeys.all);
        expect(readings.map((r) => r.value), [
          'false',
          'false',
          '"classic"',
          '20',
          '0.0',
          '{}',
        ]);
        expect(readings.map((r) => r.source).toSet(), {
          ReadingSource.appDefault,
        });
        expect(readings.map((r) => r.reason).toSet(), {
          ReadingReason.unknownFlag,
        });
      },
    );

    test('a value shows as FlagKit has it', () {
      client.values[AppFlagKeys.homeTheme] = const StringValue('modern');

      expect(
        debug.readAll()[2],
        const FlagReading(
          key: AppFlagKeys.homeTheme,
          value: '"modern"',
          source: ReadingSource.server,
          reason: ReadingReason.onForEveryone,
        ),
      );
    });

    test('every source and reason has its own word', () {
      const key = AppFlagKeys.newCheckout;
      client.values[key] = const BoolValue(true);
      final sources = <ReadingSource>{};
      final reasons = <ReadingReason>{};
      for (final source in FlagSource.values) {
        for (final reason in EvaluationReason.values) {
          client.details[key] = (source, reason);
          final reading = debug.readAll()[1];
          sources.add(reading.source);
          reasons.add(reading.reason);
        }
      }

      // FlagSource.defaultValue with a value is only possible in this fake.
      expect(sources, ReadingSource.values.toSet());
      expect(reasons, ReadingReason.values.toSet());
    });

    test('the cache, in the app\'s words, for every status', () async {
      final seen = <CacheInfo>[];
      final subscription = debug.watchCache().listen(seen.add);
      addTearDown(subscription.cancel);
      final at = DateTime.utc(2026, 11, 4, 9, 41);

      for (final status in CacheStatus.values) {
        client.debug.emit(
          FlagKitStats(
            cacheStatus: status,
            flagCount: 6,
            anonymousId: 'anon-1',
            fetchedAt: at,
          ),
        );
      }
      await pumpEventQueue();

      expect(seen.map((c) => c.state), [
        CacheState.fresh,
        CacheState.stale,
        CacheState.expired,
        CacheState.empty,
      ]);
      expect(
        seen.first,
        CacheInfo(
          state: CacheState.fresh,
          flagCount: 6,
          installId: 'anon-1',
          fetchedAt: at,
        ),
      );
    });

    test('watch() fires on any change', () async {
      var fired = 0;
      final subscription = debug.watch().listen((_) => fired++);
      addTearDown(subscription.cancel);

      client.emitChanges({'anything'});
      await pumpEventQueue();

      expect(fired, 1);
    });
  });
}
