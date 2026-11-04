import 'package:flagkit_sample/app/bootstrap.dart';
import 'package:flagkit_sample/app/flagkit_sample_app.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  // Bindings must exist before any setup touches plugins.
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const FlagKitSampleApp());
}
