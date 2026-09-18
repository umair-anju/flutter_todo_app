import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _weekStartsOn = 'Monday';

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final taskProvider = context.read<TaskProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileSection(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Preferences'),
                  _buildPreferencesSection(settingsProvider),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Notifications'),
                  _buildNotificationsSection(settingsProvider),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Data Management'),
                  _buildDataSection(taskProvider),
                  const SizedBox(height: 16),
                  _buildSectionHeader('About'),
                  _buildAboutSection(),
                  const SizedBox(height: 100), // Space for BottomNav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(Icons.person_rounded, size: 32, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'John Doe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(SettingsProvider provider) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme for the app'),
            value: provider.darkMode,
            onChanged: (val) => provider.setDarkMode(val),
            activeThumbColor: AppTheme.primaryColor,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Weekly Task Goal'),
            subtitle: Text('${provider.weeklyGoal} tasks per week'),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _showGoalPicker(provider),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Default Reminder Time'),
            subtitle: Text(provider.defaultReminderTime.format(context)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: provider.defaultReminderTime,
              );
              if (picked != null) {
                provider.setDefaultReminderTime(picked);
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Week Starts On'),
            subtitle: Text(_weekStartsOn),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              setState(() {
                _weekStartsOn = _weekStartsOn == 'Monday' ? 'Sunday' : 'Monday';
              });
            },
          ),
        ],
      ),
    );
  }

  void _showGoalPicker(SettingsProvider provider) {
    final controller = TextEditingController(text: provider.weeklyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Weekly Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Number of tasks'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                provider.setWeeklyGoal(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(SettingsProvider provider) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminders for your tasks'),
            value: provider.notificationsEnabled,
            onChanged: (val) => provider.setNotificationsEnabled(val),
            activeThumbColor: AppTheme.primaryColor,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Reminder Sound'),
            subtitle: const Text('Default system sound'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(TaskProvider taskProvider) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Export Tasks'),
            subtitle: const Text('Backup your data to a CSV file'),
            leading: const Icon(Icons.file_download_outlined, color: Colors.blue),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Clear Completed Tasks', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Remove all finished tasks from history'),
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onTap: () => _showClearConfirmation(taskProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: ListTile(
        title: const Text('TaskFlow Version'),
        subtitle: const Text('1.0.0 (Build 42)'),
        trailing: const Icon(Icons.info_outline_rounded),
        onTap: () {},
      ),
    );
  }

  void _showClearConfirmation(TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will permanently delete all completed tasks. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await taskProvider.clearCompleted();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
