import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../theme/app_theme.dart';

class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final List<Widget> destinations;
  final Widget body;
  final FloatingActionButton? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: Scaffold(
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabSelected,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: destinations.map((d) {
            final navItem = d as NavigationDestination;
            return BottomNavigationBarItem(
              icon: navItem.icon,
              label: navItem.label,
            );
          }).toList(),
        ),
        floatingActionButton: floatingActionButton,
      ),
      desktop: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: Responsive.isDesktop(context),
              selectedIndex: currentIndex,
              onDestinationSelected: onTabSelected,
              labelType: Responsive.isDesktop(context) 
                  ? NavigationRailLabelType.none 
                  : NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: AppTheme.primaryColor),
              selectedLabelTextStyle: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
              destinations: destinations.map((d) {
                final navItem = d as NavigationDestination;
                return NavigationRailDestination(
                  icon: navItem.icon,
                  selectedIcon: navItem.selectedIcon,
                  label: Text(navItem.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Stack(
                    children: [
                      body,
                      if (floatingActionButton != null)
                        Positioned(
                          bottom: 32,
                          right: 32,
                          child: floatingActionButton!,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A wrapper to match NavigationRail and BottomNavigationBar items
class NavigationDestination extends StatelessWidget {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  const NavigationDestination({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
