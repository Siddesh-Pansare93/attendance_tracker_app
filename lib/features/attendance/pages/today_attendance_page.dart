import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Page for marking today's attendance
class TodayAttendancePage extends StatelessWidget {
  const TodayAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Attendance"),
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

        if (controller.todayClasses.isEmpty) {
          return const NoClassesTodayEmpty();
        }

        return RefreshIndicator(
          onRefresh: controller.loadTodayClasses,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date header
              _buildDateHeader(context),
              const SizedBox(height: 16),

              // Progress summary
              _buildProgressSummary(context, controller),
              const SizedBox(height: 24),

              // Analytics section
              _buildAnalyticsSection(context),
              const SizedBox(height: 24),

              // Classes list
              Text(
                'Mark Your Attendance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ...controller.todayClasses.map(
                (entry) => _buildClassCard(context, entry, controller),
              ),
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

  Widget _buildClassCard(
    BuildContext context,
    TimetableEntry entry,
    AttendanceController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subject = controller.getSubject(entry.subjectId);
    if (subject == null) return const SizedBox.shrink();

    // Use entry.id for tracking individual lecture instances
    final isMarked = controller.isMarkedToday(entry.id);
    final status = controller.getTodayStatus(entry.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161622) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3C) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.book_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${subject.attendedClasses}/${subject.totalClasses} classes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Attendance percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(
                      subject.attendancePercentage,
                      controller.threshold.value,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${subject.attendancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.getStatusColor(
                        subject.attendancePercentage,
                        controller.threshold.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action buttons - pass both subjectId AND entryId
            if (isMarked)
              _buildMarkedStatus(
                context,
                status!,
                controller,
                entry.subjectId,
                entry.id,
              )
            else
              _buildActionButtons(
                context,
                controller,
                entry.subjectId,
                entry.id,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AttendanceController controller,
    String subjectId,
    String entryId,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.markAttendance(
                  subjectId,
                  'absent',
                  timetableEntryId: entryId,
                ),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Absent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.criticalColor,
                  side: const BorderSide(color: AppTheme.criticalColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.markAttendance(
                  subjectId,
                  'present',
                  timetableEntryId: entryId,
                ),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Present'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.safeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => controller.markAttendance(
              subjectId,
              'cancelled',
              timetableEntryId: entryId,
            ),
            icon: const Icon(Icons.event_busy, size: 18),
            label: const Text('Lecture Cancelled'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.warningColor,
              side: const BorderSide(color: AppTheme.warningColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkedStatus(
    BuildContext context,
    String status,
    AttendanceController controller,
    String subjectId,
    String entryId,
  ) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'present':
        statusColor = AppTheme.safeColor;
        statusIcon = Icons.check_circle;
        statusText = 'Marked Present';
        break;
      case 'cancelled':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.event_busy;
        statusText = 'Lecture Cancelled';
        break;
      default:
        statusColor = AppTheme.criticalColor;
        statusIcon = Icons.cancel;
        statusText = 'Marked Absent';
    }

    return Row(
      children: [
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Change button
        TextButton(
          onPressed: () => _showChangeDialog(
            context,
            controller,
            subjectId,
            entryId,
            status,
          ),
          child: Text(
            'Change',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  void _showChangeDialog(
    BuildContext context,
    AttendanceController controller,
    String subjectId,
    String entryId,
    String currentStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Attendance'),
        content: const Text('Select new attendance status:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (currentStatus != 'absent')
            TextButton(
              onPressed: () {
                controller.markAttendance(
                  subjectId,
                  'absent',
                  timetableEntryId: entryId,
                );
                Navigator.pop(context);
              },
              child: Text(
                'Absent',
                style: TextStyle(color: AppTheme.criticalColor),
              ),
            ),
          if (currentStatus != 'present')
            ElevatedButton(
              onPressed: () {
                controller.markAttendance(
                  subjectId,
                  'present',
                  timetableEntryId: entryId,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.safeColor,
              ),
              child: const Text('Present'),
            ),
          if (currentStatus != 'cancelled')
            TextButton(
              onPressed: () {
                controller.markAttendance(
                  subjectId,
                  'cancelled',
                  timetableEntryId: entryId,
                );
                Navigator.pop(context);
              },
              child: Text(
                'Cancelled',
                style: TextStyle(color: AppTheme.warningColor),
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
        Obx(
          () {
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Overall Attendance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(analytics['overallPercentage'] as double).toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
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
          },
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
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
    );
  }

  Widget _buildAnalyticsStat(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$present/$classes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPercentageColor(percentage).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _getPercentageColor(percentage),
              ),
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
      initialDateRange: controller.fromDate.value != null &&
              controller.toDate.value != null
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
