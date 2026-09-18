import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum Priority {
  high('High', AppTheme.priorityHigh),
  medium('Medium', AppTheme.priorityMedium),
  low('Low', AppTheme.priorityLow);

  final String displayName;
  final Color color;

  const Priority(this.displayName, this.color);
}
