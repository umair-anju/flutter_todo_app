import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../add_edit_task/add_edit_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatusFilter _filter = TaskStatusFilter.all;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final filteredTasks = taskProvider.filteredByStatus(_filter);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'My Tasks',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildFilterChips(),
              const SizedBox(height: 24),
              Expanded(
                child: _buildTaskList(filteredTasks, taskProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: TaskStatusFilter.values.map((option) {
        final isSelected = _filter == option;
        final label = option.name[0].toUpperCase() + option.name.substring(1);
        
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _filter = option);
            },
            selectedColor: AppTheme.primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.categoryText,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.categoryBg,
                width: 1.5,
              ),
            ),
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider taskProvider) {
    if (tasks.isEmpty) {
      final filterLabel = _filter.name;
      return EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'No $filterLabel Tasks',
        message: 'Everything looks clear here!',
      );
    }

    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _dismissibleTaskItem(task, taskProvider);
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 100,
        ),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _dismissibleTaskItem(task, taskProvider);
        },
      );
    }
  }

  Widget _dismissibleTaskItem(Task task, TaskProvider provider) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (direction) async {
        final deletedTask = task;
        await provider.deleteTask(task.id);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${deletedTask.title}" deleted'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppTheme.primaryColor,
              onPressed: () => provider.addTask(deletedTask),
            ),
          ),
        );
      },
      child: TaskCard(
        task: task,
        onToggle: () => provider.toggleDone(task.id),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTaskScreen(task: task),
            ),
          );
        },
      ),
    );
  }
}
