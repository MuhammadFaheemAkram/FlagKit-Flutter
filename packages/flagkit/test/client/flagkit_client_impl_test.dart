import 'dart:io';

import 'package:drift/native.dart';
import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/log_recorder.dart';
import '../helpers/sdk.dart';

void main() {
  test('create() validates the config first', () {
    expect(
      () => FlagKitClient.create(const FlagKitConfig(apiKey: '')),
      throwsArgumentError,
    );
  });

  group('a client', _client);
}

void _client() {
  late LogRecorder logs;
  late FlagKitDatabase db;
  late FlagKitClientImpl client;

  setUp(() {
    logs = LogRecorder();
    db = FlagKitDatabase.inMemory();
  });
  tearDown(() => client.shutdown());

  Future<void> start({DateTime Function()? now}) async =>
      client = await openTestClient(database: db, logs: logs, now: now);

  group('an empty cache', () {
    setUp(start);

    test('a flag it doesn\'t know: the caller\'s default, flagNotFound', () {
      expect(client.isEnabled('new_home_screen'), isFalse);
      expect(client.getInt('feed_page_size', 20), 20);
      expect(
        client.detail('feed_page_size'),
        const FlagDetail.fallback(
          'feed_page_size',
          EvaluationReason.flagNotFound,
        ),
      );
    });

    test('an unknown flag is logged once, not on every read', () {
      for (var i = 0; i < 5; i++) {
        client.isEnabled('new_home_screen');
      }
      client.getString('home_theme', 'classic');

      expect(
        logs.at(LogLevel.debug).where((line) => line.contains('not a known')),
        [
          '"new_home_screen" is not a known flag: the caller\'s default',
          '"home_theme" is not a known flag: the caller\'s default',
        ],
      );
    });

    test('clearing it changes no value: nothing to report', () async {
      final changes = <Set<String>>[];
      final subscription = client.changes.listen(changes.add);
      addTearDown(subscription.cancel);

      await client.clearCache();
      await pumpEventQueue();

      expect(changes, isEmpty);
    });
  });

  group('a cached config', () {
    setUp(() async {
      await seedCache(db, [
        definition('new_home_screen'),
        definition(
          'home_theme',
          value: const StringValue('modern'),
          offValue: const StringValue('classic'),
          enabled: false,
        ),
        definition('feed_page_size', value: const IntValue(30)),
        definition('home_config', value: JsonValue(const {'banner': 'Sale'})),
      ]);
      await start();
    });

    test('reads come from the cache, at once', () {
      expect(client.isEnabled('new_home_screen'), isTrue);
      expect(client.getInt('feed_page_size', 20), 30);
      expect(client.getJson('home_config', const {}), {'banner': 'Sale'});
      expect(
        client.detail('new_home_screen'),
        const FlagDetail(
          key: 'new_home_screen',
          value: BoolValue(true),
          source: FlagSource.cache,
          reason: EvaluationReason.fallthrough,
        ),
      );
    });

    test('a flag switched off serves its off value', () {
      expect(client.getString('home_theme', 'ocean'), 'classic');
      expect(client.detail('home_theme').reason, EvaluationReason.off);
    });

    test('an int flag read as a double widens', () {
      expect(client.getDouble('feed_page_size', 0), 30.0);
    });

    test('a wrong-typed read: the default, logged once', () {
      for (var i = 0; i < 3; i++) {
        expect(client.getString('feed_page_size', '20'), '20');
      }

      expect(
        client.detail('feed_page_size').reason,
        EvaluationReason.fallthrough,
        reason: 'detail() takes the flag as it is',
      );
      expect(logs.at(LogLevel.warning), [
        '"feed_page_size" is a int flag, read as string: the caller\'s default',
      ]);
    });

    test('clearCache: every cached flag changes; defaults after', () async {
      final changes = <Set<String>>[];
      final subscription = client.changes.listen(changes.add);
      addTearDown(subscription.cancel);

      await client.clearCache();
      await pumpEventQueue();

      expect(changes, [
        {'new_home_screen', 'home_theme', 'feed_page_size', 'home_config'},
      ]);
      expect(client.getInt('feed_page_size', 20), 20);
      expect(
        client.detail('new_home_screen').reason,
        EvaluationReason.flagNotFound,
      );
    });
  });

  group('debug stats', () {
    test('an empty cache: empty, no flags, the anonymous id', () async {
      await start();

      expect(
        await client.debug.watchStats().first,
        const FlagKitStats(
          cacheStatus: CacheStatus.empty,
          flagCount: 0,
          anonymousId: 'id-1',
        ),
      );
    });

    test(
      'a cache fetched two hours ago: stale, with its count and version',
      () async {
        await seedCache(
          db,
          [definition('a'), definition('b')],
          fetchedAt: testNow.subtract(const Duration(hours: 2)),
          configVersion: 7,
        );
        await start();

        final stats = await client.debug.watchStats().first;
        expect(stats.cacheStatus, CacheStatus.stale);
        expect(stats.flagCount, 2);
        expect(stats.configVersion, 7);
        expect(stats.fetchedAt, testNow.subtract(const Duration(hours: 2)));
      },
    );

    test('they update when the cache is cleared', () async {
      await seedCache(db, [definition('a')]);
      await start();
      final stats = client.debug.watchStats();
      final seen = expectLater(
        stats.map((s) => s.cacheStatus),
        emitsInOrder([CacheStatus.fresh, CacheStatus.empty]),
      );

      await pumpEventQueue();
      await client.clearCache();

      await seen;
    });
  });

  test(
    'a database that can\'t be opened: memory for this session, logged',
    () async {
      final broken = FlagKitDatabase(
        NativeDatabase(File('/nonexistent-dir/flagkit.sqlite')),
      );
      client = await openTestClient(database: broken, logs: logs);

      expect(client.getInt('feed_page_size', 20), 20);
      expect(await client.debug.watchStats().first, isA<FlagKitStats>());
      expect(logs.at(LogLevel.error).single, contains('in memory'));
    },
  );

  group('the context', () {
    setUp(start);

    test('is kept; setting the same one again is no change', () {
      const context = EvaluationContext(userId: 'user_123', country: 'PK');
      client
        ..setContext(context)
        ..setContext(
          const EvaluationContext(userId: 'user_123', country: 'PK'),
        );

      expect(client.context, context);
      expect(
        logs.at(LogLevel.debug).where((line) => line.startsWith('context:')),
        hasLength(1),
      );
    });
  });

  test('refresh has nothing to fetch from yet, and says so', () async {
    await start();
    expect(await client.refresh(), isA<Failed>());
  });

  test('after shutdown: defaults with notInitialized; calls ignored', () async {
    await seedCache(db, [definition('k')]);
    await start();
    final changes = expectLater(client.changes, emitsDone);
    await client.shutdown();
    await changes;

    expect(client.isEnabled('k'), isFalse);
    expect(client.detail('k').reason, EvaluationReason.notInitialized);
    expect(await client.refresh(), const NotInitialized());
    client.setContext(const EvaluationContext(userId: 'x'));
    await client.clearCache();
    expect(client.context, const EvaluationContext());
    expect(logs.at(LogLevel.warning), hasLength(2));
    // A second shutdown is harmless.
    await client.shutdown();
  });
}
