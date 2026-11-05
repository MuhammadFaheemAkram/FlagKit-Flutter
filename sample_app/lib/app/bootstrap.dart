import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/app/sample_flagkit_config.dart';
import 'package:flagkit_sample/data/network/demo_network_monitor.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';

/// Everything the app does before its first frame, in order. `main()`
/// calls it, and so do the tests, so what they start is what ships.
///
/// [beforeStart] runs between the graph and the SDK: the one point a test
/// may swap a registration (the device's network, the server's latency)
/// before the SDK is given them. The app passes nothing.
Future<void> bootstrap({void Function()? beforeStart}) async {
  // The graph first (nothing in it starts the SDK: the client is resolved
  // lazily), so the SDK can be given the app's server and network monitor.
  await configureDependencies();
  beforeStart?.call();
  // The SDK before the first screen, as the README tells every host app:
  // the first frame's reads then have the cached flags (or, on a first
  // launch, the server's, within startupWait).
  await FlagKit.initialize(
    sampleFlagKitConfig(
      transport: getIt<FakeRemoteConfigServer>(),
      networkMonitor: getIt<DemoNetworkMonitor>(),
    ),
  );
  // Who the app starts as: resolving the user context gives the SDK its
  // evaluation context before any screen reads a flag.
  getIt<UserContext>();
}
