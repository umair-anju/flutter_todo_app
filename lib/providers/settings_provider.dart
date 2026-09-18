import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  int _weeklyGoal = 60;
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  TimeOfDay _defaultReminderTime = const TimeOfDay(hour: 9, minute: 0);

  int get weeklyGoal => _weeklyGoal;
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get defaultReminderTime => _defaultReminderTime;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _weeklyGoal = prefs.getInt('weeklyGoal') ?? 60;
    _darkMode = prefs.getBool('darkMode') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    
    final reminderStr = prefs.getString('defaultReminderTime') ?? "09:00";
    final parts = reminderStr.split(':');
    _defaultReminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    
    notifyListeners();
  }

  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyGoal', goal);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setDefaultReminderTime(TimeOfDay time) async {
    _defaultReminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultReminderTime', '${time.hour}:${time.minute}');
    notifyListeners();
  }
}
