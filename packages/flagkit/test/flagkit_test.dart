import 'dart:async';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // An instant server and a network the test controls: no plugin, no
  // latency.
  final config = FlagKitConfig(
    apiKey: 'demo_key',
    transport: FakeRemoteConfigServer(latency: Duration.zero),
    networkMonitor: FakeNetworkMonitor(),
  );

  // A test has no documents directory for the cache file.
  setUp(FlagKitTesting.useInMemoryDatabase);
  tearDown(FlagKitTesting.useDeviceDatabase);
  tearDown(() async {
    await FlagKit.shutdown();
    FlagKit.setContext(const EvaluationContext());
  });

  group('before initialize', () {
    test('every read is the caller\'s default, notInitialized', () {
      expect(FlagKit.isEnabled('new_home_screen'), isFalse);
      expect(FlagKit.isEnabled('new_home_screen', true), isTrue);
      expect(FlagKit.getString('home_theme', 'classic'), 'classic');
      expect(FlagKit.getInt('feed_page_size', 20), 20);
      expect(FlagKit.getDouble('discount_percentage', 0), 0);
      expect(FlagKit.getJson('home_config', const {'a': 1}), {'a': 1});
      expect(FlagKit.getValue('k'), isNull);
      expect(
        FlagKit.detail('k'),
        const FlagDetail.fallback('k', EvaluationReason.notInitialized),
      );
    });

    test('refresh says NotInitialized; clearCache does nothing', () async {
      expect(await FlagKit.refresh(), const NotInitialized());
      await FlagKit.clearCache();
    });

    test('asking for the instance or the debug tools is a developer error', () {
      expect(() => FlagKit.instance, throwsStateError);
      expect(() => FlagKit.debug, throwsStateError);
    });

    test('a context set now is the one the client starts with', () async {
      const context = EvaluationContext(userId: 'user_123', country: 'PK');
      FlagKit.setContext(context);
      expect(FlagKit.context, context);

      await FlagKit.initialize(config);

      expect(FlagKit.instance.context, context);
    });
  });

  group('initialize', () {
    test('starts a client; reads go to it', () async {
      await FlagKit.initialize(config);

      expect(FlagKit.instance, isA<FlagKitClient>());
      expect(FlagKit.debug, same(FlagKit.instance.debug));
      // The startup refresh (an empty cache isn't fresh) has run.
      final stats = await FlagKit.debug.watchStats().firstWhere(
        (stats) => stats.lastRefresh != null,
      );
      expect(stats.cacheStatus, CacheStatus.fresh);
      expect(stats.lastRefresh?.trigger, RefreshTrigger.startup);
      expect(
        FlagKit.detail('k').reason,
        EvaluationReason.flagNotFound,
        reason: 'running now, so the flag is unknown, not "not initialized"',
      );
    });

    test('rejects a bad config, and the SDK stays stopped', () async {
      await expectLater(
        FlagKit.initialize(const FlagKitConfig(apiKey: ' ')),
        throwsArgumentError,
      );

      expect(() => FlagKit.instance, throwsStateError);
      // A good config after a bad one starts normally.
      await FlagKit.initialize(config);
      expect(FlagKit.instance, isNotNull);
    });

    test('a second call while running is ignored, unchecked', () async {
      await FlagKit.initialize(config);
      final first = FlagKit.instance;

      await FlagKit.initialize(const FlagKitConfig(apiKey: ''));

      expect(FlagKit.instance, same(first));
    });

    test('two calls at once share one start', () async {
      await Future.wait([
        FlagKit.initialize(config),
        FlagKit.initialize(const FlagKitConfig(apiKey: 'other')),
      ]);

      expect(FlagKit.instance, isNotNull);
    });
  });

  group('the context', () {
    test('while running, it goes to the client', () async {
      await FlagKit.initialize(config);
      const context = EvaluationContext(appVersion: '2.1.0');

      FlagKit.setContext(context);

      expect(FlagKit.instance.context, context);
      expect(FlagKit.context, context);
    });

    test('it outlives a restart', () async {
      await FlagKit.initialize(config);
      FlagKit.setContext(const EvaluationContext(country: 'GB'));
      await FlagKit.shutdown();
      await FlagKit.initialize(config);

      expect(FlagKit.context, const EvaluationContext(country: 'GB'));
    });
  });

  group('shutdown', () {
    test('stops the client: reads are defaults again', () async {
      await FlagKit.initialize(config);
      await FlagKit.shutdown();

      expect(() => FlagKit.instance, throwsStateError);
      expect(FlagKit.detail('k').reason, EvaluationReason.notInitialized);
      expect(await FlagKit.refresh(), const NotInitialized());
    });

    test('during a start, waits for it, then stops what it started', () async {
      final starting = FlagKit.initialize(config);
      await FlagKit.shutdown();
      await starting;

      expect(() => FlagKit.instance, throwsStateError);
    });

    test('the changes stream stays open across a restart', () async {
      final subscription = FlagKit.changes.listen((_) {});
      final done = Completer<void>();
      final watching = FlagKit.changes.listen((_) {}, onDone: done.complete);

      await FlagKit.initialize(config);
      await FlagKit.shutdown();
      await FlagKit.initialize(config);

      expect(done.isCompleted, isFalse);
      await subscription.cancel();
      await watching.cancel();
    });
  });

  group('FlagKitTesting', () {
    tearDown(FlagKitTesting.useRandomAnonymousIds);

    Future<String> installId() async {
      await FlagKit.initialize(config);
      final id = (await FlagKit.debug.watchStats().first).anonymousId;
      await FlagKit.shutdown();
      return id;
    }

    test('useAnonymousId names new installs; then random again', () async {
      FlagKitTesting.useAnonymousId('install-1');
      expect(await installId(), 'install-1');

      FlagKitTesting.useRandomAnonymousIds();
      final random = await installId();
      expect(random, isNot('install-1'));
      expect(random, matches(RegExp(r'^[0-9a-f-]{36}$')));
    });
  });
}
