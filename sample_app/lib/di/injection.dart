import 'package:flagkit_sample/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// The app's single service locator.
///
/// Only the bootstrap, the router and Page widgets resolve dependencies
/// from it. Everything else receives them through its constructor, so
/// tests can pass fakes directly.
final GetIt getIt = GetIt.instance;

/// Composition root: the one place where concrete implementations are chosen
/// and wired together (the role of Hilt modules in the Android edition).
///
/// `injectable` generates `getIt.init()` from the annotations under `lib/`.
/// Asynchronous, because the demo server reads its flags from an asset.
@InjectableInit()
Future<GetIt> configureDependencies() => getIt.init();
