import 'package:flagkit/flagkit.dart';
import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// The app on the real SDK and the demo's server (its flags from the asset).
void main() {
  tearDown(tearDownSample);

  /// Lets the SDK's writes and the screens' streams land, in real time.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }
  }

  Finder chip(String label) =>
      find.descendant(of: find.byType(StatusChip), matching: find.text(label));

  testWidgets('a first launch: the server\'s flags, within startupWait', (
    tester,
  ) async {
    await pumpSample(tester);

    // The new home, its banner and sections, the server's page size and
    // the modern look: no default flashed first.
    expect(find.text('Spring sale: 15.5 % off at checkout'), findsOneWidget);
    expect(find.text('Deals'), findsOneWidget);
    final primary = Theme.of(tester.element(find.text('Deals')))
        .colorScheme
        .primary;
    expect(
      primary,
      AppTheme.build(AppThemeSpec.modern, Brightness.light).colorScheme.primary,
    );

    await tester.tapAndSettle(destination('Checkout'));
    // new_checkout is switched off on the server: the classic checkout.
    expect(find.byType(Stepper), findsOneWidget);

    tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
    await tester.tapAndSettle(destination('Dashboard'));
    await settle(tester);
    expect(find.text('Fresh'), findsOneWidget);
    expect(chip('Server'), findsNWidgets(6));
    expect(find.textContaining('At start · Updated'), findsOneWidget);
  });

  testWidgets('the server switches a flag off; a refresh brings it', (
    tester,
  ) async {
    await pumpSample(tester);
    expect(find.text('Deals'), findsOneWidget);

    testServer.setEnabled('new_home_screen', false);
    await tester.tapAndSettle(destination('Dashboard'));
    await tester.tap(find.text('Refresh'));
    await settle(tester);
    expect(find.text('Refreshed: 1 flag changed.'), findsOneWidget);

    await tester.tapAndSettle(destination('Home'));
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('Deals'), findsNothing);
  });

  testWidgets('nothing new: "Up to date"', (tester) async {
    await pumpSample(tester, initialLocation: '/dashboard');

    await tester.tap(find.text('Refresh'));
    await settle(tester);

    expect(
      find.text('Up to date: the server has nothing new.'),
      findsOneWidget,
    );
  });

  testWidgets('Device offline: a refresh attempts nothing, the flags stay', (
    tester,
  ) async {
    await pumpSample(tester, initialLocation: '/dashboard');
    await settle(tester);
    final requests = testServer.stats.requests;

    await tester.tap(find.text('Device offline'));
    await tester.pumpAndSettle();
    expect(find.text('Offline (simulated)'), findsOneWidget);
    expect(FlagKit.instance.detail('new_home_screen').reason, isNotNull);

    testServer.setEnabled('new_home_screen', false);
    await tester.tap(find.text('Refresh'));
    await settle(tester);

    expect(
      find.text('You\'re offline: the flags stay as they are.'),
      findsOneWidget,
    );
    expect(testServer.stats.requests, requests);
    expect(FlagKit.isEnabled('new_home_screen'), isTrue);
  });

  testWidgets('the server failing: the flags stay, and the reason shows', (
    tester,
  ) async {
    await pumpSample(tester, initialLocation: '/dashboard');
    testServer
      ..failureRate = 1
      ..setEnabled('new_home_screen', false);

    await tester.tap(find.text('Refresh'));
    await settle(tester);

    expect(find.textContaining('server error 503'), findsWidgets);
    expect(FlagKit.isEnabled('new_home_screen'), isTrue);
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
