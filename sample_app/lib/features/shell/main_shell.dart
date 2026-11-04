import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The tabs, in the order of the shell's branches.
enum AppTab {
  home('Home', Icons.home_outlined, Icons.home),
  checkout('Checkout', Icons.shopping_cart_outlined, Icons.shopping_cart),
  profile('Profile', Icons.person_outline, Icons.person),
  dashboard('Dashboard', Icons.flag_outlined, Icons.flag);

  const AppTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Hosts the bottom [NavigationBar] around the active tab.
///
/// [navigationShell] holds the tab navigators in an IndexedStack; this widget
/// only decides which branch is visible. Each tab screen brings its own
/// `Scaffold` and `AppBar`.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Tapping the tab that is already open returns it to its first screen,
  // as both platforms' tab bars do.
  void _selectTab(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      // The tab labels keep their size whatever the text setting, as the
      // platforms' own tab bars do. A long press shows the label in a
      // tooltip, and screen readers read it.
      bottomNavigationBar: MediaQuery.withNoTextScaling(
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _selectTab,
          destinations: [
            for (final tab in AppTab.values)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
                tooltip: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
