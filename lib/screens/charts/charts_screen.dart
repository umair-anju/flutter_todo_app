import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../providers/task_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/analytics_service.dart';
import '../../widgets/empty_state.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String _trendType = 'Completed'; // 'Completed' or 'Added'
  String _viewMode = 'Week'; // 'Week' or 'Month'

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final taskProvider = context.watch<TaskProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final tasks = taskProvider.allTasks;

    if (tasks.isEmpty) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.bar_chart_rounded,
          title: 'No Analytics Yet',
          message: 'Add and complete some tasks to see your productivity trends!',
        ),
      );
    }

    final weeklyData = AnalyticsService.weeklyCompletion(tasks);
    final monthlyCompleted = AnalyticsService.monthlyCompletedTrend(tasks);
    final monthlyAdded = AnalyticsService.monthlyAddedTrend(tasks);
    final completionRate = AnalyticsService.completionRate(tasks);
    final rateChange = AnalyticsService.completionRateChangeFromLastWeek(tasks);
    final avgTasksPerDay = AnalyticsService.averageTasksPerDay(tasks);
    final goalProgress = AnalyticsService.weeklyGoalProgress(tasks, settingsProvider.weeklyGoal);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildViewToggle(),
              const SizedBox(height: 24),
              if (isMobile) ...[
                _buildStatCards(completionRate, rateChange, avgTasksPerDay),
                const SizedBox(height: 20),
                _buildGoalProgressCard(goalProgress),
                const SizedBox(height: 20),
                if (_viewMode == 'Week') _buildWeeklyCompletionCard(weeklyData),
                if (_viewMode == 'Month') _buildMonthlyTrendCard(monthlyCompleted, monthlyAdded),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildStatCards(completionRate, rateChange, avgTasksPerDay),
                          const SizedBox(height: 20),
                          _buildWeeklyCompletionCard(weeklyData),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          _buildGoalProgressCard(goalProgress),
                          const SizedBox(height: 20),
                          _buildMonthlyTrendCard(monthlyCompleted, monthlyAdded),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 100), // Space for BottomNav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      children: ['Week', 'Month'].map((mode) {
        final isSelected = _viewMode == mode;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text('$mode View'),
            selected: isSelected,
            onSelected: (val) {
              if (val) setState(() => _viewMode = mode);
            },
            selectedColor: AppTheme.primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.categoryText,
              fontWeight: FontWeight.bold,
            ),
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your productivity and task trends.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatCards(double rate, double change, double avg) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Completion Rate',
            value: '${rate.toInt()}%',
            trend: '${change >= 0 ? '+' : ''}${change.toInt()}%',
            trendColor: change >= 0 ? Colors.green : Colors.red,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Avg Tasks/Day',
            value: avg.toStringAsFixed(1),
            trend: 'from history',
            trendColor: Colors.grey.shade600,
            icon: Icons.assignment_turned_in_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required Color trendColor,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryColor),
                const Spacer(),
                const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: TextStyle(fontSize: 10, color: trendColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard((int, int, double) goalData) {
    final (completed, goal, percent) = goalData;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Weekly Goal Progress',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completed/$goal tasks completed',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCompletionCard(Map<String, int> data) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = data.values.fold(5, (prev, element) => element > prev ? element : prev).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Weekly Completion',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.more_horiz, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal + 2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: days.asMap().entries.map((entry) {
                    return _buildBarGroup(entry.key, (data[entry.value] ?? 0).toDouble());
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryColor,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendCard(Map<DateTime, int> completed, Map<DateTime, int> added) {
    final sortedMonths = completed.keys.toList()..sort();
    final dataset = _trendType == 'Completed' ? completed : added;
    final maxVal = dataset.values.fold(5, (prev, element) => element > prev ? element : prev).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Monthly Trends',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                _buildTrendToggle(),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  minY: 0,
                  maxY: maxVal + 2,
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${sortedMonths[value.toInt()].month}/${sortedMonths[value.toInt()].year.toString().substring(2)}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedMonths.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), (dataset[entry.value] ?? 0).toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                            AppTheme.primaryColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.categoryBg.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Completed', 'Added'].map((type) {
          final isSelected = _trendType == type;
          return GestureDetector(
            onTap: () => setState(() => _trendType = type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                    : null,
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
