import 'package:flutter/foundation.dart';

/// Why a refresh ran.
enum RefreshTrigger {
  /// `initialize`, with a cache that wasn't fresh.
  startup,

  /// The foreground interval (`refreshInterval`), with a cache that wasn't
  /// fresh.
  interval,

  /// The app came back to the foreground with a cache that wasn't fresh.
  resumed,

  /// The network came back with a cache that wasn't fresh.
  reconnect,

  /// `refresh()`: the app asked.
  manual,
}

/// What a refresh did, as the refresh log records it.
enum RefreshOutcome {
  /// New definitions replaced the cache.
  updated,

  /// The server had nothing new.
  notModified,

  /// The device was offline (logged for a manual refresh only).
  offline,

  /// The refresh failed; the cache stayed.
  failed,

  /// The server rejected the API key.
  unauthorized,
}

/// One refresh, as the refresh log keeps it (`FlagKit.debug`).
@immutable
final class RefreshRecord {
  /// A refresh's record.
  const RefreshRecord({
    required this.trigger,
    required this.startedAt,
    required this.finishedAt,
    required this.outcome,
    this.added = 0,
    this.changed = 0,
    this.removed = 0,
    this.skipped = 0,
    this.configVersion,
    this.error,
  });

  /// Why it ran.
  final RefreshTrigger trigger;

  /// When it started and finished (UTC).
  final DateTime startedAt;

  /// When it finished (UTC).
  final DateTime finishedAt;

  /// What came of it.
  final RefreshOutcome outcome;

  /// How many flags arrived for the first time.
  final int added;

  /// How many flags' definitions changed.
  final int changed;

  /// How many flags the server stopped sending.
  final int removed;

  /// How many definitions were invalid and left out.
  final int skipped;

  /// The server's config version, when it sent one.
  final int? configVersion;

  /// What went wrong, for a failed or rejected refresh.
  final String? error;

  @override
  bool operator ==(Object other) =>
      other is RefreshRecord &&
      other.trigger == trigger &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt &&
      other.outcome == outcome &&
      other.added == added &&
      other.changed == changed &&
      other.removed == removed &&
      other.skipped == skipped &&
      other.configVersion == configVersion &&
      other.error == error;

  @override
  int get hashCode => Object.hash(
    trigger,
    startedAt,
    finishedAt,
    outcome,
    added,
    changed,
    removed,
    skipped,
    configVersion,
    error,
  );

  @override
  String toString() =>
      'RefreshRecord(${trigger.name} → ${outcome.name}'
      '${error == null ? '' : ': $error'})';
}
