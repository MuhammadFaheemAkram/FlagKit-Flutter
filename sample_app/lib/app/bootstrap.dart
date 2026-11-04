import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/app/sample_flagkit_config.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/context/user_context.dart';

/// Everything the app does before its first frame, in order. `main()`
/// calls it, and so do the tests, so what they start is what ships.
Future<void> bootstrap() async {
  // The SDK starts before the first screen, as the README tells every host
  // app: the first frame's reads then have the cached flags.
  await FlagKit.initialize(sampleFlagKitConfig());
  // The graph next: its adapters receive the running client.
  configureDependencies();
  // Who the app starts as: resolving the user context gives the SDK its
  // first evaluation context, before any screen reads a flag.
  getIt<UserContext>();
}
