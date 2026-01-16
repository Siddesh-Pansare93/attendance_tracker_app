import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';

/// Page for marking today's attendance
class TodayAttendancePage extends StatelessWidget {
  const TodayAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        actions: [
          IconButton(
            onPressed: () => controller.loadTodayClasses(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadTodayClasses,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Show date header and analytics regardless of whether there are classes today
              // Date header
              _buildDateHeader(context),
              const SizedBox(height: 16),

              // Progress summary (only if there are classes today)
              if (controller.todayClasses.isNotEmpty) ...[
                _buildProgressSummary(context, controller),
                const SizedBox(height: 24),
              ] else ...[
                // Show a message if no classes today
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Classes Today',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enjoy your free time!',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Analytics section (always shown)
              _buildAnalyticsSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AttendanceUtils.formatDateLong(today),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AttendanceUtils.formatDateForDisplay(today),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary(
    BuildContext context,
    AttendanceController controller,
  ) {
    final theme = Theme.of(context);
    final total = controller.todayClasses.length;
    final marked = controller.todayRecords.length;
    final present = controller.todayRecords.values
        .where((r) => r.isPresent)
        .length;
    final absent = marked - present;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(
              context,
              '$marked/$total',
              'Marked',
              theme.colorScheme.primary,
            ),
            _buildDivider(context),
            _buildStat(context, '$present', 'Present', AppTheme.safeColor),
            _buildDivider(context),
            _buildStat(context, '$absent', 'Absent', AppTheme.criticalColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  /// Analytics section with filters
  Widget _buildAnalyticsSection(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Filter tabs
        _buildAnalyticsFilterTabs(context, dashboardController),
        const SizedBox(height: 16),

        // Analytics stats
        Obx(() {
          final analytics = dashboardController.getAnalyticsData();
          return Column(
            children: [
              // Summary row
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsStat(
                      context,
                      '${analytics['totalClasses']}',
                      'Classes',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnalyticsStat(
                      context,
                      '${analytics['totalPresent']}',
                      'Present',
                      AppTheme.safeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnalyticsStat(
                      context,
                      '${analytics['totalAbsent']}',
                      'Absent',
                      AppTheme.criticalColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Overall percentage card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                      theme.colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circular progress indicator
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value:
                                (analytics['overallPercentage'] as double) /
                                100,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(analytics['overallPercentage'] as double).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.analytics,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Overall Attendance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on selected period',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Per-subject breakdown
              if ((analytics['subjectStats'] as Map).isNotEmpty) ...[
                Text(
                  'By Subject',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...(analytics['subjectStats'] as Map).entries.map(
                  (entry) => _buildSubjectAnalyticsTile(
                    context,
                    entry.key as String,
                    entry.value as Map<String, int>,
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAnalyticsFilterTabs(
    BuildContext context,
    DashboardController controller,
  ) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildFilterTab(
              context,
              'Weekly',
              controller.analyticsFilter.value == 'weekly',
              () => controller.setAnalyticsFilterWeekly(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(
              context,
              'Monthly',
              controller.analyticsFilter.value == 'monthly',
              () => controller.setAnalyticsFilterMonthly(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(
              context,
              'Custom',
              controller.analyticsFilter.value == 'from-to',
              () => _showDateRangePicker(context, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    IconData icon;

    switch (label) {
      case 'Weekly':
        icon = Icons.date_range;
        break;
      case 'Monthly':
        icon = Icons.calendar_month;
        break;
      case 'Custom':
        icon = Icons.calendar_today;
        break;
      default:
        icon = Icons.calendar_today;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsStat(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    IconData icon;

    switch (label) {
      case 'Classes':
        icon = Icons.class_;
        break;
      case 'Present':
        icon = Icons.check_circle;
        break;
      case 'Absent':
        icon = Icons.cancel;
        break;
      default:
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectAnalyticsTile(
    BuildContext context,
    String subjectName,
    Map<String, int> stats,
  ) {
    final theme = Theme.of(context);
    final classes = stats['classes'] ?? 0;
    final present = stats['present'] ?? 0;
    final percentage = classes > 0 ? (present / classes * 100) : 0.0;
    final percentageColor = _getPercentageColor(percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            percentageColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: percentageColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: percentageColor.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Subject icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: percentageColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.book, color: percentageColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Subject name and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$present/$classes classes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      percentageColor,
                      percentageColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: percentageColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: classes > 0 ? (present / classes) : 0.0,
              minHeight: 6,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(percentageColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return AppTheme.safeColor;
    if (percentage >= 50) return AppTheme.warningColor;
    return AppTheme.criticalColor;
  }

  /// Show date range picker for custom analytics
  void _showDateRangePicker(
    BuildContext context,
    DashboardController controller,
  ) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange:
          controller.fromDate.value != null && controller.toDate.value != null
          ? DateTimeRange(
              start: controller.fromDate.value!,
              end: controller.toDate.value!,
            )
          : null,
    );

    if (range != null) {
      controller.setAnalyticsFilterFromTo(range.start, range.end);
    }
  }
}
