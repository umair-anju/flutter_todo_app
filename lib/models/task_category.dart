import 'package:flutter/material.dart';

enum TaskCategory {
  work('Work', Color(0xFF4F46E5)),
  personal('Personal', Color(0xFF10B981)),
  health('Health', Color(0xFFF59E0B)),
  design('Design', Color(0xFF8B5CF6)),
  other('Other', Color(0xFF6B7280));

  final String displayName;
  final Color color;

  const TaskCategory(this.displayName, this.color);
}
