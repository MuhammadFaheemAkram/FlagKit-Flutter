import 'package:flutter/foundation.dart';

/// What a refresh did. `FlagKit.refresh()` returns one instead of
/// throwing: a failed refresh leaves the flags as they were, and the app
/// decides whether to tell anyone.
///
/// Sealed and complete from the first version, so a host's `switch` over
/// it stays exhaustive as the SDK grows.
@immutable
sealed class RefreshResult {
  const RefreshResult();
}

/// New definitions arrived and replaced the old ones.
final class Updated extends RefreshResult {
  /// New definitions arrived: which flags were [added], [changed] or
  /// [removed], and how many the SDK [skipped] as invalid.
  const Updated({
    this.added = const {},
    this.changed = const {},
    this.removed = const {},
    this.skipped = 0,
  });

  /// The keys of flags the server sent for the first time.
  final Set<String> added;

  /// The keys of flags whose definition changed.
  final Set<String> changed;

  /// The keys of flags the server no longer sends.
  final Set<String> removed;

  /// How many definitions were invalid and left out (logged in debug mode).
  final int skipped;

  @override
  bool operator ==(Object other) =>
      other is Updated &&
      setEquals(other.added, added) &&
      setEquals(other.changed, changed) &&
      setEquals(other.removed, removed) &&
      other.skipped == skipped;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(added),
    Object.hashAllUnordered(changed),
    Object.hashAllUnordered(removed),
    skipped,
  );

  @override
  String toString() =>
      'Updated(added: $added, changed: $changed, removed: $removed, '
      'skipped: $skipped)';
}

/// The server's definitions are the ones FlagKit already has.
final class NotModified extends RefreshResult {
  /// Nothing changed on the server.
  const NotModified();

  @override
  bool operator ==(Object other) => other is NotModified;

  @override
  int get hashCode => (NotModified).hashCode;

  @override
  String toString() => 'NotModified()';
}

/// The device is offline: nothing was attempted.
final class Offline extends RefreshResult {
  /// The device is offline.
  const Offline();

  @override
  bool operator ==(Object other) => other is Offline;

  @override
  int get hashCode => (Offline).hashCode;

  @override
  String toString() => 'Offline()';
}

/// The refresh failed; the flags are as they were.
final class Failed extends RefreshResult {
  /// The refresh failed, for [reason].
  const Failed({required this.reason});

  /// Why, in words (for a log or a debug screen).
  final String reason;

  @override
  bool operator ==(Object other) => other is Failed && other.reason == reason;

  @override
  int get hashCode => Object.hash(Failed, reason);

  @override
  String toString() => 'Failed($reason)';
}

/// The server rejected the API key. Automatic refreshes pause until the
/// next `initialize`; the flags are as they were.
final class Unauthorized extends RefreshResult {
  /// The server rejected the API key.
  const Unauthorized();

  @override
  bool operator ==(Object other) => other is Unauthorized;

  @override
  int get hashCode => (Unauthorized).hashCode;

  @override
  String toString() => 'Unauthorized()';
}

/// FlagKit isn't running (before `initialize`, or after `shutdown`).
final class NotInitialized extends RefreshResult {
  /// FlagKit isn't running.
  const NotInitialized();

  @override
  bool operator ==(Object other) => other is NotInitialized;

  @override
  int get hashCode => (NotInitialized).hashCode;

  @override
  String toString() => 'NotInitialized()';
}
