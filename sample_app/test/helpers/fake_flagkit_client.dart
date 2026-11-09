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

  /// A rolled-out key's bucket and percentage, as its detail reports them.
  final rollouts = <String, (int, double)>{};

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
    final rollout = rollouts[key];
    return FlagDetail(
      key: key,
      value: value,
      source: source,
      reason: reason,
      bucket: rollout?.$1,
      rolloutPercent: rollout?.$2,
    );
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

  /// What [refresh] returns.
  RefreshResult refreshResult = const NotModified();

  @override
  Future<RefreshResult> refresh() async => refreshResult;

  @override
  Future<void> clearCache() async {}

  @override
  late final FakeFlagKitDebug debug = FakeFlagKitDebug(this);

  @override
  Future<void> shutdown() async {
    await _changes.close();
    await debug.close();
  }
}

/// [FlagKitDebug] whose stats and flag lists a test sends; its answers
/// for one flag are the client's, and overrides are only recorded.
final class FakeFlagKitDebug implements FlagKitDebug {
  FakeFlagKitDebug(this._client);

  final FakeFlagKitClient _client;
  final _stats = StreamController<FlagKitStats>.broadcast();
  final _flags = StreamController<List<FlagDetail>>.broadcast();

  /// Sends [flags] to `watchFlags` listeners.
  void emitFlags([List<FlagDetail> flags = const []]) => _flags.add(flags);

  @override
  Stream<List<FlagDetail>> watchFlags() => _flags.stream;

  @override
  List<FeatureFlag> definitions = [];

  /// Every context `evaluateFor` was asked about.
  final asked = <EvaluationContext>[];

  @override
  FlagDetail evaluateFor(String key, EvaluationContext context) {
    asked.add(context);
    return _client.detail(key);
  }

  @override
  FlagExplanation explain(String key, {EvaluationContext? context}) =>
      FlagExplanation(
        detail: _client.detail(key),
        context: context ?? _client.context,
        flag: definitions.where((flag) => flag.key == key).firstOrNull,
        overrideValue: overrides[key],
      );

  /// The overrides set, by key.
  final overrides = <String, FlagValue>{};

  @override
  Future<void> setOverride(String key, FlagValue value) async =>
      overrides[key] = value;

  @override
  Future<void> clearOverride(String key) async => overrides.remove(key);

  @override
  Future<void> clearOverrides() async => overrides.clear();

  /// Sends [stats] to the listeners.
  void emit(FlagKitStats stats) => _stats.add(stats);

  @override
  Stream<FlagKitStats> watchStats() => _stats.stream;

  @override
  Stream<List<RefreshRecord>> watchRefreshes({int limit = 10}) =>
      const Stream.empty();

  Future<void> close() async {
    await _stats.close();
    await _flags.close();
  }
}
