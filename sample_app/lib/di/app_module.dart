import 'package:flagkit/flagkit.dart';
import 'package:injectable/injectable.dart';

/// Registrations for objects the app doesn't construct itself.
@module
abstract class AppModule {
  /// The SDK's client, started in `main()` with `FlagKit.initialize`
  /// before anything resolves it. Registering it lets the adapters receive
  /// it through their constructors, like any other dependency.
  @lazySingleton
  FlagKitClient get flagKit => FlagKit.instance;
}
