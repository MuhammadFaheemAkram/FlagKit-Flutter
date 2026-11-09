import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/data/flags/app_flag_keys.dart';
import 'package:flagkit_sample/data/flags/flagkit_app_flags.dart';
import 'package:flagkit_sample/domain/flags/app_flags.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flagkit_sample/domain/flags/home_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_flagkit_client.dart';

void main() {
  late FakeFlagKitClient client;
  late FlagKitAppFlags flags;

  setUp(() {
    client = FakeFlagKitClient();
    flags = FlagKitAppFlags(client);
  });
  tearDown(() => client.shutdown());

  test('no values: every flag is the app\'s default', () {
    expect(flags.newHomeScreen, AppFlagDefaults.newHomeScreen);
    expect(flags.newCheckout, AppFlagDefaults.newCheckout);
    expect(flags.homeTheme, AppThemeChoice.classic);
    expect(flags.feedPageSize, AppFlagDefaults.feedPageSize);
    expect(flags.discountPercentage, AppFlagDefaults.discountPercentage);
    expect(flags.homeConfig, HomeConfig.fallback);
  });

  test('each flag reads its own key', () {
    client.values.addAll({
      AppFlagKeys.newHomeScreen: const BoolValue(true),
      AppFlagKeys.newCheckout: const BoolValue(true),
      AppFlagKeys.homeTheme: const StringValue('modern'),
      AppFlagKeys.feedPageSize: const IntValue(30),
      AppFlagKeys.discountPercentage: const DoubleValue(15.5),
      AppFlagKeys.homeConfig: JsonValue(const {
        'banner': 'Sale',
        'sections': ['deals'],
      }),
    });

    expect(flags.newHomeScreen, isTrue);
    expect(flags.newCheckout, isTrue);
    expect(flags.homeTheme, AppThemeChoice.modern);
    expect(flags.feedPageSize, 30);
    expect(flags.discountPercentage, 15.5);
    expect(
      flags.homeConfig,
      const HomeConfig(banner: 'Sale', sections: [HomeSection.deals]),
    );
  });

  // One key at a time: with every flag set at once, a getter reading
  // another getter's key could still pass.
  group('each getter reads only its own key', () {
    for (final (key, value, Object? Function(FlagKitAppFlags) read, expected)
        in <(String, FlagValue, Object? Function(FlagKitAppFlags), Object?)>[
          (
            AppFlagKeys.newHomeScreen,
            const BoolValue(true),
            (f) => f.newHomeScreen,
            true,
          ),
          (
            AppFlagKeys.newCheckout,
            const BoolValue(true),
            (f) => f.newCheckout,
            true,
          ),
          (
            AppFlagKeys.homeTheme,
            const StringValue('ocean'),
            (f) => f.homeTheme,
            AppThemeChoice.ocean,
          ),
          (
            AppFlagKeys.feedPageSize,
            const IntValue(12),
            (f) => f.feedPageSize,
            12,
          ),
          (
            AppFlagKeys.discountPercentage,
            const DoubleValue(5),
            (f) => f.discountPercentage,
            5.0,
          ),
        ]) {
      test(key, () {
        final defaults = _snapshot(flags);
        client.values[key] = value;

        final now = _snapshot(flags);
        expect(read(flags), expected);
        // Every other getter still has its default.
        for (final other in defaults.keys.where((k) => k != key)) {
          expect(now[other], defaults[other], reason: other);
        }
      });
    }
  });

  test('a discount sent as a whole number is read too', () {
    client.values[AppFlagKeys.discountPercentage] = const IntValue(10);

    expect(flags.discountPercentage, 10);
  });

  test('remote numbers are kept to the app\'s ranges', () {
    client.values.addAll({
      AppFlagKeys.feedPageSize: const IntValue(2000),
      AppFlagKeys.discountPercentage: const DoubleValue(90),
    });
    expect(flags.feedPageSize, AppFlagDefaults.maxFeedPageSize);
    expect(flags.discountPercentage, AppFlagDefaults.maxDiscountPercentage);

    client.values.addAll({
      AppFlagKeys.feedPageSize: const IntValue(0),
      AppFlagKeys.discountPercentage: const DoubleValue(-4),
    });
    expect(flags.feedPageSize, AppFlagDefaults.minFeedPageSize);
    expect(flags.discountPercentage, 0);
  });

  test('watch() fires for the app\'s flags only', () async {
    var fired = 0;
    final subscription = flags.watch().listen((_) => fired++);
    addTearDown(subscription.cancel);

    client
      ..emitChanges({'some_other_flag'})
      ..emitChanges({AppFlagKeys.homeTheme, 'some_other_flag'})
      ..emitChanges({AppFlagKeys.feedPageSize});
    await pumpEventQueue();

    expect(fired, 2);
  });
  group('explain', () {
    test('each flag by its own key', () {
      for (final flag in AppFlag.values) {
        final key = AppFlagKeys.of(flag);
        client.values
          ..clear()
          ..[key] = const BoolValue(true);

        final reading = flags.explain(flag);
        expect(reading.key, key);
        expect(reading.reason, ReadingReason.onForEveryone);
        for (final other in AppFlag.values.where((f) => f != flag)) {
          expect(
            flags.explain(other).reason,
            ReadingReason.unknownFlag,
            reason: '${other.name} must not read $key',
          );
        }
      }
    });

    test('every key once, in AppFlagKeys.all', () {
      expect(AppFlag.values.map(AppFlagKeys.of), AppFlagKeys.all);
    });

    test('a rollout\'s bucket and percentage', () {
      client.values[AppFlagKeys.newCheckout] = const BoolValue(false);
      client.details[AppFlagKeys.newCheckout] = (
        FlagSource.cache,
        EvaluationReason.rolloutExcluded,
      );
      client.rollouts[AppFlagKeys.newCheckout] = (4486, 25.0);

      expect(
        flags.explain(AppFlag.newCheckout),
        const FlagReading(
          key: AppFlagKeys.newCheckout,
          value: 'false',
          source: ReadingSource.cache,
          reason: ReadingReason.outsideRollout,
          bucket: 4486,
          rolloutPercent: 25,
          kind: FlagKind.onOff,
        ),
      );
    });
  });
}

Map<String, Object?> _snapshot(FlagKitAppFlags flags) => {
  AppFlagKeys.newHomeScreen: flags.newHomeScreen,
  AppFlagKeys.newCheckout: flags.newCheckout,
  AppFlagKeys.homeTheme: flags.homeTheme,
  AppFlagKeys.feedPageSize: flags.feedPageSize,
  AppFlagKeys.discountPercentage: flags.discountPercentage,
  AppFlagKeys.homeConfig: flags.homeConfig,
};
