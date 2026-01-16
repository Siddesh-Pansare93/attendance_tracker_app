import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event_available,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No Classes Today',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enjoy your free time!',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
    final isDark = theme.brightness == Brightness.dark;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AttendanceUtils.formatDateLong(today),
                style:
                    (isDark
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
              ),
              const SizedBox(height: 4),
              Text(
                AttendanceUtils.formatDateForDisplay(today),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(
    BuildContext context,
    AttendanceController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final total = controller.todayClasses.length;
    final marked = controller.todayRecords.length;
    final present = controller.todayRecords.values
        .where((r) => r.isPresent)
        .length;
    final absent = marked - present;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style:
                (isDark ? theme.textTheme.bodySmall : theme.textTheme.bodySmall)
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextMuted
                          : AppTheme.textMuted,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildProgressStat(
                  context,
                  '$marked/$total',
                  'Marked',
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressStat(
                  context,
                  '$present',
                  'Present',
                  AppTheme.safeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressStat(
                  context,
                  '$absent',
                  'Absent',
                  AppTheme.criticalColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.08)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style:
                (isDark
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.headlineSmall)
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 18,
                    ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Analytics section with filters
  Widget _buildAnalyticsSection(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style:
              (isDark
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
        ),
        const SizedBox(height: 16),

        // Filter tabs
        _buildAnalyticsFilterTabs(context, dashboardController),
        const SizedBox(height: 20),

        // Analytics stats
        Obx(() {
          final analytics = dashboardController.getAnalyticsData();
          return Column(
            children: [
              // Summary row with 3 cards
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsStat(
                      context,
                      '${analytics['totalClasses']}',
                      'Classes',
                      AppTheme.infoColor,
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
              const SizedBox(height: 20),

              // Overall percentage card - Minimalist with solid color
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Circular progress indicator
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value:
                                (analytics['overallPercentage'] as double) /
                                100,
                            strokeWidth: 5,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(analytics['overallPercentage'] as double).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.analytics,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Overall Attendance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on selected period',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Per-subject breakdown
              if ((analytics['subjectStats'] as Map).isNotEmpty) ...[
                Text(
                  'By Subject',
                  style:
                      (isDark
                              ? theme.textTheme.bodySmall
                              : theme.textTheme.bodySmall)
                          ?.copyWith(
                            color: isDark
                                ? AppTheme.darkTextMuted
                                : AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                ),
                const SizedBox(height: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildFilterTab(
              context,
              'Weekly',
              controller.analyticsFilter.value == 'weekly',
              () => controller.setAnalyticsFilterWeekly(),
              isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(
              context,
              'Monthly',
              controller.analyticsFilter.value == 'monthly',
              () => controller.setAnalyticsFilterMonthly(),
              isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(
              context,
              'Custom',
              controller.analyticsFilter.value == 'from-to',
              () => _showDateRangePicker(context, controller),
              isDark,
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
    bool isDark,
  ) {
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
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? AppTheme.darkBgSecondary : AppTheme.bgSecondary),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary),
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
    final isDark = theme.brightness == Brightness.dark;
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
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
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
    final isDark = theme.brightness == Brightness.dark;
    final classes = stats['classes'] ?? 0;
    final present = stats['present'] ?? 0;
    final percentage = classes > 0 ? (present / classes * 100) : 0.0;
    final percentageColor = _getPercentageColor(percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
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
                  color: percentageColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.book, color: percentageColor, size: 18),
              ),
              const SizedBox(width: 12),
              // Subject name and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectName,
                      style:
                          (isDark
                                  ? theme.textTheme.bodyLarge
                                  : theme.textTheme.bodyLarge)
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$present/$classes classes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextMuted
                            : AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: percentageColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: percentageColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: percentageColor,
                    fontSize: 13,
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
              backgroundColor: isDark
                  ? AppTheme.darkBorderSubtle
                  : AppTheme.borderSubtle,
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
