// The smallest integration: initialize once, then read flags from anywhere.
import 'package:flagkit/flagkit.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlagKit.initialize(
    const FlagKitConfig(apiKey: 'demo_key', debugMode: true),
  );
  FlagKit.setContext(
    const EvaluationContext(country: 'PK', appVersion: '2.1.0'),
  );

  if (FlagKit.isEnabled('new_home_screen')) {
    debugPrint('the new home');
  }
  final pageSize = FlagKit.getInt('feed_page_size', 20);
  final theme = FlagKit.getString('home_theme', 'classic');
  final discount = FlagKit.getDouble('discount_percentage', 0);
  debugPrint('page size $pageSize, theme $theme, discount $discount %');

  // Why a flag has its value: the source and the reason.
  debugPrint('${FlagKit.detail('new_checkout')}');

  final result = await FlagKit.refresh();
  debugPrint('refresh: $result');
  await FlagKit.shutdown();
}
