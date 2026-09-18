import 'package:flutter/material.dart';
import 'task_category.dart';
import 'priority.dart';
import 'sub_task.dart';

class Task {
  final String id;
  String title;
  TaskCategory category;
  Priority priority;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  bool isDone;
  bool reminderEnabled;
  DateTime? reminderTime;
  List<SubTask> subtasks;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    this.dueDate,
    this.dueTime,
    this.isDone = false,
    this.reminderEnabled = false,
    this.reminderTime,
    this.subtasks = const [],
    required this.createdAt,
    this.completedAt,
  });

  String get progress {
    if (subtasks.isEmpty) return isDone ? "1/1" : "0/1";
    int completedCount = subtasks.where((st) => st.isDone).length;
    return "$completedCount/${subtasks.length}";
  }

  bool get isOverdue {
    if (isDone || dueDate == null) return false;
    
    final now = DateTime.now();
    final due = DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      dueTime?.hour ?? 23,
      dueTime?.minute ?? 59,
    );
    
    return now.isAfter(due);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime != null ? '${dueTime!.hour}:${dueTime!.minute}' : null,
      'isDone': isDone ? 1 : 0,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderTime': reminderTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, List<SubTask> subtasks) {
    TimeOfDay? parsedTime;
    if (map['dueTime'] != null) {
      final parts = map['dueTime'].split(':');
      parsedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Task(
      id: map['id'],
      title: map['title'],
      category: TaskCategory.values.byName(map['category']),
      priority: Priority.values.byName(map['priority']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      dueTime: parsedTime,
      isDone: map['isDone'] == 1,
      reminderEnabled: map['reminderEnabled'] == 1,
      reminderTime: map['reminderTime'] != null ? DateTime.parse(map['reminderTime']) : null,
      subtasks: subtasks,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}
