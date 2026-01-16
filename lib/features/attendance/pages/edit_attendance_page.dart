import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/common/widgets/attendance_status_badge.dart';
import 'package:smart_attendance_app/common/widgets/attendance_action_buttons.dart';
import 'package:smart_attendance_app/features/attendance/controller/edit_attendance_controller.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Page for editing attendance on any date
///
/// REFACTORED: Now a StatelessWidget using EditAttendanceController
/// - No more setState() - uses GetX reactive state
/// - Business logic moved to EditAttendanceController
/// - Uses reusable widgets (AttendanceStatusBadge, AttendanceActionButtons)
/// - Follows SRP - UI only handles presentation
class EditAttendancePage extends StatelessWidget {
  const EditAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create controller for this page
    final controller = Get.put(EditAttendanceController());

    // Initialize with date from arguments
    final date = Get.arguments as DateTime? ?? DateTime.now();
    controller.initWithDate(date);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(AttendanceUtils.formatDateLong(date))),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No classes scheduled',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'on ${AttendanceUtils.formatDateLong(date)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.entries.length,
          itemBuilder: (context, index) => _buildClassCard(
            context,
            controller.entries[index],
            controller,
            isDark,
          ),
        );
      }),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    TimetableEntry entry,
    EditAttendanceController controller,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final subject = controller.getSubject(entry.subjectId);
    if (subject == null) {
      return const SizedBox.shrink();
    }
    final status = controller.getRecordStatus(entry.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book,
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
                      subject.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${subject.attendancePercentage.toStringAsFixed(1)}% attendance',
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
            ],
          ),
          const SizedBox(height: 12),

          // Status or action buttons - now using reusable widgets!
          if (status != null)
            AttendanceStatusBadge(
              status: status,
              onChangePressed: () =>
                  _showChangeDialog(context, entry, controller, status),
            )
          else
            AttendanceActionButtons(
              onPresent: () => controller.markAttendance(entry, 'present'),
              onAbsent: () => controller.markAttendance(entry, 'absent'),
              onCancelled: () => controller.markAttendance(entry, 'cancelled'),
            ),
        ],
      ),
    );
  }

  void _showChangeDialog(
    BuildContext context,
    TimetableEntry entry,
    EditAttendanceController controller,
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
                controller.markAttendance(entry, 'absent');
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
                controller.markAttendance(entry, 'present');
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
                controller.markAttendance(entry, 'cancelled');
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
