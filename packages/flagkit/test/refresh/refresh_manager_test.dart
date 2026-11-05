import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/refresh/refresh_manager.dart';
import 'package:flagkit/src/repository/flag_repository.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/refresh_mapper.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flagkit/src/version.dart';
import 'package:flagkit/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/log_recorder.dart';
import '../helpers/sdk.dart';

void main() {
  late FlagKitDatabase db;
  late FlagRepository repository;
  late ScriptedTransport transport;
  late FakeNetworkMonitor monitor;
  late LogRecorder logs;
  late DateTime now;
  late RefreshManager manager;

  setUp(() async {
    db = FlagKitDatabase.inMemory();
    logs = LogRecorder();
    now = testNow;
    repository = await FlagRepository.open(
      db,
      logger: logs.logger(),
      newId: SequentialIds().call,
    );
    transport = ScriptedTransport();
    monitor = FakeNetworkMonitor();
    manager = RefreshManager(
      database: db,
      repository: repository,
      transport: transport,
      monitor: monitor,
      apiKey: 'demo_key',
      logger: logs.logger(),
      clock: Clock(() => now),
    );
  });
  tearDown(() async {
    await manager.close();
    await db.close();
  });

  Future<List<RefreshRecord>> log() async => [
    for (final row in await db.refreshDao.newest()) row.toRecord(),
  ];

  group('the first refresh', () {
    test('asks with no version, and stores what came', () async {
      transport.config = wireConfig(version: 3, [
        wireFlag('a'),
        wireFlag('b', type: 'int', value: 30, offValue: 20),
      ]);

      final result = await manager.refresh(RefreshTrigger.startup);

      expect(result, const Updated(added: {'a', 'b'}));
      expect(
        transport.requests.single,
        const FetchRequest(apiKey: 'demo_key', sdkVersion: flagKitVersion),
      );
      final snapshot = repository.snapshot;
      expect(snapshot.flags.keys, ['a', 'b']);
      expect(snapshot.source, FlagSource.remote);
      expect(snapshot.configVersion, 3);
      expect(snapshot.fetchedAt, testNow);
      expect(
        (await log()).single,
        RefreshRecord(
          trigger: RefreshTrigger.startup,
          startedAt: testNow,
          finishedAt: testNow,
          outcome: RefreshOutcome.updated,
          added: 2,
          configVersion: 3,
        ),
      );
    });
  });

  group('a later refresh', () {
    setUp(() async {
      transport.config = wireConfig(version: 3, [
        wireFlag('kept'),
        wireFlag('changed', type: 'int', value: 1, offValue: 0),
        wireFlag('removed'),
      ]);
      await manager.refresh(RefreshTrigger.startup);
    });

    test(
      'sends the cached version: not modified moves only the time',
      () async {
        transport.then(const ConfigNotModified());
        now = testNow.add(const Duration(hours: 2));

        final result = await manager.refresh(RefreshTrigger.interval);

        expect(result, const NotModified());
        expect(transport.requests.last.ifVersion, 3);
        expect(repository.snapshot.fetchedAt, now);
        expect(repository.snapshot.flags, hasLength(3));
        // Confirmed by the server in this session: no longer just the cache's.
        expect(repository.snapshot.source, FlagSource.remote);
        expect((await log()).first.outcome, RefreshOutcome.notModified);
        // The time is kept: a restart finds the cache fresh.
        final reopened = await FlagRepository.open(
          db,
          logger: FlagKitLogger.silent(),
          newId: SequentialIds().call,
        );
        expect(reopened.snapshot.fetchedAt, now);
      },
    );

    test('says what was added, changed and removed', () async {
      transport.config = wireConfig(version: 4, [
        wireFlag('kept'),
        wireFlag('changed', type: 'int', value: 2, offValue: 0),
        wireFlag('new'),
      ]);
      now = testNow.add(const Duration(minutes: 5));

      final result = await manager.refresh(RefreshTrigger.manual);

      expect(
        result,
        const Updated(
          added: {'new'},
          changed: {'changed'},
          removed: {'removed'},
        ),
      );
      expect(repository.snapshot.flags.keys, ['kept', 'changed', 'new']);
      final record = (await log()).first;
      expect(
        (record.added, record.changed, record.removed, record.configVersion),
        (1, 1, 1, 4),
      );
    });

    test('a new version with the same flags changes none', () async {
      transport.config = {...transport.config, 'version': 9};

      expect(await manager.refresh(RefreshTrigger.manual), const Updated());
      expect(repository.snapshot.configVersion, 9);
    });
  });

  test('a cache from an earlier session, confirmed: source remote', () async {
    // Flags cached by an earlier run, loaded as this run's starting point.
    await seedCache(db, [definition('a')], configVersion: 3);
    final loaded = await FlagRepository.open(
      db,
      logger: FlagKitLogger.silent(),
      newId: SequentialIds().call,
    );
    expect(loaded.snapshot.source, FlagSource.cache);
    final confirming = RefreshManager(
      database: db,
      repository: loaded,
      transport: ScriptedTransport([const ConfigNotModified()]),
      monitor: monitor,
      apiKey: 'demo_key',
      logger: FlagKitLogger.silent(),
      clock: Clock(() => now),
    );
    addTearDown(confirming.close);

    expect(
      await confirming.refresh(RefreshTrigger.startup),
      const NotModified(),
    );
    expect(loaded.snapshot.source, FlagSource.remote);
    expect(loaded.snapshot.flags.keys, ['a']);
  });

  test('invalid flags are skipped, logged, and counted', () async {
    transport.config = wireConfig([
      wireFlag('good'),
      wireFlag('bad', type: 'date'),
    ]);

    final result = await manager.refresh(RefreshTrigger.manual);

    expect(result, const Updated(added: {'good'}, skipped: 1));
    expect(logs.at(LogLevel.warning).single, contains('bad: an unknown type'));
    expect((await log()).first.skipped, 1);
  });

  group('a failure leaves the cache as it was', () {
    setUp(() async {
      transport.config = wireConfig(version: 3, [wireFlag('a')]);
      await manager.refresh(RefreshTrigger.startup);
    });

    for (final (name, Object outcome, reason) in [
      ('unreachable', const ServerUnreachable(), 'server unreachable'),
      ('a server error', const ServerFailure(503), 'server error 503'),
      (
        'a malformed config',
        const FetchedConfig({'flags': <Object?>[]}),
        'malformed config',
      ),
      ('a transport that broke its contract', StateError('boom'), 'transport'),
    ]) {
      test(name, () async {
        final before = repository.snapshot;
        transport.then(outcome);

        final result = await manager.refresh(RefreshTrigger.manual);

        expect(
          result,
          isA<Failed>().having((f) => f.reason, 'reason', contains(reason)),
        );
        expect(repository.snapshot, same(before));
        final record = (await log()).first;
        expect(record.outcome, RefreshOutcome.failed);
        expect(record.error, contains(reason));
        expect(manager.pausedByRejectedKey, isFalse);
      });
    }

    test(
      'a rejected key: Unauthorized, and automatic refreshes pause',
      () async {
        final before = repository.snapshot;
        transport.then(const ApiKeyRejected());

        expect(
          await manager.refresh(RefreshTrigger.manual),
          const Unauthorized(),
        );
        expect(repository.snapshot, same(before));
        expect(manager.pausedByRejectedKey, isTrue);
        expect((await log()).first.outcome, RefreshOutcome.unauthorized);
      },
    );
  });

  group('offline', () {
    setUp(() => monitor.online = false);

    test('nothing is attempted', () async {
      expect(await manager.refresh(RefreshTrigger.reconnect), const Offline());
      expect(transport.requests, isEmpty);
    });

    test(
      'a refresh the app asked for is logged; an automatic one isn\'t',
      () async {
        await manager.refresh(RefreshTrigger.interval);
        expect(await log(), isEmpty);

        await manager.refresh(RefreshTrigger.manual);
        expect((await log()).single.outcome, RefreshOutcome.offline);
      },
    );
  });

  test('one refresh at a time: a second call joins the first', () async {
    transport.gate = Completer<void>();
    final first = manager.refresh(RefreshTrigger.startup);
    final second = manager.refresh(RefreshTrigger.manual);
    transport.gate!.complete();

    expect(await second, await first);
    expect(transport.requests, hasLength(1));
  });

  test(
    'watchRefreshing: false, then true while one runs, then false',
    () async {
      final seen = <bool>[];
      final subscription = manager.watchRefreshing().listen(seen.add);
      addTearDown(subscription.cancel);
      transport.gate = Completer<void>();

      final refreshing = manager.refresh(RefreshTrigger.manual);
      await pumpEventQueue();
      expect(manager.isRefreshing, isTrue);
      transport.gate!.complete();
      await refreshing;
      await pumpEventQueue();

      expect(seen, [false, true, false]);
      expect(manager.isRefreshing, isFalse);
    },
  );

  test(
    'a database that fails mid-refresh: Failed, and nothing swapped',
    () async {
      final before = repository.snapshot;
      await db.close();

      final result = await manager.refresh(RefreshTrigger.manual);

      expect(
        result,
        isA<Failed>().having((f) => f.reason, 'reason', contains('storage')),
      );
      expect(repository.snapshot, same(before));
      db = FlagKitDatabase.inMemory(); // for tearDown
    },
  );

  test('the log keeps the newest 50', () async {
    monitor.online = false;
    for (var i = 0; i < 55; i++) {
      await manager.refresh(RefreshTrigger.manual);
    }

    expect(await db.refreshDao.newest(limit: 100), hasLength(50));
  });
}
