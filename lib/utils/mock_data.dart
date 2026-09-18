import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/priority.dart';
import '../models/sub_task.dart';

class MockData {
  static final _uuid = const Uuid();

  static List<Task> get mockTasks {
    final now = DateTime.now();
    
    return [
      Task(
        id: _uuid.v4(),
        title: 'Project Proposal for TaskFlow',
        category: TaskCategory.work,
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 1)),
        dueTime: const TimeOfDay(hour: 10, minute: 0),
        createdAt: now.subtract(const Duration(hours: 5)),
        subtasks: [
          SubTask(id: _uuid.v4(), title: 'Define features', isDone: true),
          SubTask(id: _uuid.v4(), title: 'Create wireframes', isDone: false),
          SubTask(id: _uuid.v4(), title: 'Draft tech stack', isDone: false),
        ],
      ),
      Task(
        id: _uuid.v4(),
        title: 'Morning Yoga',
        category: TaskCategory.health,
        priority: Priority.medium,
        dueDate: now,
        dueTime: const TimeOfDay(hour: 7, minute: 30),
        isDone: true,
        completedAt: now.subtract(const Duration(hours: 4)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Grocery Shopping',
        category: TaskCategory.personal,
        priority: Priority.low,
        dueDate: now.subtract(const Duration(days: 1)),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        id: _uuid.v4(),
        title: 'UI Design for Home Screen',
        category: TaskCategory.design,
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now,
        subtasks: [
          SubTask(id: _uuid.v4(), title: 'Color palette', isDone: true),
          SubTask(id: _uuid.v4(), title: 'Typography', isDone: true),
        ],
      ),
      Task(
        id: _uuid.v4(),
        title: 'Book Flight for Vacation',
        category: TaskCategory.personal,
        priority: Priority.medium,
        reminderEnabled: true,
        reminderTime: now.add(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Weekly Team Sync',
        category: TaskCategory.work,
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 3)),
        dueTime: const TimeOfDay(hour: 14, minute: 0),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Annual Physical Checkup',
        category: TaskCategory.health,
        priority: Priority.low,
        dueDate: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Refactor Database Layer',
        category: TaskCategory.other,
        priority: Priority.medium,
        isDone: false,
        createdAt: now.subtract(const Duration(days: 1)),
        subtasks: [
          SubTask(id: _uuid.v4(), title: 'Update migrations', isDone: false),
        ],
      ),
    ];
  }
}
