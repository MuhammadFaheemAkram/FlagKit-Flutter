import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';

import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/sdk.dart';

void main() {
  late FlagKitDatabase db;
  late ScriptedTransport transport;
  late FakeAppLifecycle lifecycle;
  FlagKitClientImpl? client;

  setUp(() {
    db = FlagKitDatabase.inMemory();
    transport = ScriptedTransport()
      ..config = wireConfig(version: 2, [
        wireFlag('new_home_screen'),
        wireFlag('feed_page_size', type: 'int', value: 30, offValue: 20),
      ]);
    lifecycle = FakeAppLifecycle();
  });
  tearDown(() async => client?.shutdown());

  Future<FlagKitClientImpl> open({
    Duration startupWait = Duration.zero,
  }) async => client = await openTestClient(
    database: db,
    lifecycle: lifecycle,
    config: testConfig(transport: transport, startupWait: startupWait),
  );

  group('at start', () {
    test('an empty cache is refreshed at once', () async {
      await open();
      await pumpEventQueue();

      expect(transport.requests, hasLength(1));
      expect(client!.getInt('feed_page_size', 20), 30);
      expect(client!.detail('feed_page_size').source, FlagSource.remote);
    });

    test('a fresh cache asks nothing', () async {
      await seedCache(db, [definition('new_home_screen')]);
      await open();
      await pumpEventQueue();

      expect(transport.requests, isEmpty);
      expect(client!.detail('new_home_screen').source, FlagSource.cache);
    });

    test('a stale cache is refreshed, sending its version', () async {
      await seedCache(db, [
        definition('new_home_screen'),
      ], fetchedAt: testNow.subtract(const Duration(hours: 2)));
      await open();
      await pumpEventQueue();

      expect(transport.requests.single.ifVersion, 1);
    });
  });

  group('startupWait', () {
    test('an empty cache: initialize waits for the first fetch', () async {
      await open(startupWait: const Duration(seconds: 5));

      // No pump: the value is there when initialize returns.
      expect(client!.getInt('feed_page_size', 20), 30);
    });

    test(
      'a fetch slower than the wait: initialize goes on with defaults',
      () async {
        transport.gate = Completer<void>();
        final stopwatch = Stopwatch()..start();
        await open(startupWait: const Duration(milliseconds: 50));

        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
        expect(client!.getInt('feed_page_size', 20), 20);

        final changed = client!.changes.first;
        transport.gate!.complete();
        expect(await changed, {'new_home_screen', 'feed_page_size'});
        expect(client!.getInt('feed_page_size', 20), 30);
      },
    );

    test('a cache: initialize never waits', () async {
      await seedCache(db, [
        definition('feed_page_size', value: const IntValue(25)),
      ], fetchedAt: testNow.subtract(const Duration(hours: 2)));
      transport.gate = Completer<void>();

      await open(startupWait: const Duration(seconds: 30));

      expect(client!.getInt('feed_page_size', 20), 25);
      transport.gate!.complete();
    });
  });

  group('refresh()', () {
    setUp(() async {
      await open();
      await pumpEventQueue();
    });

    test('reports the flags whose value changed', () async {
      final changes = <Set<String>>[];
      final subscription = client!.changes.listen(changes.add);
      addTearDown(subscription.cancel);
      transport.config = wireConfig(version: 3, [
        wireFlag('new_home_screen', enabled: false),
        wireFlag('feed_page_size', type: 'int', value: 30, offValue: 20),
      ]);

      final result = await client!.refresh();
      await pumpEventQueue();

      expect(result, const Updated(changed: {'new_home_screen'}));
      expect(changes, [
        {'new_home_screen'},
      ]);
      expect(client!.isEnabled('new_home_screen', true), isFalse);
    });

    test('nothing new: nothing reported', () async {
      final changes = <Set<String>>[];
      final subscription = client!.changes.listen(changes.add);
      addTearDown(subscription.cancel);
      transport.then(const ConfigNotModified());

      expect(await client!.refresh(), const NotModified());
      await pumpEventQueue();

      expect(changes, isEmpty);
    });

    test('joined refreshes report once', () async {
      final changes = <Set<String>>[];
      final subscription = client!.changes.listen(changes.add);
      addTearDown(subscription.cancel);
      transport
        ..config = wireConfig(version: 9, [wireFlag('new_home_screen')])
        ..gate = Completer<void>();

      final first = client!.refresh();
      final second = client!.refresh();
      transport.gate!.complete();
      await Future.wait([first, second]);
      await pumpEventQueue();

      expect(changes, [
        {'feed_page_size'},
      ]);
    });

    test('reads during a refresh see the old flags, whole', () async {
      transport
        ..config = wireConfig(version: 9, [
          wireFlag('feed_page_size', type: 'int', value: 50, offValue: 20),
        ])
        ..gate = Completer<void>();

      final refreshing = client!.refresh();
      await pumpEventQueue();
      expect(client!.getInt('feed_page_size', 20), 30);
      expect(client!.isEnabled('new_home_screen'), isTrue);

      transport.gate!.complete();
      await refreshing;
      expect(client!.getInt('feed_page_size', 20), 50);
      expect(client!.isEnabled('new_home_screen'), isFalse);
    });
  });

  test('the flags survive a restart, from the cache', () async {
    final dir = await Directory.systemTemp.createTemp('flagkit');
    addTearDown(() => dir.delete(recursive: true));
    FlagKitDatabase file() =>
        FlagKitDatabase(NativeDatabase(File('${dir.path}/flagkit.sqlite')));

    final first = await openTestClient(
      database: file(),
      config: testConfig(transport: transport),
    );
    await pumpEventQueue();
    expect(first.detail('feed_page_size').source, FlagSource.remote);
    await first.shutdown();

    // Offline this time: whatever it reads comes from the file.
    client = await openTestClient(
      database: file(),
      config: testConfig(monitor: FakeNetworkMonitor(online: false)),
    );

    expect(client!.getInt('feed_page_size', 20), 30);
    expect(client!.detail('feed_page_size').source, FlagSource.cache);
  });

  test('shutdown waits for a refresh in flight, then closes', () async {
    await seedCache(db, [definition('a')]);
    await open();
    transport.gate = Completer<void>();
    final refreshing = client!.refresh();
    await pumpEventQueue();

    var closed = false;
    final closing = client!.shutdown().then((_) => closed = true);
    await pumpEventQueue();
    expect(closed, isFalse, reason: 'the refresh is still in flight');

    transport.gate!.complete();
    await closing;

    // The refresh finished against an open database: it stored its flags.
    expect(await refreshing, isA<Updated>());
    expect(lifecycle.disposed, isTrue);
    client = null;
  });

  test('a reconnect with a stale cache refreshes', () async {
    final monitor = FakeNetworkMonitor(online: false);
    await seedCache(db, [
      definition('a'),
    ], fetchedAt: testNow.subtract(const Duration(hours: 2)));
    client = await openTestClient(
      database: db,
      lifecycle: lifecycle,
      config: testConfig(transport: transport, monitor: monitor),
    );
    await pumpEventQueue();
    expect(transport.requests, isEmpty);

    monitor.online = true;
    await pumpEventQueue();

    expect(transport.requests, hasLength(1));
    expect(client!.isEnabled('new_home_screen'), isTrue);
  });

  test('back in the foreground with a stale cache refreshes', () async {
    var now = testNow;
    await seedCache(db, [definition('a')]);
    client = await openTestClient(
      database: db,
      lifecycle: lifecycle,
      now: () => now,
      config: testConfig(transport: transport),
    );
    await pumpEventQueue();
    expect(transport.requests, isEmpty, reason: 'fresh at start');

    lifecycle.foreground = false;
    now = testNow.add(const Duration(hours: 2));
    lifecycle.foreground = true;
    await pumpEventQueue();

    expect(transport.requests, hasLength(1));
    expect(client!.isEnabled('new_home_screen'), isTrue);
  });

  test('back in the foreground with a fresh cache asks nothing', () async {
    await seedCache(db, [definition('a')]);
    await open();
    lifecycle
      ..foreground = false
      ..foreground = true;
    await pumpEventQueue();

    expect(transport.requests, isEmpty);
  });
}
