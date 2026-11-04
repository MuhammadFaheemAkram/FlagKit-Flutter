import 'package:flagkit/flagkit.dart';
import 'package:flutter/foundation.dart';

/// How the sample configures the SDK.
///
/// - `debugMode` follows the build: debug builds log every SDK decision,
///   release builds are silent.
/// - A one-minute refresh interval, so the demo shows stale flags in
///   minutes rather than hours; expired after ten.
/// - On a first launch (nothing cached), wait up to two seconds for the
///   server, so the first screen shows real values instead of defaults.
FlagKitConfig sampleFlagKitConfig() => const FlagKitConfig(
  apiKey: 'demo_key',
  debugMode: kDebugMode,
  refreshInterval: Duration(minutes: 1),
  cacheExpiration: Duration(minutes: 10),
  startupWait: Duration(seconds: 2),
);
