import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// The app on the real SDK. In 0.1.0 FlagKit knows no flags, so the app must
// work entirely on its own defaults: the classic home, the classic
// checkout, no discount, the classic look.
void main() {
  tearDown(tearDownSample);

  testWidgets('with no flags, every screen runs on the app\'s defaults', (
    tester,
  ) async {
    await pumpSample(tester);

    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('Story 20'), findsNothing, reason: 'a lazy list');
    final primary = Theme.of(tester.element(find.text('Stories')))
        .colorScheme
        .primary;
    expect(
      primary,
      AppTheme.build(
        AppThemeSpec.classic,
        Brightness.light,
      ).colorScheme.primary,
    );

    await tester.tapAndSettle(destination('Checkout'));
    expect(find.byType(Stepper), findsOneWidget);
    expect(find.textContaining('Discount'), findsNothing);

    // Tall enough for every flag's row: a lazy list builds only what shows.
    tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
    await tester.tapAndSettle(destination('Dashboard'));
    expect(find.text('FlagKit ${FlagKit.version}'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(StatusChip),
        matching: find.text('Default'),
      ),
      findsNWidgets(6),
    );
  });

  testWidgets('Profile sets the SDK\'s context', (tester) async {
    await pumpSample(tester, initialLocation: '/profile');

    await tester.enterText(find.byKey(const ValueKey('userId')), 'alex');
    await tester.pump();
    await tester.tapAndSettle(find.text('Sign in'));
    await tester.tapAndSettle(find.text('2.0.0'));

    expect(
      FlagKit.context,
      const EvaluationContext(userId: 'alex', appVersion: '2.0.0'),
    );
  });
}
