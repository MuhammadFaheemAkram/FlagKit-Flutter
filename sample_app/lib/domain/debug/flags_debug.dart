import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flutter/foundation.dart';

export 'package:flagkit_sample/domain/flags/flag_reading.dart';

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

  /// Forgets the cached flags (not the overrides, nor the install id).
  Future<void> clearCache();

  /// The newest refreshes, newest first: now, then after each one.
  Stream<List<LastRefresh>> watchRefreshLog();

  /// Everything behind [key]'s value, or `null` for a flag FlagKit knows
  /// nothing of (no definition, no override).
  FlagInspection? inspect(String key);

  /// What every flag would be for [userId], the rest of the context as it
  /// is now: "try a user", without changing who the app is for.
  List<FlagReading> readFor(String userId);

  /// Overrides [key] on this device with [text], read as the flag's kind
  /// (`true` / `false` for an on/off flag). Returns what's wrong with
  /// [text], in words, or `null` once the override is set.
  Future<String?> setOverride(String key, String text);

  /// Removes [key]'s override.
  Future<void> clearOverride(String key);

  /// Removes every override.
  Future<void> clearOverrides();
}

/// One flag, explained in full: the Dashboard's detail page.
@immutable
final class FlagInspection {
  const FlagInspection({
    required this.reading,
    this.serverValue,
    this.offValue,
    this.enabled,
    this.rules = const [],
    this.overrideValue,
  });

  /// The value the app gets, where from and why (with the bucket for a
  /// rollout).
  final FlagReading reading;

  /// The server's value (served when the flag applies), as text, when
  /// FlagKit has a definition.
  final String? serverValue;

  /// The server's off value, as text, when FlagKit has a definition.
  final String? offValue;

  /// The kill switch, when FlagKit has a definition.
  final bool? enabled;

  /// Each targeting rule, and whether the current user matches it.
  final List<RuleCheck> rules;

  /// The local override, as text, if one is set.
  final String? overrideValue;

  /// Whether FlagKit has the server's definition (an override can exist
  /// without one).
  bool get defined => enabled != null;

  @override
  bool operator ==(Object other) =>
      other is FlagInspection &&
      other.reading == reading &&
      other.serverValue == serverValue &&
      other.offValue == offValue &&
      other.enabled == enabled &&
      listEquals(other.rules, rules) &&
      other.overrideValue == overrideValue;

  @override
  int get hashCode => Object.hash(
    reading,
    serverValue,
    offValue,
    enabled,
    Object.hashAll(rules),
    overrideValue,
  );
}

/// A targeting rule in words, and whether the current user matches it.
@immutable
final class RuleCheck {
  const RuleCheck(this.text, {required this.matched});

  /// The rule: "country is one of PK, AE".
  final String text;
  final bool matched;

  @override
  bool operator ==(Object other) =>
      other is RuleCheck && other.text == text && other.matched == matched;

  @override
  int get hashCode => Object.hash(text, matched);

  @override
  String toString() => 'RuleCheck($text, $matched)';
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
    this.configVersion,
    this.overrideCount = 0,
    this.refreshing = false,
    this.reads = const {},
    this.refreshes = 0,
    this.failedRefreshes = 0,
    this.skippedDefinitions = 0,
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

  /// The server's version of the cached flags, if known.
  final int? configVersion;

  /// How many local overrides are set.
  final int overrideCount;

  /// Whether a refresh is running (any: a tap, a timer, a reconnect).
  final bool refreshing;

  /// This session's reads, by where their value came from.
  final Map<ReadingSource, int> reads;

  /// Refreshes on this install, ever; how many failed; how many invalid
  /// definitions they left out.
  final int refreshes;
  final int failedRefreshes;
  final int skippedDefinitions;

  @override
  bool operator ==(Object other) =>
      other is CacheInfo &&
      other.lastRefresh == lastRefresh &&
      other.state == state &&
      other.flagCount == flagCount &&
      other.installId == installId &&
      other.fetchedAt == fetchedAt &&
      other.configVersion == configVersion &&
      other.overrideCount == overrideCount &&
      other.refreshing == refreshing &&
      mapEquals(other.reads, reads) &&
      other.refreshes == refreshes &&
      other.failedRefreshes == failedRefreshes &&
      other.skippedDefinitions == skippedDefinitions;

  @override
  int get hashCode => Object.hash(
    state,
    flagCount,
    installId,
    fetchedAt,
    lastRefresh,
    configVersion,
    overrideCount,
    refreshing,
    Object.hashAllUnordered(
      reads.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    refreshes,
    failedRefreshes,
    skippedDefinitions,
  );

  @override
  String toString() => 'CacheInfo($state, $flagCount flags, $fetchedAt)';
}
