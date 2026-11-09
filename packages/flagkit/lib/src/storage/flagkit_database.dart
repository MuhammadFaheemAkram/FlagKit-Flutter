import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flagkit/src/storage/flag_dao.dart';
import 'package:flagkit/src/storage/flagkit_database.steps.dart';
import 'package:flagkit/src/storage/meta_dao.dart';
import 'package:flagkit/src/storage/override_dao.dart';
import 'package:flagkit/src/storage/refresh_dao.dart';
import 'package:flagkit/src/storage/tables.dart';
import 'package:meta/meta.dart';

part 'flagkit_database.g.dart';

/// The SDK's own SQLite database, `flagkit.sqlite` in the app's documents
/// directory: never the host's database, so neither can break the other's
/// schema or migrations.
///
/// Reads never touch it: the client loads the definitions into memory once,
/// at `initialize`, and answers from there. The database is what makes the
/// flags survive a restart and work offline.
@internal
@DriftDatabase(
  tables: [Flags, MetaEntries, Refreshes, Overrides],
  daos: [FlagDao, MetaDao, RefreshDao, OverrideDao],
)
class FlagKitDatabase extends _$FlagKitDatabase {
  FlagKitDatabase(super.executor);

  /// The database on the device.
  FlagKitDatabase.onDevice() : this(driftDatabase(name: 'flagkit'));

  /// A fresh database in memory: for tests, and for a session whose file
  /// can't be opened. `closeStreamsSynchronously` lets widget tests end
  /// without waiting on drift's stream timers (conventions §11.24).
  FlagKitDatabase.inMemory()
    : this(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );

  /// A change to the schema bumps this, exports the new version
  /// (`fvm dart run drift_dev make-migrations`) and ships a tested
  /// migration: an SDK's database upgrades in place on its users' devices.
  ///
  /// 1. The cached definitions and `meta`.
  /// 2. The refresh log.
  /// 3. Local overrides.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) => m.createTable(schema.refreshes),
      from2To3: (m, schema) => m.createTable(schema.overrides),
    ),
  );

  /// What the debug stats show, as one row, in one query that watches both
  /// tables: every write to either re-runs it.
  Stream<QueryRow> watchStatsRow() => customSelect(
    '''
    SELECT
      (SELECT COUNT(*) FROM flags) AS flag_count,
      (SELECT value FROM meta WHERE name = 'fetched_at') AS fetched_at,
      (SELECT value FROM meta WHERE name = 'config_version') AS config_version,
      (SELECT value FROM meta WHERE name = 'anonymous_id') AS anonymous_id,
      (SELECT id FROM refreshes ORDER BY id DESC LIMIT 1) AS last_refresh,
      (SELECT COUNT(*) FROM overrides) AS override_count,
      (SELECT value FROM meta WHERE name = 'refresh_total') AS refresh_total,
      (SELECT value FROM meta WHERE name = 'refresh_failed_total')
        AS refresh_failed_total,
      (SELECT value FROM meta WHERE name = 'skipped_total') AS skipped_total
    ''',
    readsFrom: {flags, metaEntries, refreshes, overrides},
  ).watchSingle();
}

/// How the client opens its database: on the device, unless a host's tests
/// asked for memory (`FlagKitTesting.useInMemoryDatabase`).
@internal
FlagKitDatabase Function() openFlagKitDatabase = FlagKitDatabase.onDevice;
