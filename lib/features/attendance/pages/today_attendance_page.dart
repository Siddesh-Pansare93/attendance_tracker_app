import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
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
    final subject = controller.getSubject(entry.subjectId);
    if (subject == null) return const SizedBox.shrink();

    // Use entry.id for tracking individual lecture instances
    final isMarked = controller.isMarkedToday(entry.id);
    final status = controller.getTodayStatus(entry.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
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
                    ],
                  ),
                ),
                // Current attendance
                Text(
                  '${subject.attendancePercentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getStatusColor(
                      subject.attendancePercentage,
                      controller.threshold.value,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

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
}
