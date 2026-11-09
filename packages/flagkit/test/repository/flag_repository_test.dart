import 'package:flagkit/flagkit.dart';
import 'package:flagkit/src/repository/flag_repository.dart';
import 'package:flagkit/src/storage/flag_mapper.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/meta_keys.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/log_recorder.dart';
import '../helpers/sdk.dart';

void main() {
  late FlagKitDatabase db;
  late LogRecorder logs;

  setUp(() {
    db = FlagKitDatabase.inMemory();
    logs = LogRecorder();
  });
  tearDown(() => db.close());

  Future<FlagRepository> open({String Function()? newId}) =>
      FlagRepository.open(
        db,
        logger: logs.logger(),
        newId: newId ?? SequentialIds().call,
      );

  group('the anonymous id', () {
    test('created and stored on the first start', () async {
      final repository = await open();

      expect(repository.anonymousId, 'id-1');
      expect(await db.metaDao.read(MetaKeys.anonymousId), 'id-1');
    });

    test('the same on every later start', () async {
      await open();
      final again = await open(newId: () => 'another');

      expect(again.anonymousId, 'id-1');
    });

    test('kept by clear: clearing a cache isn\'t a new install', () async {
      final repository = await open();
      await repository.clear();

      expect((await open()).anonymousId, 'id-1');
    });
  });

  test('an empty cache: no flags, never fetched', () async {
    final snapshot = (await open()).snapshot;

    expect(snapshot.flags, isEmpty);
    expect(snapshot.fetchedAt, isNull);
    expect(snapshot.configVersion, isNull);
    expect(snapshot.source, FlagSource.cache);
  });

  group('replace', () {
    test(
      'stores the definitions, the version and the time; source remote',
      () async {
        final repository = await open();
        final a = definition('a');

        final snapshot = await repository.replace(
          definitions: [a],
          configVersion: 7,
          fetchedAt: testNow,
        );

        expect(snapshot, same(repository.snapshot));
        expect(snapshot.flags, {'a': a});
        expect(snapshot.source, FlagSource.remote);
        expect(snapshot.fetchedAt, testNow);
        expect(snapshot.configVersion, 7);
      },
    );

    test('the flags survive a restart, from the cache this time', () async {
      final repository = await open();
      final flags = [
        definition(
          'a',
          value: const IntValue(30),
          offValue: const IntValue(20),
        ),
        definition('b', enabled: false),
      ];
      await repository.replace(
        definitions: flags,
        configVersion: 3,
        fetchedAt: testNow,
      );

      final snapshot = (await open()).snapshot;

      expect(snapshot.flags.values, flags);
      expect(snapshot.source, FlagSource.cache);
      expect(snapshot.fetchedAt, testNow);
      expect(snapshot.configVersion, 3);
    });

    test('a flag the server no longer sends is gone', () async {
      final repository = await open();
      await repository.replace(
        definitions: [definition('a'), definition('b')],
        configVersion: 1,
        fetchedAt: testNow,
      );
      await repository.replace(
        definitions: [definition('b')],
        configVersion: 2,
        fetchedAt: testNow,
      );

      expect((await open()).snapshot.flags.keys, ['b']);
    });

    test('a failed write leaves the snapshot as it was', () async {
      final repository = await open();
      await repository.replace(
        definitions: [definition('a')],
        configVersion: 1,
        fetchedAt: testNow,
      );
      final before = repository.snapshot;
      await db.close();

      await expectLater(
        repository.replace(
          definitions: [definition('b')],
          configVersion: 2,
          fetchedAt: testNow,
        ),
        throwsA(anything),
      );

      expect(repository.snapshot, same(before));
      db = FlagKitDatabase.inMemory(); // for tearDown
    });
  });

  test('clear forgets the flags, the time and the version', () async {
    final repository = await open();
    await repository.replace(
      definitions: [definition('a')],
      configVersion: 4,
      fetchedAt: testNow,
    );

    await repository.clear();

    final snapshot = (await open()).snapshot;
    expect(snapshot.flags, isEmpty);
    expect(snapshot.fetchedAt, isNull);
    expect(snapshot.configVersion, isNull);
    expect(repository.snapshot.flags, isEmpty);
  });

  test('a cached row that can\'t be read is skipped, and logged', () async {
    await db.flagDao.save(definition('good').toRow());
    await db.customStatement(
      'INSERT INTO flags (key, type, value, off_value, enabled, rules, updated_at) '
      "VALUES ('bad', 'int', '\"thirty\"', '20', 1, '[]', '2026-11-04T09:41:00.000Z')",
    );

    final snapshot = (await open()).snapshot;

    expect(snapshot.flags.keys, ['good']);
    expect(logs.at(LogLevel.warning).single, contains('1 cached definitions'));
  });

  group('overrides', () {
    test('set, replaced, removed and cleared: on disk first', () async {
      final repository = await open();
      await repository.setOverride('a', const IntValue(1), testNow);
      await repository.setOverride('a', const IntValue(2), testNow);
      await repository.setOverride('b', const BoolValue(true), testNow);
      expect(repository.overrides, {
        'a': const IntValue(2),
        'b': const BoolValue(true),
      });
      expect((await open()).overrides, repository.overrides);

      await repository.removeOverride('a');
      expect((await open()).overrides.keys, ['b']);

      await repository.clearOverrides();
      expect(repository.overrides, isEmpty);
      expect((await open()).overrides, isEmpty);
    });

    test(
      'kept by clear: they\'re the developer\'s, not the server\'s',
      () async {
        final repository = await open();
        await repository.setOverride('a', const IntValue(1), testNow);

        await repository.clear();

        expect(repository.overrides, {'a': const IntValue(1)});
        expect((await open()).overrides, {'a': const IntValue(1)});
      },
    );

    test('read-only, and an unreadable row is skipped', () async {
      await db.customStatement(
        'INSERT INTO overrides (key, type, value, created_at) '
        "VALUES ('bad', 'int', '\"x\"', '2026-11-04T09:41:00.000Z')",
      );
      final repository = await open();

      expect(repository.overrides, isEmpty);
      expect(
        () => repository.overrides['a'] = const IntValue(1),
        throwsUnsupportedError,
      );
    });
  });
}
