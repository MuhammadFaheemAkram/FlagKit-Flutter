import 'dart:async';

import 'package:flagkit/flagkit.dart';

/// A [FlagKitClient] a test controls: the values each key evaluates to, and
/// the changes stream. What a host's tests do when they inject the client
/// rather than start the SDK.
final class FakeFlagKitClient implements FlagKitClient {
  /// The evaluated value of each key; a missing key is the caller's
  /// default (flagNotFound).
  final values = <String, FlagValue>{};

  /// The source and reason a key's detail reports (default: from the
  /// server, on for everyone).
  final details = <String, (FlagSource, EvaluationReason)>{};

  /// Every context set, in order.
  final contexts = <EvaluationContext>[];

  final _changes = StreamController<Set<String>>.broadcast();

  /// Emits [keys] on [changes].
  void emitChanges(Set<String> keys) => _changes.add(keys);

  FlagValue? _of(String key, FlagType type) => switch (values[key]) {
    final value? when value.type == type => value,
    final IntValue value when type == FlagType.decimal => value,
    _ => null,
  };

  @override
  bool isEnabled(String key, [bool defaultValue = false]) =>
      switch (_of(key, FlagType.boolean)) {
        BoolValue(:final value) => value,
        _ => defaultValue,
      };

  @override
  String getString(String key, String defaultValue) =>
      switch (_of(key, FlagType.string)) {
        StringValue(:final value) => value,
        _ => defaultValue,
      };

  @override
  int getInt(String key, int defaultValue) =>
      switch (_of(key, FlagType.integer)) {
        IntValue(:final value) => value,
        _ => defaultValue,
      };

  @override
  double getDouble(String key, double defaultValue) =>
      switch (_of(key, FlagType.decimal)) {
        DoubleValue(:final value) => value,
        IntValue(:final value) => value.toDouble(),
        _ => defaultValue,
      };

  @override
  Map<String, Object?> getJson(String key, Map<String, Object?> defaultValue) =>
      switch (_of(key, FlagType.json)) {
        JsonValue(:final value) => value,
        _ => defaultValue,
      };

  @override
  FlagValue? getValue(String key) => values[key];

  @override
  FlagDetail detail(String key) {
    final value = values[key];
    if (value == null) {
      return FlagDetail.fallback(key, EvaluationReason.flagNotFound);
    }
    final (source, reason) =
        details[key] ?? (FlagSource.remote, EvaluationReason.fallthrough);
    return FlagDetail(key: key, value: value, source: source, reason: reason);
  }

  EvaluationContext _context = const EvaluationContext();

  @override
  EvaluationContext get context => _context;

  @override
  void setContext(EvaluationContext context) {
    _context = context;
    contexts.add(context);
  }

  @override
  Stream<Set<String>> get changes => _changes.stream;

  @override
  Future<RefreshResult> refresh() async => const NotModified();

  @override
  Future<void> clearCache() async {}

  @override
  final FakeFlagKitDebug debug = FakeFlagKitDebug();

  @override
  Future<void> shutdown() async {
    await _changes.close();
    await debug.close();
  }
}

/// [FlagKitDebug] whose stats a test sends.
final class FakeFlagKitDebug implements FlagKitDebug {
  final _stats = StreamController<FlagKitStats>.broadcast();

  /// Sends [stats] to the listeners.
  void emit(FlagKitStats stats) => _stats.add(stats);

  @override
  Stream<FlagKitStats> watchStats() => _stats.stream;

  Future<void> close() => _stats.close();
}
