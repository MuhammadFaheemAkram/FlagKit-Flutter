import 'package:flagkit_sample/core/navigation/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';

void main() {
  tearDown(tearDownSample);

  test('typed routes build their locations', () {
    expect(const HomeRoute().location, '/home');
    expect(const CheckoutRoute().location, '/checkout');
    expect(const ProfileRoute().location, '/profile');
    expect(const DashboardRoute().location, '/dashboard');
  });

  testWidgets('the app opens on Home', (tester) async {
    await pumpSample(tester);

    expect(appBarTitled('Home'), findsOneWidget);
    expect(tester.selectedTab, 0);
  });

  testWidgets('each tab shows its own screen', (tester) async {
    await pumpSample(tester);

    for (final (index, label) in [
      (1, 'Checkout'),
      (2, 'Profile'),
      (3, 'Dashboard'),
      (0, 'Home'),
    ]) {
      await tester.tapAndSettle(destination(label));
      expect(tester.selectedTab, index);
      expect(appBarTitled(label), findsOneWidget);
    }
  });

  testWidgets('a deep link opens its tab', (tester) async {
    await pumpSample(tester, initialLocation: '/dashboard');

    expect(appBarTitled('Dashboard'), findsOneWidget);
    expect(tester.selectedTab, 3);
  });

  testWidgets('a tab keeps its state while another is visited', (tester) async {
    await pumpSample(tester, initialLocation: '/checkout');
    await tester.tapAndSettle(find.text('Continue'));
    expect(find.text('Standard delivery'), findsOneWidget);

    await tester.tapAndSettle(destination('Home'));
    await tester.tapAndSettle(destination('Checkout'));

    expect(find.text('Standard delivery'), findsOneWidget);
  });

  testWidgets('an unknown location shows "Page not found", with a way back', (
    tester,
  ) async {
    await pumpSample(tester, initialLocation: '/nowhere');
    expect(find.text('Page not found'), findsOneWidget);

    await tester.tapAndSettle(find.text('Go to Home'));
    expect(appBarTitled('Home'), findsOneWidget);
  });
}
