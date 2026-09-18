import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../services/task_repository.dart';
import '../services/notification_service.dart';

enum TaskStatusFilter { all, pending, completed }

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;
  final NotificationService _notificationService = NotificationService.instance;
  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _isInitialLoad = true;

  TaskProvider(this._repository) {
    loadTasks(reschedule: true);
  }

  List<Task> get allTasks => _tasks;
  bool get isLoading => _isLoading;

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();
  }

  double get todayCompletionPercent {
    final today = todayTasks;
    if (today.isEmpty) return 0.0;
    final completed = today.where((t) => t.isDone).length;
    return completed / today.length;
  }

  Future<void> loadTasks({bool reschedule = false}) async {
    if (_isInitialLoad) {
      _isLoading = true;
      notifyListeners();
    }
    
    _tasks = await _repository.getAllTasks();
    
    if (_isInitialLoad) {
      _isLoading = false;
      _isInitialLoad = false;
    }
    
    notifyListeners();
    
    // Reschedule only on initial load or if explicitly requested
    if (reschedule) {
      await _notificationService.rescheduleAll(_tasks);
    }
  }

  List<Task> filteredTasks(TaskCategory? category) {
    if (category == null) return _tasks;
    return _tasks.where((t) => t.category == category).toList();
  }

  List<Task> filteredByStatus(TaskStatusFilter filter) {
    return switch (filter) {
      TaskStatusFilter.pending => _tasks.where((t) => !t.isDone).toList(),
      TaskStatusFilter.completed => _tasks.where((t) => t.isDone).toList(),
      TaskStatusFilter.all => _tasks
    };
  }

  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
    if (task.reminderEnabled && !task.isDone) {
      await _notificationService.scheduleTaskReminder(task);
    }
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    // Explicitly cancel and re-schedule to avoid duplicates or stale data
    await _notificationService.cancelTaskReminder(task.id);
    if (task.reminderEnabled && !task.isDone) {
      await _notificationService.scheduleTaskReminder(task);
    }
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await _notificationService.cancelTaskReminder(id);
    await loadTasks();
  }

  Future<void> toggleDone(String id) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final newStatus = !task.isDone;
      await _repository.toggleTaskDone(id, newStatus);
      
      if (newStatus) {
        await _notificationService.cancelTaskReminder(id);
      } else if (task.reminderEnabled) {
        await _notificationService.scheduleTaskReminder(task);
      }
      
      await loadTasks();
    }
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final subtaskIndex = _tasks[taskIndex].subtasks.indexWhere((st) => st.id == subtaskId);
      if (subtaskIndex != -1) {
        final newStatus = !_tasks[taskIndex].subtasks[subtaskIndex].isDone;
        await _repository.toggleSubtask(subtaskId, newStatus);
        await loadTasks();
      }
    }
  }

  Future<void> clearCompleted() async {
    final completedTasks = _tasks.where((t) => t.isDone).toList();
    await _repository.clearCompleted();
    for (var task in completedTasks) {
      await _notificationService.cancelTaskReminder(task.id);
    }
    await loadTasks();
  }
}
