import 'package:flagkit/flagkit.dart';
import 'package:flagkit/testing.dart';
import 'package:flagkit_sample/data/demo/fake_server_demo.dart';
import 'package:flagkit_sample/data/flags/flagkit_flags_debug.dart';
import 'package:flagkit_sample/domain/debug/flags_debug.dart';
import 'package:flagkit_sample/domain/demo/demo_server.dart';
import 'package:flutter_test/flutter_test.dart';

// The Dashboard's adapters on the real SDK and a real fake server: what
// the debug tools say, in the app's words.
void main() {
  late FakeRemoteConfigServer server;
  late FlagKitFlagsDebug debug;

  setUp(() async {
    FlagKitTesting.useInMemoryDatabase();
    FlagKitTesting.disableTimers();
    FlagKitTesting.useAnonymousId('test-install');
    server = FakeRemoteConfigServer(
      latency: Duration.zero,
      flags: const [
        {
          'key': 'home_theme',
          'type': 'string',
          'value': 'modern',
          'offValue': 'classic',
          'rules': [
            {
              'attribute': 'country',
              'operator': 'in',
              'values': ['PK', 'AE'],
            },
          ],
        },
        {
          'key': 'new_checkout',
          'type': 'boolean',
          'value': true,
          'offValue': false,
          'rollout': 25,
        },
        {'key': 'feed_page_size', 'type': 'int', 'value': 12, 'offValue': 20},
        {
          'key': 'beta_banner',
          'type': 'boolean',
          'value': true,
          'offValue': false,
        },
      ],
    );
    await FlagKit.initialize(
      FlagKitConfig(
        apiKey: 'demo_key',
        transport: server,
        networkMonitor: FakeNetworkMonitor(),
        startupWait: const Duration(seconds: 1),
      ),
    );
    debug = FlagKitFlagsDebug(FlagKit.instance);
  });
  tearDown(() async {
    await FlagKit.shutdown();
    FlagKit.setContext(const EvaluationContext());
    FlagKitTesting.useDeviceDatabase();
    FlagKitTesting.enableTimers();
    FlagKitTesting.useRandomAnonymousIds();
  });

  group('FlagKitFlagsDebug', () {
    test('the app\'s flags first, then the server\'s others', () {
      final keys = debug.readAll().map((r) => r.key).toList();

      expect(keys.take(6), [
        'new_home_screen',
        'new_checkout',
        'home_theme',
        'feed_page_size',
        'discount_percentage',
        'home_config',
      ]);
      expect(keys.skip(6), ['beta_banner']);
    });

    test('inspect: the definition, the bucket, each rule', () {
      final checkout = debug.inspect('new_checkout')!;
      expect(checkout.reading.kind, FlagKind.onOff);
      expect(checkout.reading.rolloutPercent, 25);
      expect(checkout.reading.bucket, 4486);
      expect(checkout.reading.reason, ReadingReason.outsideRollout);
      expect(checkout.serverValue, 'true');
      expect(checkout.offValue, 'false');
      expect(checkout.enabled, isTrue);
      expect(checkout.defined, isTrue);
      expect(checkout.rules, isEmpty);

      final theme = debug.inspect('home_theme')!;
      expect(theme.rules, [
        const RuleCheck('country is one of PK, AE', matched: false),
      ]);
      FlagKit.setContext(const EvaluationContext(country: 'PK'));
      expect(debug.inspect('home_theme')!.rules.single.matched, isTrue);
    });

    test('inspect: nothing known is null; an override alone is not', () async {
      expect(debug.inspect('nope'), isNull);

      FlagKit.debug.setOverride('nope', const IntValue(3)).ignore();
      await pumpEventQueue();

      final inspection = debug.inspect('nope')!;
      expect(inspection.defined, isFalse);
      expect(inspection.overrideValue, '3');
      expect(inspection.reading.kind, FlagKind.wholeNumber);
      expect(inspection.reading.source, ReadingSource.override);
    });

    test('readFor: another user, in the current country', () {
      FlagKit.setContext(const EvaluationContext(country: 'PK'));

      final maya = debug.readFor(' maya ');
      final checkout = maya.firstWhere((r) => r.key == 'new_checkout');
      expect(checkout.bucket, 404);
      expect(checkout.reason, ReadingReason.inRollout);
      final theme = maya.firstWhere((r) => r.key == 'home_theme');
      expect(theme.reason, ReadingReason.rulesMatched);
      expect(FlagKit.context.userId, isNull, reason: 'the app\'s user stays');
    });

    group('setOverride', () {
      for (final (key, text, value) in [
        ('new_checkout', 'true', const BoolValue(true)),
        ('new_checkout', ' OFF ', const BoolValue(false)),
        ('home_theme', 'ocean', const StringValue('ocean')),
        ('home_theme', '"ocean"', const StringValue('ocean')),
        ('feed_page_size', ' 30 ', const IntValue(30)),
      ]) {
        test('$key: "$text"', () async {
          expect(await debug.setOverride(key, text), isNull);
          expect(FlagKit.instance.getValue(key), value);
          expect(debug.inspect(key)!.overrideValue, value.toString());
        });
      }

      for (final (key, text, error) in [
        ('new_checkout', 'yes', 'Use true or false.'),
        ('home_theme', '  ', 'Enter some text.'),
        ('feed_page_size', '12.5', 'Enter a whole number.'),
        ('nope', '1', 'FlagKit doesn\'t know this flag\'s type.'),
      ]) {
        test('$key: "$text" is refused', () async {
          expect(await debug.setOverride(key, text), error);
          expect(debug.inspect(key)?.overrideValue, isNull);
        });
      }

      test('cleared one at a time, or all', () async {
        await debug.setOverride('new_checkout', 'true');
        await debug.setOverride('feed_page_size', '30');

        await debug.clearOverride('new_checkout');
        expect(debug.inspect('new_checkout')!.overrideValue, isNull);
        await debug.clearOverrides();
        expect(debug.inspect('feed_page_size')!.overrideValue, isNull);
      });
    });

    test('the cache: overrides, version, counts, reads by source', () async {
      await debug.setOverride('new_checkout', 'true');
      FlagKit.instance
        ..isEnabled('new_checkout')
        ..getInt('feed_page_size', 20);

      final cache = await debug.watchCache().first;
      expect(cache.overrideCount, 1);
      expect(cache.configVersion, 1);
      expect(cache.refreshes, 1);
      expect(cache.failedRefreshes, 0);
      expect(cache.reads, {ReadingSource.override: 1, ReadingSource.server: 1});
    });

    test('clearCache and the refresh log', () async {
      await debug.clearCache();
      expect((await debug.watchCache().first).state, CacheState.empty);

      await debug.refresh();
      final log = await debug.watchRefreshLog().first;
      expect(log.map((r) => r.cause), [
        RefreshCause.manual,
        RefreshCause.startup,
      ]);
    });
  });

  group('parseOverride and ruleWords', () {
    test('JSON and decimals', () {
      expect(
        parseOverride(FlagType.json, '{"banner": "Sale"}'),
        JsonValue(const {'banner': 'Sale'}),
      );
      expect(parseOverride(FlagType.json, '[1]'), isNull);
      expect(parseOverride(FlagType.json, '{'), isNull);
      expect(parseOverride(FlagType.decimal, '12.5'), const DoubleValue(12.5));
      expect(parseOverride(FlagType.decimal, 'NaN'), isNull);
      expect(parseOverride(FlagType.string, '""'), isNull);
    });

    test('every operator has its words', () {
      final words = {
        for (final operator in TargetingOperator.values)
          ruleWords(
            TargetingRule(
              attribute: 'a',
              operator: operator,
              operatorName: 'regex',
              values: const ['x'],
            ),
          ),
      };
      expect(words, hasLength(TargetingOperator.values.length));
      expect(words, contains('a "regex" (unknown: never matches) x'));
    });
  });

  group('FakeServerDemo', () {
    late FakeServerDemo demo;

    setUp(() => demo = FakeServerDemo(server));
    tearDown(() => demo.dispose());

    test('the server\'s flags, and the console\'s changes', () async {
      final seen = <List<ServerFlag>>[];
      final subscription = demo.watchFlags().listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      expect(
        seen.single.first,
        const ServerFlag(
          key: 'home_theme',
          enabled: true,
          value: '"modern"',
          isTheme: true,
        ),
      );
      expect(seen.single[1].rolloutPercent, 25);

      demo
        ..setEnabled('feed_page_size', false)
        ..setRollout('new_checkout', 50)
        ..setTheme('ocean');
      await pumpEventQueue();

      expect(seen.last[2].enabled, isFalse);
      expect(seen.last[1].rolloutPercent, 50);
      expect(seen.last.first.value, '"ocean"');
      expect(server.version, 4);
    });

    test('a request alone is no new flag list', () async {
      final seen = <List<ServerFlag>>[];
      final subscription = demo.watchFlags().listen(seen.add);
      addTearDown(subscription.cancel);

      await FlagKit.refresh();
      await pumpEventQueue();

      expect(seen, hasLength(1));
    });

    test('the knobs set the failure rate and the latency', () async {
      final seen = <ServerKnobs>[];
      final subscription = demo.watchKnobs().listen(seen.add);
      addTearDown(subscription.cancel);

      demo
        ..setFailures(ServerFailures.half)
        ..setSpeed(ServerSpeed.slow);
      expect(server.failureRate, 0.5);
      expect(server.latency, const Duration(seconds: 3));
      demo
        ..setFailures(ServerFailures.all)
        ..setSpeed(ServerSpeed.normal);
      expect(server.failureRate, 1);
      expect(server.latency, const Duration(milliseconds: 600));
      await pumpEventQueue();

      expect(seen.first, const ServerKnobs(speed: ServerSpeed.fast));
      expect(seen.last, const ServerKnobs(failures: ServerFailures.all));
      demo
        ..setFailures(ServerFailures.none)
        ..setSpeed(ServerSpeed.fast);
      expect(server.failureRate, 0);
      expect(server.latency, Duration.zero);
    });
  });
}
