import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:flagkit/src/storage/meta_keys.dart';
import 'package:flagkit/src/storage/refresh_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sdk.dart';

void main() {
  late FlagKitDatabase db;

  setUp(() => db = FlagKitDatabase.inMemory());
  tearDown(() => db.close());

  FlagRow row(String key, {String type = 'boolean', String value = 'true'}) =>
      FlagRow(
        key: key,
        type: type,
        value: value,
        offValue: value,
        enabled: true,
        rules: '[]',
        updatedAt: testNow,
      );

  test('the current schema version is exported, with every table', () {
    final file = File('drift_schemas/flagkit_database/drift_schema_v3.json');
    final schema = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    final entities = (schema['entities']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((e) => (e['data']! as Map<String, Object?>)['name']);

    expect(db.schemaVersion, 3);
    expect(entities, containsAll(['flags', 'meta', 'refreshes', 'overrides']));
  });

  group('the CHECKs refuse a broken row', () {
    Future<void> insert(String values) => db.customStatement(
      'INSERT INTO flags (key, type, value, off_value, enabled, rollout_bp, '
      'rules, updated_at) VALUES ($values)',
    );
    const good =
        "'k', 'boolean', 'true', 'false', 1, NULL, '[]', '2026-11-04T09:41:00.000Z'";

    test('a valid row is accepted', () async {
      await insert(good);
      expect(await db.flagDao.all(), hasLength(1));
    });

    for (final (name, values) in [
      ('a blank key', good.replaceFirst("'k'", "''")),
      ('a 65-character key', good.replaceFirst("'k'", "'${'k' * 65}'")),
      ('an unknown type', good.replaceFirst("'boolean'", "'date'")),
      ('a value that isn\'t JSON', good.replaceFirst("'true'", "'yes'")),
      ('an off value that isn\'t JSON', good.replaceFirst("'false'", "'no'")),
      ('a rollout above 100 %', good.replaceFirst('NULL', '10001')),
      ('a negative rollout', good.replaceFirst('NULL', '-1')),
      ('rules that aren\'t a list', good.replaceFirst("'[]'", "'{}'")),
      ('a local time', good.replaceFirst('.000Z', '.000')),
    ]) {
      test(name, () {
        expect(insert(values), throwsA(isA<Exception>()));
      });
    }
  });

  group('the overrides\' CHECKs refuse a broken row', () {
    Future<void> insert(String values) => db.customStatement(
      'INSERT INTO overrides (key, type, value, created_at) VALUES ($values)',
    );
    const good = "'k', 'int', '5', '2026-11-09T09:41:00.000Z'";

    test('a valid row is accepted', () async {
      await insert(good);
      expect(await db.overrideDao.all(), hasLength(1));
    });

    for (final (name, values) in [
      ('a blank key', good.replaceFirst("'k'", "''")),
      ('an unknown type', good.replaceFirst("'int'", "'date'")),
      ('a value that isn\'t JSON', good.replaceFirst("'5'", "'five'")),
      ('a local time', good.replaceFirst('.000Z', '.000')),
    ]) {
      test(name, () {
        expect(insert(values), throwsA(isA<Exception>()));
      });
    }
  });

  group('refresh counters', () {
    Future<int?> counter(String name) async =>
        int.tryParse(await db.metaDao.read(name) ?? '');

    RefreshesCompanion row(String outcome, {int skipped = 0}) =>
        RefreshesCompanion.insert(
          trigger: 'manual',
          startedAt: testNow,
          finishedAt: testNow,
          outcome: outcome,
          skipped: Value(skipped),
        );

    test('count every refresh, the failures and the skipped, ever', () async {
      await db.refreshDao.add(row('updated', skipped: 2));
      await db.refreshDao.add(row('failed'));
      await db.refreshDao.add(row('unauthorized'));
      await db.refreshDao.add(row('offline'));
      await db.refreshDao.add(row('notModified', skipped: 1));

      expect(await counter(MetaKeys.refreshTotal), 5);
      expect(await counter(MetaKeys.refreshFailedTotal), 2);
      expect(await counter(MetaKeys.skippedTotal), 3);
    });

    test('outlive the log it trims', () async {
      for (var i = 0; i < RefreshDao.keep + 5; i++) {
        await db.refreshDao.add(row('updated'));
      }

      expect(await db.refreshDao.newest(), hasLength(RefreshDao.keep));
      expect(await counter(MetaKeys.refreshTotal), RefreshDao.keep + 5);
    });
  });

  group('flags', () {
    test('save, read by key, read all in key order', () async {
      await db.flagDao.save(row('b'));
      await db.flagDao.save(row('a'));

      expect((await db.flagDao.all()).map((r) => r.key), ['a', 'b']);
      expect((await db.flagDao.byKey('a'))?.key, 'a');
      expect(await db.flagDao.byKey('c'), isNull);
    });

    test('saving an existing key replaces every column, nulls too', () async {
      await db.flagDao.save(row('k').copyWith(rolloutBp: const Value(2500)));
      await db.flagDao.save(row('k', type: 'int', value: '30'));

      final saved = await db.flagDao.byKey('k');
      expect(saved?.type, 'int');
      expect(saved?.value, '30');
      // An upsert that leaves NULLs unwritten would keep the old rollout
      // (conventions §11.57).
      expect(saved?.rolloutBp, isNull);
    });

    test('replaceAll keeps exactly the given rows', () async {
      await db.flagDao.save(row('gone'));
      await db.flagDao.save(row('kept', value: 'false'));

      await db.flagDao.replaceAll([row('kept'), row('new')]);

      final all = await db.flagDao.all();
      expect(all.map((r) => r.key), ['kept', 'new']);
      expect(all.first.value, 'true');
    });

    test('replaceAll with nothing empties the table', () async {
      await db.flagDao.save(row('a'));
      await db.flagDao.replaceAll(const []);

      expect(await db.flagDao.all(), isEmpty);
    });

    test('clear deletes every row, and says how many', () async {
      await db.flagDao.save(row('a'));
      await db.flagDao.save(row('b'));

      expect(await db.flagDao.clear(), 2);
      expect(await db.flagDao.all(), isEmpty);
    });
  });

  test('meta: write, read, overwrite, remove', () async {
    await db.metaDao.write('n', 'one');
    await db.metaDao.write('n', 'two');
    expect(await db.metaDao.read('n'), 'two');

    await db.metaDao.remove('n');
    expect(await db.metaDao.read('n'), isNull);
  });
}
