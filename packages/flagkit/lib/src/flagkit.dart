import 'dart:async';

import 'package:flagkit/src/client/flagkit_client.dart';
import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/config/flagkit_config.dart';
import 'package:flagkit/src/debug/flagkit_debug.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/evaluation_reason.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/refresh_result.dart';
import 'package:flagkit/src/util/flagkit_logger.dart';
import 'package:flagkit/src/version.dart';

/// The SDK's front door: static calls, so any widget can read a flag
/// without passing anything around.
///
/// ```dart
/// await FlagKit.initialize(const FlagKitConfig(apiKey: 'demo_key'));
/// if (FlagKit.isEnabled('new_home_screen')) { /* the new UI */ }
/// final pageSize = FlagKit.getInt('feed_page_size', 20);
/// ```
///
/// Every call forwards to one [FlagKitClient] ([instance]). **Reads never
/// throw and never wait:** before [initialize] finishes and after
/// [shutdown] they return the caller's default (reason
/// [EvaluationReason.notInitialized]), and [refresh] reports
/// [NotInitialized]. The one exception is a bad configuration, rejected at
/// [initialize].
abstract final class FlagKit {
  /// This SDK's version, sent with every fetch so the server knows which
  /// client asked.
  static const String version = flagKitVersion;

  static FlagKitClientImpl? _client;
  static Future<FlagKitClientImpl>? _starting;
  static FlagKitLogger _logger = FlagKitLogger.silent();

  // The context outlives a client: one set before `initialize` (or between
  // a shutdown and the next start) is the one the next client starts with.
  static EvaluationContext _context = const EvaluationContext();

  // One stream for the app's lifetime: a widget listening to `changes`
  // keeps listening across a shutdown and a new start. Never closed, on
  // purpose: the facade lives as long as the app.
  // ignore: close_sinks
  static final _changes = StreamController<Set<String>>.broadcast();
  static StreamSubscription<Set<String>>? _forwarding;

  /// Starts the SDK with [config]. Call it once, before `runApp`.
  ///
  /// Throws an [ArgumentError] if [config] breaks a rule. A second call
  /// while the SDK runs is ignored (with a warning in debug mode): to change
  /// the configuration, [shutdown] first. Two calls at once share one start.
  static Future<void> initialize(FlagKitConfig config) async {
    if (_client != null) {
      _logger.warning(
        'initialize() while running: ignored. Call shutdown() '
        'first to change the configuration.',
      );
      return;
    }
    // A call while a start is in flight joins it: one client, built from
    // the first caller's config.
    if (_starting case final starting?) {
      await starting;
      return;
    }
    // Checked here, before the start exists. Inside `_start` it would throw
    // before the start's first `await`, while `_start` was still running
    // synchronously: its `finally` would clear `_starting` *before* the
    // failed start was stored in it, and every later call would join that
    // failure (TrackLite's lesson).
    config.validate();
    await (_starting = _start(config));
  }

  static Future<FlagKitClientImpl> _start(FlagKitConfig config) async {
    try {
      final client = await FlagKitClientImpl.open(config)
        ..setContext(_context);
      _forwarding = client.changes.listen(_changes.add);
      // Set before the shared future completes, so whoever awaited it
      // (another initialize, or a shutdown) finds the client in place.
      _client = client;
      _logger = client.logger;
      return client;
    } finally {
      _starting = null;
    }
  }

  /// Whether the boolean flag [key] is on; [defaultValue] if there is no
  /// boolean value for it.
  static bool isEnabled(String key, [bool defaultValue = false]) =>
      _client?.isEnabled(key, defaultValue) ?? defaultValue;

  /// The string flag [key]; [defaultValue] if there is no string for it.
  static String getString(String key, String defaultValue) =>
      _client?.getString(key, defaultValue) ?? defaultValue;

  /// The integer flag [key]; [defaultValue] if there is no integer for it.
  static int getInt(String key, int defaultValue) =>
      _client?.getInt(key, defaultValue) ?? defaultValue;

  /// The decimal flag [key] (an integer flag widens); [defaultValue] if
  /// there is no number for it.
  static double getDouble(String key, double defaultValue) =>
      _client?.getDouble(key, defaultValue) ?? defaultValue;

  /// The JSON flag [key], unmodifiable; [defaultValue] if there is no JSON
  /// object for it.
  static Map<String, Object?> getJson(
    String key,
    Map<String, Object?> defaultValue,
  ) => _client?.getJson(key, defaultValue) ?? defaultValue;

  /// The flag [key]'s value, whatever its type, or `null` if there is none.
  static FlagValue? getValue(String key) => _client?.getValue(key);

  /// The flag [key]'s value with where it came from and why.
  static FlagDetail detail(String key) =>
      _client?.detail(key) ??
      FlagDetail.fallback(key, EvaluationReason.notInitialized);

  /// Who is asking: what targeting and rollouts evaluate against.
  static EvaluationContext get context => _client?.context ?? _context;

  /// Changes who is asking. Reads use the new context at once, and
  /// [changes] reports the flags whose value changed. Before [initialize],
  /// the context is kept for it.
  static void setContext(EvaluationContext context) {
    _context = context;
    _client?.setContext(context);
  }

  /// The keys of flags whose evaluated value changed: after a refresh, a
  /// context change or a cleared cache. Listen to rebuild what reads them.
  static Stream<Set<String>> get changes => _changes.stream;

  /// Fetches the flags from the server now, and says what happened.
  static Future<RefreshResult> refresh() async =>
      await _client?.refresh() ?? const NotInitialized();

  /// Forgets the cached flags: reads return the callers' defaults until the
  /// next refresh.
  static Future<void> clearCache() async => _client?.clearCache();

  /// Stops the SDK. Reads return the callers' defaults until the next
  /// [initialize].
  static Future<void> shutdown() async {
    // A start in progress finishes first, so it can't come back to life
    // after the shutdown.
    if (_starting case final starting?) {
      try {
        await starting;
      } on Object {
        // It failed, and its caller was told: nothing to stop.
      }
    }
    final client = _client;
    _client = null;
    _logger = FlagKitLogger.silent();
    await _forwarding?.cancel();
    _forwarding = null;
    await client?.shutdown();
  }

  /// The running client, for apps that inject the SDK rather than call the
  /// facade (and for their tests, which pass a fake instead).
  ///
  /// Throws a [StateError] before [initialize]: asking for the client of an
  /// SDK that isn't running is a developer's mistake.
  static FlagKitClient get instance =>
      _client ??
      (throw StateError(
        'FlagKit.instance before FlagKit.initialize() finished.',
      ));

  /// The running client's debug tools ([FlagKitClient.debug]).
  ///
  /// Throws a [StateError] before [initialize], like [instance].
  static FlagKitDebug get debug => instance.debug;
}
