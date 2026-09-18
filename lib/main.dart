import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/main_layout.dart';
import 'services/task_repository.dart';
import 'services/notification_service.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'utils/mock_data.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized before any plugin setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  await NotificationService.instance.init(navigatorKey);

  // Initialize Repository
  final taskRepository = TaskRepository();

  // One-time Seeding Logic
  final prefs = await SharedPreferences.getInstance();
  final hasSeeded = prefs.getBool('hasSeeded') ?? false;

  if (!hasSeeded) {
    final mockTasks = MockData.mockTasks;
    for (var task in mockTasks) {
      await taskRepository.addTask(task);
    }
    await prefs.setBool('hasSeeded', true);
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<TaskRepository>.value(value: taskRepository),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'TaskFlow',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (taskProvider.isLoading) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 64, color: AppTheme.primaryColor),
                        SizedBox(height: 24),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }
              return const MainLayout();
            },
          ),
        );
      },
    );
  }
}
