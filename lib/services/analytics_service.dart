import 'package:intl/intl.dart';
import '../models/task.dart';

class AnalyticsService {
  static Map<String, int> weeklyCompletion(List<Task> tasks) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final Map<String, int> data = {
      'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0
    };

    for (var task in tasks) {
      if (task.isDone && task.completedAt != null) {
        if (task.completedAt!.isAfter(firstDayOfWeek.subtract(const Duration(seconds: 1)))) {
          final dayName = DateFormat('E').format(task.completedAt!);
          if (data.containsKey(dayName)) {
            data[dayName] = data[dayName]! + 1;
          }
        }
      }
    }
    return data;
  }

  static Map<DateTime, int> monthlyCompletedTrend(List<Task> tasks, {int months = 6}) {
    final now = DateTime.now();
    final Map<DateTime, int> data = {};
    
    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      data[month] = 0;
    }

    for (var task in tasks) {
      if (task.isDone && task.completedAt != null) {
        final taskMonth = DateTime(task.completedAt!.year, task.completedAt!.month, 1);
        if (data.containsKey(taskMonth)) {
          data[taskMonth] = data[taskMonth]! + 1;
        }
      }
    }
    return data;
  }

  static Map<DateTime, int> monthlyAddedTrend(List<Task> tasks, {int months = 6}) {
    final now = DateTime.now();
    final Map<DateTime, int> data = {};
    
    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      data[month] = 0;
    }

    for (var task in tasks) {
      final taskMonth = DateTime(task.createdAt.year, task.createdAt.month, 1);
      if (data.containsKey(taskMonth)) {
        data[taskMonth] = data[taskMonth]! + 1;
      }
    }
    return data;
  }

  static double completionRate(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isDone).length;
    return (completed / tasks.length) * 100;
  }

  static double completionRateChangeFromLastWeek(List<Task> tasks) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(seconds: 1));

    final thisWeekTasks = tasks.where((t) => 
      t.createdAt.isAfter(thisWeekStart.subtract(const Duration(seconds: 1)))
    ).toList();
    
    final lastWeekTasks = tasks.where((t) => 
      t.createdAt.isAfter(lastWeekStart.subtract(const Duration(seconds: 1))) &&
      t.createdAt.isBefore(lastWeekEnd)
    ).toList();

    final thisWeekRate = completionRate(thisWeekTasks);
    final lastWeekRate = completionRate(lastWeekTasks);

    return thisWeekRate - lastWeekRate;
  }

  static double averageTasksPerDay(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    final dates = tasks.map((t) => DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day)).toSet();
    if (dates.isEmpty) return 0.0;
    
    return tasks.length / dates.length;
  }

  static (int completed, int goal, double percent) weeklyGoalProgress(List<Task> tasks, int goal) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    final completedThisWeek = tasks.where((t) => 
      t.isDone && 
      t.completedAt != null && 
      t.completedAt!.isAfter(firstDayOfWeek.subtract(const Duration(seconds: 1)))
    ).length;

    final percent = (completedThisWeek / goal).clamp(0.0, 1.0);
    return (completedThisWeek, goal, percent);
  }
}
