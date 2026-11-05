import 'package:flagkit/flagkit.dart';
import 'package:flutter/foundation.dart';

/// How the sample configures the SDK.
///
/// - `debugMode` follows the build: debug builds log every SDK decision,
///   release builds are silent.
/// - A one-minute refresh interval, so the demo shows a refresh within
///   minutes rather than hours; expired after ten.
/// - On a first launch (nothing cached), wait up to two seconds for the
///   server, so the first screen shows real values instead of defaults.
/// - The [transport] is the demo's fake server, made by the app so the
///   Dashboard can turn its knobs; the [networkMonitor] is the device's
///   network plus the Dashboard's "Device offline" switch.
FlagKitConfig sampleFlagKitConfig({
  required RemoteConfigTransport transport,
  required NetworkMonitor networkMonitor,
}) => FlagKitConfig(
  apiKey: 'demo_key',
  debugMode: kDebugMode,
  refreshInterval: const Duration(minutes: 1),
  cacheExpiration: const Duration(minutes: 10),
  startupWait: const Duration(seconds: 2),
  transport: transport,
  networkMonitor: networkMonitor,
);
