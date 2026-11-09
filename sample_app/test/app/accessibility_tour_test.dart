import 'package:flagkit/flagkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// Every screen, in light and dark, with text at 200 %: no layout overflows
// (an overflow fails the test), tap targets of at least 48 × 48, a label on
// everything tappable, and readable text contrast. A new screen, or a new
// state of one, gets a stop here.
void main() {
  tearDown(tearDownSample);

  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200 %', () {
      for (final (name, location, Future<void> Function(WidgetTester)? act) in [
        ('Home, the new home (the server\'s flags)', '/home', null),
        (
          'Home, the classic home',
          '/home',
          (tester) async {
            testServer.setEnabled('new_home_screen', false);
            await tester.runAsync(FlagKit.refresh);
            await tester.pumpAndSettle();
          },
        ),
        (
          'Home, why (the modern look, from Pakistan)',
          '/profile',
          (tester) async {
            await tester.tapAndSettle(find.byKey(const ValueKey('country')));
            await tester.tapAndSettle(find.text('PK').last);
            await tester.tapAndSettle(destination('Home'));
            await tester.tapAndSettle(find.text('Why am I seeing this?'));
          },
        ),
        ('Checkout, the cart step', '/checkout', null),
        (
          'Checkout, why (outside the rollout)',
          '/checkout',
          (tester) async {
            await tester.tapAndSettle(find.text('Why am I seeing this?'));
          },
        ),
        (
          'Checkout, the one-page checkout (signed in, in the rollout)',
          '/checkout',
          (tester) async {
            await tester.runAsync(() async {
              FlagKit.setContext(
                const EvaluationContext(
                  userId: userInRollout,
                  appVersion: '2.1.0',
                ),
              );
            });
            await tester.pumpAndSettle();
            await tester.tapAndSettle(find.text('Why am I seeing this?'));
          },
        ),
        (
          'Checkout, the payment step',
          '/checkout',
          (tester) async {
            await tester.tapAndSettle(find.text('Continue'));
            await tester.tapAndSettle(find.text('Continue'));
          },
        ),
        (
          'Checkout, after an order',
          '/checkout',
          (tester) async {
            await tester.tapAndSettle(find.text('Continue'));
            await tester.tapAndSettle(find.text('Continue'));
            await tester.tap(find.text('Place order'));
            await tester.pump();
          },
        ),
        ('Profile, signed out', '/profile', null),
        (
          'Profile, signed in',
          '/profile',
          (tester) async {
            await tester.enterText(
              find.byKey(const ValueKey('userId')),
              'alex',
            );
            await tester.pump();
            await tester.tapAndSettle(find.text('Sign in'));
          },
        ),
        ('Dashboard', '/dashboard', null),
        (
          'Dashboard, after a refresh',
          '/dashboard',
          (tester) async {
            await tester.tap(find.text('Refresh'));
            for (var i = 0; i < 3; i++) {
              await tester.runAsync(() => Future<void>.delayed(Duration.zero));
              await tester.pumpAndSettle();
            }
          },
        ),
        (
          'Dashboard, offline (simulated)',
          '/dashboard',
          (tester) async {
            await tester.tap(find.text('Device offline'));
            await tester.pumpAndSettle();
          },
        ),
        (
          'Dashboard, trying a user',
          '/dashboard',
          (tester) async {
            final field = find.byKey(const ValueKey('tryUserId'));
            // At 200 % the field is past what's built: scroll to it.
            await tester.scrollUntilVisible(
              field,
              400,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.enterText(field, userInRollout);
          },
        ),
        ('Flag, a rollout', '/dashboard/flags/new_checkout', null),
        (
          'Flag, its rules and an override that\'s refused',
          '/dashboard/flags/home_theme',
          (tester) async {
            await tester.enterText(
              find.byKey(const ValueKey('overrideValue')),
              '  ',
            );
            await tester.tap(find.text('Override'));
            await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          },
        ),
        (
          'Flag, overridden',
          '/dashboard/flags/new_checkout',
          (tester) async {
            await tester.tap(find.text('Override: on'));
            for (var i = 0; i < 3; i++) {
              await tester.runAsync(() => Future<void>.delayed(Duration.zero));
              await tester.pumpAndSettle();
            }
          },
        ),
        ('Flag not found', '/dashboard/flags/gone', null),
        ('Page not found', '/nowhere', null),
      ]) {
        testWidgets(name, (tester) async {
          tester.platformDispatcher
            ..textScaleFactorTestValue = 2
            ..platformBrightnessTestValue = brightness;
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          await pumpSample(tester, initialLocation: location);
          // Phone width, but tall enough to lay out every item of a long
          // list: the checks see only what is built.
          tester.view.physicalSize = const Size(390 * 3, 5000 * 3);
          await tester.pumpAndSettle();
          await act?.call(tester);
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(Scaffold).last);
          expect(MediaQuery.textScalerOf(context).scale(10), 20);
          expect(Theme.of(context).brightness, brightness);

          final handle = tester.ensureSemantics();
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    });
  }

  testWidgets('the tab labels keep their size at any text setting (a long '
      'press shows them)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpSample(tester);

    final label = destination('Dashboard');
    expect(MediaQuery.textScalerOf(tester.element(label)).scale(10), 10);

    final before = find.text('Dashboard').evaluate().length;
    await tester.longPress(label);
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsNWidgets(before + 1));
  });
}
