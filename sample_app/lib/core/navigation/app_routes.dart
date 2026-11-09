import 'package:flagkit_sample/features/checkout/checkout_page.dart';
import 'package:flagkit_sample/features/dashboard/dashboard_page.dart';
import 'package:flagkit_sample/features/dashboard/flag_detail_page.dart';
import 'package:flagkit_sample/features/home/home_page.dart';
import 'package:flagkit_sample/features/profile/profile_page.dart';
import 'package:flagkit_sample/features/shell/main_shell.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

part 'app_routes.g.dart';

// Typed routes: every destination is a class, and `go_router_builder`
// generates its path parsing, `location` getter and `go`/`push` helpers. A
// typo or a missing parameter is a compile error instead of a runtime "page
// not found".
//
// Four tabs: Home, Checkout, Profile and Dashboard. Each tab's screen
// reads its flags through the app's `AppFlags` port. The Dashboard's tab
// also holds one flag's detail page.

/// `StatefulShellRoute` gives every tab its own Navigator and keeps inactive
/// tabs alive in an IndexedStack, so switching tabs preserves each tab's
/// state (a checkout half-way through its steps, the dashboard's scroll).
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: '/home', name: 'home')],
    ),
    TypedStatefulShellBranch<CheckoutBranch>(
      routes: [
        TypedGoRoute<CheckoutRoute>(path: '/checkout', name: 'checkout'),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile', name: 'profile')],
    ),
    TypedStatefulShellBranch<DashboardBranch>(
      routes: [
        TypedGoRoute<DashboardRoute>(
          path: '/dashboard',
          name: 'dashboard',
          routes: [
            TypedGoRoute<FlagDetailRoute>(path: 'flags/:flagKey', name: 'flag'),
          ],
        ),
      ],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => MainShell(navigationShell: navigationShell);
}

// A named navigator key per tab makes each back stack addressable (and
// readable in debugging tools).

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeTab');
}

class CheckoutBranch extends StatefulShellBranchData {
  const CheckoutBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'checkoutTab');
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileTab');
}

class DashboardBranch extends StatefulShellBranchData {
  const DashboardBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'dashboardTab');
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class CheckoutRoute extends GoRouteData with $CheckoutRoute {
  const CheckoutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CheckoutPage();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfilePage();
}

class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DashboardPage();
}

/// One flag in full, over the Dashboard (in its tab): a deep link opens it
/// with the Dashboard beneath, so Back always has somewhere to go.
class FlagDetailRoute extends GoRouteData with $FlagDetailRoute {
  const FlagDetailRoute({required this.flagKey});

  final String flagKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FlagDetailPage(flagKey: flagKey);
}
