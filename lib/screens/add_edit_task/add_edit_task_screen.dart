import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/task.dart';
import '../../models/task_category.dart';
import '../../models/priority.dart';
import '../../models/sub_task.dart';
import '../../providers/task_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtaskController = TextEditingController();

  late TaskCategory _selectedCategory;
  late Priority _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  List<SubTask> _subtasks = [];
  bool _hasNotificationPermission = true;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _titleController.text = t.title;
      _selectedCategory = t.category;
      _selectedPriority = t.priority;
      _selectedDate = t.dueDate;
      _selectedTime = t.dueTime;
      _reminderEnabled = t.reminderEnabled;
      if (t.reminderTime != null) {
        _reminderTime = TimeOfDay.fromDateTime(t.reminderTime!);
      }
      _subtasks = List.from(t.subtasks);
    } else {
      _selectedCategory = TaskCategory.work;
      _selectedPriority = Priority.medium;
      // Get default reminder time from provider if creating new
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settings = context.read<SettingsProvider>();
        setState(() {
          _reminderTime = settings.defaultReminderTime;
        });
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _saveTask(TaskProvider provider) async {
    if (_formKey.currentState!.validate()) {
      if (_reminderEnabled) {
        if (_selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a due date for the reminder')),
          );
          return;
        }
        if (_reminderTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a reminder time')),
          );
          return;
        }
      }

      final task = Task(
        id: _isEditing ? widget.task!.id : const Uuid().v4(),
        title: _titleController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDate,
        dueTime: _selectedTime,
        isDone: _isEditing ? widget.task!.isDone : false,
        reminderEnabled: _reminderEnabled,
        reminderTime: _reminderEnabled && _reminderTime != null && _selectedDate != null
            ? DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _reminderTime!.hour,
                _reminderTime!.minute,
              )
            : null,
        subtasks: _subtasks,
        createdAt: _isEditing ? widget.task!.createdAt : DateTime.now(),
        completedAt: _isEditing ? widget.task!.completedAt : null,
      );

      if (_isEditing) {
        await provider.updateTask(task);
      } else {
        await provider.addTask(task);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _confirmDelete(TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteTask(widget.task!.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to previous screen
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _addSubtask() {
    if (_subtaskController.text.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTask(
          id: const Uuid().v4(),
          title: _subtaskController.text,
        ));
        _subtaskController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () => _confirmDelete(taskProvider),
            ),
          TextButton(
            onPressed: () => _saveTask(taskProvider),
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                _isEditing ? 'Edit Task' : 'New Task',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                _isEditing
                    ? 'Update task details and manage sub-tasks.'
                    : 'Fill in the details to create a new task.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _buildTitleSection(),
              const SizedBox(height: 16),
              _buildCategorizationSection(),
              const SizedBox(height: 16),
              _buildDateTimeSection(),
              const SizedBox(height: 16),
              _buildReminderSection(),
              const SizedBox(height: 16),
              _buildSubtasksSection(taskProvider),
              const SizedBox(height: 32),
              _buildActionButtons(taskProvider),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _selectedPriority.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: InputBorder.none,
                    floatingLabelStyle: TextStyle(color: AppTheme.primaryColor),
                  ),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: Priority.values.map((p) {
                final isSelected = _selectedPriority == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.displayName),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedPriority = p);
                    },
                    selectedColor: p.color.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? p.color : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? p.color : Colors.grey.shade300,
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TaskCategory>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: TaskCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18, color: cat.color),
                          const SizedBox(width: 8),
                          Text(cat.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor),
              title: const Text('Due Date'),
              subtitle: Text(
                _selectedDate == null ? 'Set date' : DateFormat('EEEE, MMM d').format(_selectedDate!),
              ),
              onTap: _pickDate,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_rounded, color: AppTheme.primaryColor),
              title: const Text('Due Time'),
              subtitle: Text(
                _selectedTime == null ? 'Set time' : _selectedTime!.format(context),
              ),
              onTap: _pickDueTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Switch(
                  value: _reminderEnabled,
                  onChanged: (val) async {
                    if (val) {
                      final granted = await NotificationService.instance.requestPermissions();
                      setState(() {
                        _hasNotificationPermission = granted;
                        _reminderEnabled = granted ? val : false;
                      });
                    } else {
                      setState(() => _reminderEnabled = val);
                    }
                  },
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ],
            ),
            if (!_hasNotificationPermission && _reminderEnabled == false)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Enable notifications in system settings to receive reminders',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_reminderEnabled) ...[
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notify me at'),
                subtitle: Text(
                  _reminderTime == null ? 'Select time' : _reminderTime!.format(context),
                ),
                onTap: _pickReminderTime,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubtasksSection(TaskProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.checklist_rounded, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text('Sub-tasks', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ..._subtasks.map((st) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  value: st.isDone,
                  onChanged: (val) {
                    setState(() => st.isDone = val ?? false);
                    if (_isEditing) {
                      provider.toggleSubtask(widget.task!.id, st.id);
                    }
                  },
                  shape: const CircleBorder(),
                  activeColor: AppTheme.primaryColor,
                ),
                title: TextFormField(
                  initialValue: st.title,
                  onChanged: (val) => st.title = val,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    decoration: st.isDone ? TextDecoration.lineThrough : null,
                    color: st.isDone ? Colors.grey : Colors.black87,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                  onPressed: () => setState(() => _subtasks.remove(st)),
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    decoration: const InputDecoration(
                      hintText: 'Add sub-task...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                TextButton(
                  onPressed: _addSubtask,
                  child: const Text('+ Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(TaskProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveTask(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Save Task', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
