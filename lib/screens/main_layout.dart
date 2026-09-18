import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'tasks/tasks_screen.dart';
import 'charts/charts_screen.dart';
import 'settings/settings_screen.dart';
import 'add_edit_task/add_edit_task_screen.dart';
import '../widgets/adaptive_scaffold.dart' as adaptive;

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const ChartsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return adaptive.AdaptiveScaffold(
      currentIndex: _currentIndex,
      onTabSelected: (index) => setState(() => _currentIndex = index),
      destinations: const [
        adaptive.NavigationDestination(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        adaptive.NavigationDestination(
          icon: Icon(Icons.list_alt_rounded),
          label: 'Tasks',
        ),
        adaptive.NavigationDestination(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Charts',
        ),
        adaptive.NavigationDestination(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
