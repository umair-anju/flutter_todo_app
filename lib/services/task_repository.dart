import '../models/task.dart';
import '../models/sub_task.dart';
import 'database_helper.dart';

class TaskRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Task>> getAllTasks() async {
    final db = await dbHelper.database;

    // Fetch all tasks
    final tasksResult = await db.query('tasks', orderBy: 'createdAt DESC');

    // Fetch all subtasks
    final subtasksResult = await db.query('subtasks');

    // Group subtasks by taskId
    final Map<String, List<SubTask>> subtaskMap = {};
    for (var row in subtasksResult) {
      final taskId = row['taskId'] as String;
      final subtask = SubTask.fromMap(row);
      subtaskMap.putIfAbsent(taskId, () => []).add(subtask);
    }

    // Reconstruct Task objects
    return tasksResult.map((row) {
      final taskId = row['id'] as String;
      return Task.fromMap(row, subtaskMap[taskId] ?? []);
    }).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final db = await dbHelper.database;
    
    final tasks = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (tasks.isEmpty) return null;

    final subtasksResult = await db.query('subtasks', where: 'taskId = ?', whereArgs: [id]);
    final subtasks = subtasksResult.map((s) => SubTask.fromMap(s)).toList();

    return Task.fromMap(tasks.first, subtasks);
  }

  Future<void> addTask(Task task) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      await txn.insert('tasks', task.toMap());
      for (var subtask in task.subtasks) {
        await txn.insert('subtasks', subtask.toMap(task.id));
      }
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );

      // Simple approach: delete all subtasks and re-insert
      await txn.delete('subtasks', where: 'taskId = ?', whereArgs: [task.id]);
      for (var subtask in task.subtasks) {
        await txn.insert('subtasks', subtask.toMap(task.id));
      }
    });
  }

  Future<void> deleteTask(String id) async {
    final db = await dbHelper.database;
    // Subtasks will be deleted by ON DELETE CASCADE
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleTaskDone(String id, bool isDone) async {
    final db = await dbHelper.database;
    final completedAt = isDone ? DateTime.now().toIso8601String() : null;

    await db.update(
      'tasks',
      {
        'isDone': isDone ? 1 : 0,
        'completedAt': completedAt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleSubtask(String subtaskId, bool isDone) async {
    final db = await dbHelper.database;
    await db.update(
      'subtasks',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }

  Future<void> clearCompleted() async {
    final db = await dbHelper.database;
    await db.delete('tasks', where: 'isDone = ?', whereArgs: [1]);
  }
}
