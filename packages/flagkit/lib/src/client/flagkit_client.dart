import 'package:flagkit/src/client/flagkit_client_impl.dart';
import 'package:flagkit/src/config/flagkit_config.dart';
import 'package:flagkit/src/model/evaluation_context.dart';
import 'package:flagkit/src/model/flag_detail.dart';
import 'package:flagkit/src/model/flag_value.dart';
import 'package:flagkit/src/model/refresh_result.dart';

/// The SDK as an object: what the `FlagKit` facade forwards to.
///
/// Most apps use the facade. An app with dependency injection can register
/// the client instead (`FlagKit.instance`, or one from [create]) and depend
/// on this interface, so its tests can pass a fake.
///
/// **Reads are synchronous and never throw.** They answer from flags held
/// in memory and never wait for the disk or the network; when there is no
/// value of the right type, they return the caller's default. The async
/// methods report their outcome instead of throwing.
abstract interface class FlagKitClient {
  /// Starts a client with [config].
  ///
  /// Throws an [ArgumentError] if [config] breaks a rule: a developer's
  /// mistake, reported in development rather than hidden.
  static Future<FlagKitClient> create(FlagKitConfig config) async {
    config.validate();
    // The composition root: the SDK has no DI container (it would become
    // every host's dependency), so the parts are wired by hand, in `open`.
    return FlagKitClientImpl.open(config);
  }

  /// Whether the boolean flag [key] is on; [defaultValue] if there is no
  /// boolean value for it.
  bool isEnabled(String key, [bool defaultValue = false]);

  /// The string flag [key]; [defaultValue] if there is no string for it.
  String getString(String key, String defaultValue);

  /// The integer flag [key]; [defaultValue] if there is no integer for it.
  int getInt(String key, int defaultValue);

  /// The decimal flag [key] (an integer flag widens); [defaultValue] if
  /// there is no number for it.
  double getDouble(String key, double defaultValue);

  /// The JSON flag [key], unmodifiable; [defaultValue] if there is no JSON
  /// object for it.
  Map<String, Object?> getJson(String key, Map<String, Object?> defaultValue);

  /// The flag [key]'s value, whatever its type, or `null` if there is none.
  FlagValue? getValue(String key);

  /// The flag [key]'s value with where it came from and why.
  FlagDetail detail(String key);

  /// Who is asking: what targeting and rollouts evaluate against.
  EvaluationContext get context;

  /// Changes who is asking. Reads use the new context at once, and
  /// [changes] reports the flags whose value changed.
  void setContext(EvaluationContext context);

  /// The keys of flags whose evaluated value changed: after a refresh, a
  /// context change or a cleared cache. Listen to rebuild what reads them.
  Stream<Set<String>> get changes;

  /// Fetches the flags from the server now, and says what happened.
  Future<RefreshResult> refresh();

  /// Forgets the cached flags: reads return the callers' defaults until the
  /// next refresh.
  Future<void> clearCache();

  /// Stops the client. Later reads return the callers' defaults.
  Future<void> shutdown();
}
