import 'package:flagkit/src/model/refresh_record.dart';
import 'package:flagkit/src/storage/flagkit_database.dart';
import 'package:meta/meta.dart';

/// A log row as the public record. The `CHECK`s keep the names known.
@internal
extension RefreshRowMapper on RefreshRow {
  RefreshRecord toRecord() => RefreshRecord(
    trigger: RefreshTrigger.values.byName(trigger),
    startedAt: startedAt.toUtc(),
    finishedAt: finishedAt.toUtc(),
    outcome: RefreshOutcome.values.byName(outcome),
    added: added,
    changed: changed,
    removed: removed,
    skipped: skipped,
    configVersion: configVersion,
    error: error,
  );
}
