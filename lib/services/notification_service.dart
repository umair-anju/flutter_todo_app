import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_edit_task/add_edit_task_screen.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;

  NotificationService._init();

  Future<void> init(GlobalKey<NavigatorState> navKey) async {
    _navigatorKey = navKey;
    // 1. Initialize Timezone Data
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    // 2. Initialization Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 3. Initialize Plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && _navigatorKey?.currentContext != null) {
          final taskId = details.payload!;
          
          Future.microtask(() {
            final context = _navigatorKey!.currentContext!;
            final taskProvider = Provider.of<TaskProvider>(context, listen: false);
            try {
              final task = taskProvider.allTasks.firstWhere((t) => t.id == taskId);
              _navigatorKey!.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => AddEditTaskScreen(task: task),
                ),
              );
            } catch (e) {
              debugPrint('Task not found for deep linking: $taskId');
            }
          });
        }
      },
    );

    // 4. Request Permissions
    await requestPermissions();
  }

  Future<bool> requestPermissions() async {
    bool? granted = false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      granted = await androidImplementation?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    return granted ?? false;
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (!task.reminderEnabled || task.reminderTime == null || task.isDone) {
      await cancelTaskReminder(task.id);
      return;
    }
    
    // Ensure reminder time is in the future
    if (task.reminderTime!.isBefore(DateTime.now())) {
      debugPrint('Skipping reminder for "${task.title}" because it is in the past.');
      return;
    }

    // Ensure non-negative 31-bit integer for notification ID
    final int notificationId = task.id.hashCode.abs() & 0x7FFFFFFF;

    debugPrint('Scheduling reminder for "${task.title}" at ${task.reminderTime} with ID $notificationId');

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        task.title,
        'Reminder: Your task is due!',
        tz.TZDateTime.from(task.reminderTime!, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task deadlines and reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelTaskReminder(String taskId) async {
    final int notificationId = taskId.hashCode.abs() & 0x7FFFFFFF;
    await _notificationsPlugin.cancel(notificationId);
  }

  Future<void> rescheduleAll(List<Task> tasks) async {
    await _notificationsPlugin.cancelAll();
    for (final task in tasks) {
      if (task.reminderEnabled && !task.isDone) {
        await scheduleTaskReminder(task);
      }
    }
  }
}
