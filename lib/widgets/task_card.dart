import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.isDone;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Priority accent bar
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: task.priority.color,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Checkbox with scale animation
                          GestureDetector(
                            onTap: onToggle,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? AppTheme.primaryColor : Colors.transparent,
                                border: Border.all(
                                  color: isDone ? AppTheme.primaryColor : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: AnimatedScale(
                                scale: isDone ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                color: isDone ? Colors.grey : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                              ),
                              child: Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Reminder icon
                          if (task.reminderEnabled)
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 18,
                              color: isDone ? Colors.grey.shade400 : AppTheme.primaryColor.withValues(alpha: 0.7),
                            ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Metadata row
                      Row(
                        children: [
                          const SizedBox(width: 36), // Align with title text
                          // Priority dot + label
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: task.priority.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.priority.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Subtask progress OR Due Date
                          if (task.subtasks.isNotEmpty) ...[
                            Icon(Icons.checklist_rounded, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              task.progress,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ] else if (task.dueDate != null) ...[
                            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(task.dueDate!),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                          const Spacer(),
                          // Category pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.categoryBg.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 1.0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.category.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppTheme.categoryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
