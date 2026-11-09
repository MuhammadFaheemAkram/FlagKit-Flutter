import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/feature_flag.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_explanation.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/flagkit_stats.dart';
import 'package:flagkit/src/model/refresh_record.dart';

/// Tools for a debug screen and for support: what the SDK holds, and why.
/// Kept apart from the everyday API (`FlagKit.debug`), so an app's screens
/// never depend on them.
abstract interface class FlagKitDebug {
  /// The SDK's state now, then again after every change: the cache, the
  /// refresh log, the overrides, the network, a refresh starting or
  /// ending.
  Stream<FlagKitStats> watchStats();

  /// The newest [limit] refreshes, newest first: now, then after every
  /// refresh.
  Stream<List<RefreshRecord>> watchRefreshes({int limit = 10});

  /// Every flag the SDK can answer (each definition, and each override of
  /// a flag the server doesn't send), by key, evaluated for the current
  /// context:
  /// now, then after every refresh, context change or override, even when
  /// only a reason or a bucket changed.
  Stream<List<FlagDetail>> watchFlags();

  /// The server's definitions, as cached now, by key.
  List<FeatureFlag> get definitions;

  /// What [key] would be for [context], without changing the current one:
  /// "what would this user get?". Overrides still win: they apply to
  /// every user on this device.
  FlagDetail evaluateFor(String key, EvaluationContext context);

  /// Everything behind [key]'s answer for [context] (the current context
  /// by default): the detail, the definition, the override, and each
  /// rule with whether it matches.
  FlagExplanation explain(String key, {EvaluationContext? context});

  /// Overrides [key] with [value] on this device: it wins over the
  /// server's definition (source `override`), and is kept across restarts
  /// and `clearCache` until cleared. Throws an [ArgumentError] for a key
  /// that isn't valid, or a value of another type than the flag's.
  Future<void> setOverride(String key, FlagValue value);

  /// Removes [key]'s override.
  Future<void> clearOverride(String key);

  /// Removes every override.
  Future<void> clearOverrides();
}
