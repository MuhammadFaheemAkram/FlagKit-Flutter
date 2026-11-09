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

  Future<void> pickCountry(WidgetTester tester, String country) async {
    await tester.tapAndSettle(destination('Profile'));
    await tester.tapAndSettle(find.byKey(const ValueKey('country')));
    await tester.tapAndSettle(find.text(country).last);
  }

  Future<void> openWhy(WidgetTester tester) =>
      tester.tapAndSettle(find.text('Why am I seeing this?'));

  testWidgets('a first launch: the server\'s flags, within startupWait', (
    tester,
  ) async {
    await pumpSample(tester);

    // The new home, its banner and sections, the server's page size: no
    // default flashed first. The look is classic: home_theme targets
    // Pakistan and the UAE, and no country is set yet.
    expect(find.text('Spring sale: 15.5 % off at checkout'), findsOneWidget);
    expect(find.text('Deals'), findsOneWidget);
    expect(primaryOf(tester), primaryFor(AppThemeSpec.classic));

    await tester.tapAndSettle(destination('Checkout'));
    // new_checkout is rolled out to 25 %, and this install's bucket (4486)
    // is outside it: the classic checkout.
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

    // Tall enough to build the whole Dashboard: the switch is far down.
    tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
    await tester.pumpAndSettle();
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

  group('targeting and rollouts', () {
    testWidgets('a country the theme targets: the modern look', (tester) async {
      await pumpSample(tester);

      await pickCountry(tester, 'PK');
      await tester.tapAndSettle(destination('Home'));
      expect(primaryOf(tester), primaryFor(AppThemeSpec.modern));
      await openWhy(tester);
      expect(
        find.textContaining(
          'You see the modern look because the flag\'s targeting rules match '
          'you.',
        ),
        findsOneWidget,
      );

      await pickCountry(tester, 'GB');
      await tester.tapAndSettle(destination('Home'));
      expect(primaryOf(tester), primaryFor(AppThemeSpec.classic));
    });

    testWidgets('signed out, outside the rollout; signing in moves the '
        'bucket', (tester) async {
      await pumpSample(tester, initialLocation: '/checkout');
      expect(find.byType(Stepper), findsOneWidget);
      await openWhy(tester);
      expect(
        find.textContaining(
          'You see the step-by-step checkout because you\'re outside its '
          '25 % rollout (bucket 4486 of 10,000, not below 2500).',
        ),
        findsOneWidget,
      );

      await tester.tapAndSettle(destination('Profile'));
      await tester.enterText(
        find.byKey(const ValueKey('userId')),
        userInRollout,
      );
      await tester.pump();
      await tester.tapAndSettle(find.text('Sign in'));
      await tester.tapAndSettle(destination('Checkout'));

      expect(find.byType(Stepper), findsNothing);
      expect(find.textContaining('Pay'), findsOneWidget);
      await openWhy(tester);
      expect(
        find.textContaining(
          'You see the one-page checkout because you\'re in its 25 % rollout '
          '(bucket 404 of 10,000, below 2500).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('an app before 2.0.0: no discount', (tester) async {
      await pumpSample(tester, initialLocation: '/profile');

      await tester.tapAndSettle(find.text('1.9.0'));
      await tester.tapAndSettle(destination('Checkout'));
      await tester.tapAndSettle(find.text('Continue'));
      await tester.tapAndSettle(find.text('Continue'));

      expect(find.textContaining('Discount'), findsNothing);
      await openWhy(tester);
      expect(
        find.textContaining(
          'You see no discount because the flag targets other users',
        ),
        findsOneWidget,
      );
    });
  });

  group('the Dashboard\'s tools', () {
    /// The Dashboard, tall enough to build every section.
    Future<void> openDashboard(
      WidgetTester tester, {
      String path = '/dashboard',
    }) async {
      await pumpSample(tester, initialLocation: path);
      // Taller would fail to rasterize the page transitions.
      tester.view.physicalSize = const Size(390 * 3, 5000 * 3);
      await settle(tester);
    }

    testWidgets('the server console switches a flag off; Refresh brings it', (
      tester,
    ) async {
      await openDashboard(tester);

      await tester.tap(find.widgetWithText(SwitchListTile, 'new_home_screen'));
      await settle(tester);
      expect(testServer.flags.first['enabled'], isFalse);
      // Nothing in the app yet: a server change waits for a refresh.
      expect(FlagKit.isEnabled('new_home_screen'), isTrue);

      await tester.tap(find.text('Refresh'));
      await settle(tester);
      expect(FlagKit.isEnabled('new_home_screen'), isFalse);
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      await tester.tapAndSettle(destination('Home'));
      expect(find.text('Stories'), findsOneWidget);
    });

    testWidgets('an override from a flag\'s page wins, and is cleared', (
      tester,
    ) async {
      await openDashboard(tester);

      // The Flags list's row (the console, further down, lists it too).
      await tester.tap(find.text('new_checkout').first);
      await settle(tester);
      expect(find.text('Rolled out to 25 %'), findsOneWidget);
      expect(
        find.text(
          'Your bucket is 4486 of 10,000: not below 2500, so you\'re out.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Override: on'));
      await settle(tester);
      expect(find.text('Overridden with true.'), findsOneWidget);
      expect(FlagKit.detail('new_checkout').source, FlagSource.override);

      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      await tester.tapAndSettle(destination('Checkout'));
      expect(find.byType(Stepper), findsNothing, reason: 'the one-page one');

      // Back on the Dashboard's tab: the flag's page is still open.
      await tester.tapAndSettle(destination('Dashboard'));
      await tester.ensureVisible(find.text('Clear override'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear override'));
      await settle(tester);
      expect(
        FlagKit.detail('new_checkout').reason,
        EvaluationReason.rolloutExcluded,
      );
    });

    testWidgets('Clear cache: defaults until Refresh brings the flags', (
      tester,
    ) async {
      await openDashboard(tester);

      await tester.tap(find.text('Clear cache'));
      await settle(tester);
      await tester.tap(find.text('Clear'));
      await settle(tester);
      expect(find.text('Empty'), findsOneWidget);
      expect(FlagKit.detail('feed_page_size').source, FlagSource.defaultValue);

      await tester.tap(find.text('Refresh'));
      await settle(tester);
      expect(FlagKit.getInt('feed_page_size', 20), 12);
    });

    testWidgets('Try a user shows the rollout at work', (tester) async {
      await openDashboard(tester);

      await tester.enterText(
        find.byKey(const ValueKey('tryUserId')),
        userInRollout,
      );
      await settle(tester);

      expect(
        find.textContaining('you\'re in the rollout (bucket 404'),
        findsOneWidget,
      );
      expect(FlagKit.context.userId, isNull, reason: 'the app\'s user stays');
    });

    testWidgets('a link to a flag opens it over the Dashboard', (tester) async {
      await openDashboard(tester, path: '/dashboard/flags/home_theme');
      expect(find.text('country is one of PK, AE'), findsOneWidget);

      await tester.pageBack();
      await settle(tester);
      expect(appBarTitled('Dashboard'), findsOneWidget);
    });

    testWidgets('a link to a flag that\'s gone says so', (tester) async {
      await openDashboard(tester, path: '/dashboard/flags/gone');
      expect(find.text('Flag not found'), findsOneWidget);

      await tester.tap(find.text('Back to the Dashboard'));
      await settle(tester);
      expect(appBarTitled('Dashboard'), findsOneWidget);
    });
  });
}

Color primaryOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first)).colorScheme.primary;

Color primaryFor(AppThemeSpec spec) =>
    AppTheme.build(spec, Brightness.light).colorScheme.primary;
