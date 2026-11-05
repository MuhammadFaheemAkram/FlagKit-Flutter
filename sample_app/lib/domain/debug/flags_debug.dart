import 'package:flutter/foundation.dart';

/// What the Dashboard knows about the SDK: the port its Cubit uses (the
/// adapter reads FlagKit).
abstract interface class FlagsDebug {
  /// The SDK's version.
  String get sdkVersion;

  /// The app's flags, each as FlagKit evaluates it right now.
  List<FlagReading> readAll();

  /// Emits whenever a reading may have changed.
  Stream<void> watch();

  /// The SDK's cache now, then after every change to it.
  Stream<CacheInfo> watchCache();

  /// Fetches the flags from the server now.
  Future<RefreshSummary> refresh();
}

/// What a refresh did, in the app's words.
enum RefreshKind { updated, upToDate, offline, failed, rejected }

/// Why a refresh ran, in the app's words.
enum RefreshCause { startup, interval, resumed, reconnect, manual }

/// A refresh's result, as the Dashboard tells it.
@immutable
final class RefreshSummary {
  const RefreshSummary(
    this.kind, {
    this.changed = 0,
    this.skipped = 0,
    this.reason,
  });

  final RefreshKind kind;

  /// How many flags were added, changed or removed.
  final int changed;

  /// How many definitions the SDK left out as invalid.
  final int skipped;

  /// Why it failed, for a failed refresh.
  final String? reason;

  @override
  bool operator ==(Object other) =>
      other is RefreshSummary &&
      other.kind == kind &&
      other.changed == changed &&
      other.skipped == skipped &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(kind, changed, skipped, reason);

  @override
  String toString() => 'RefreshSummary($kind, $changed changed)';
}

/// The latest refresh in the SDK's log.
@immutable
final class LastRefresh {
  const LastRefresh({
    required this.cause,
    required this.kind,
    required this.at,
    this.error,
  });

  final RefreshCause cause;
  final RefreshKind kind;

  /// When it finished.
  final DateTime at;

  final String? error;

  @override
  bool operator ==(Object other) =>
      other is LastRefresh &&
      other.cause == cause &&
      other.kind == kind &&
      other.at == at &&
      other.error == error;

  @override
  int get hashCode => Object.hash(cause, kind, at, error);
}

/// How fresh the SDK's cached flags are, in the app's words.
enum CacheState { fresh, stale, expired, empty }

/// The SDK's cache, as the Dashboard shows it.
@immutable
final class CacheInfo {
  const CacheInfo({
    required this.state,
    required this.flagCount,
    required this.installId,
    this.fetchedAt,
    this.lastRefresh,
  });

  final CacheState state;

  /// How many flags are cached.
  final int flagCount;

  /// This install's anonymous id: who rollouts bucket when no one is
  /// signed in.
  final String installId;

  /// When the flags were last fetched, if ever.
  final DateTime? fetchedAt;

  /// The latest refresh, if any.
  final LastRefresh? lastRefresh;

  @override
  bool operator ==(Object other) =>
      other is CacheInfo &&
      other.lastRefresh == lastRefresh &&
      other.state == state &&
      other.flagCount == flagCount &&
      other.installId == installId &&
      other.fetchedAt == fetchedAt;

  @override
  int get hashCode =>
      Object.hash(state, flagCount, installId, fetchedAt, lastRefresh);

  @override
  String toString() => 'CacheInfo($state, $flagCount flags, $fetchedAt)';
}

/// Where a reading's value came from, in the app's words.
enum ReadingSource { override, server, cache, appDefault }

/// Why a reading has its value, in the app's words.
enum ReadingReason {
  override,
  switchedOff,
  rulesMatched,
  rulesMissed,
  inRollout,
  outsideRollout,
  onForEveryone,
  notRunning,
  unknownFlag,
  wrongType,
}

/// One flag, as the Dashboard shows it.
@immutable
final class FlagReading {
  const FlagReading({
    required this.key,
    required this.value,
    required this.source,
    required this.reason,
  });

  /// The flag's key.
  final String key;

  /// The value the app gets, as text.
  final String value;

  final ReadingSource source;
  final ReadingReason reason;

  @override
  bool operator ==(Object other) =>
      other is FlagReading &&
      other.key == key &&
      other.value == value &&
      other.source == source &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(key, value, source, reason);

  @override
  String toString() => 'FlagReading($key: $value, $source, $reason)';
}
