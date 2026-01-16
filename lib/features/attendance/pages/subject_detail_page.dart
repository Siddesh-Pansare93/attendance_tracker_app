import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/common/widgets/attendance_indicator.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';

/// Page showing detailed information about a subject
///
/// REFACTORED: Now a StatelessWidget
/// - Was StatefulWidget unnecessarily
/// - Now properly uses GetX reactive patterns
/// - Follows SRP - UI only handles presentation
class SubjectDetailPage extends StatelessWidget {
  const SubjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectId = Get.parameters['id'] ?? '';
    final controller = Get.find<AttendanceController>();
    final theme = Theme.of(context);

    // Load subject detail when page opens
    controller.loadSubjectDetail(subjectId);

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.selectedSubject.value?.name ?? 'Subject'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(value, controller, subjectId, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Subject'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppTheme.criticalColor),
                    SizedBox(width: 8),
                    Text(
                      'Delete Subject',
                      style: TextStyle(color: AppTheme.criticalColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final subject = controller.selectedSubject.value;
        if (subject == null) {
          return const Center(child: Text('Subject not found'));
        }

        final percentage = subject.attendancePercentage;
        final statusMessage = AttendanceUtils.getStatusMessage(
          subject.attendedClasses,
          subject.totalClasses,
          controller.threshold.value,
        );

        return RefreshIndicator(
          onRefresh: () => controller.loadSubjectDetail(subjectId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Main stats card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkSurfaceDefault
                      : AppTheme.surfaceDefault,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkBorderSubtle
                        : AppTheme.borderSubtle,
                  ),
                ),
                child: Column(
                  children: [
                    // Circular indicator
                    AttendanceIndicator(
                      percentage: percentage,
                      threshold: controller.threshold.value,
                      size: 120,
                    ),
                    const SizedBox(height: 20),

                    // Status message
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getStatusColor(
                          percentage,
                          controller.threshold.value,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.getStatusColor(
                            percentage,
                            controller.threshold.value,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        statusMessage,
                        style: TextStyle(
                          color: AppTheme.getStatusColor(
                            percentage,
                            controller.threshold.value,
                          ),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total',
                      '${subject.totalClasses}',
                      Icons.class_,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Present',
                      '${subject.attendedClasses}',
                      Icons.check_circle,
                      AppTheme.safeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Absent',
                      '${subject.totalClasses - subject.attendedClasses}',
                      Icons.cancel,
                      AppTheme.criticalColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // History section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${controller.subjectHistory.length} records',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkTextMuted
                          : AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (controller.subjectHistory.isEmpty)
                const NoAttendanceRecordsEmpty()
              else
                ...controller.subjectHistory.map(
                  (record) => _buildHistoryItem(context, record, controller),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    color ??= AppTheme.primaryColor;

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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

  Widget _buildHistoryItem(
    BuildContext context,
    AttendanceRecord record,
    AttendanceController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final date = AttendanceUtils.parseDate(record.date);
    final isPresent = record.isPresent;
    final statusColor = isPresent ? AppTheme.safeColor : AppTheme.criticalColor;
    final statusLabel = isPresent ? 'Present' : 'Absent';
    final statusIcon = isPresent ? Icons.check_circle : Icons.cancel;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppTheme.criticalColor,
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) => controller.deleteAttendanceRecord(record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AttendanceUtils.formatDateForDisplay(date),
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
                  const SizedBox(height: 2),
                  Text(
                    AttendanceUtils.formatDateLong(date),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Record'),
            content: const Text(
              'Are you sure you want to delete this attendance record?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.criticalColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleMenuAction(
    String action,
    AttendanceController controller,
    String subjectId,
    BuildContext context,
  ) {
    switch (action) {
      case 'edit':
        Get.toNamed(AppRoutes.editSubject.replaceAll(':id', subjectId));
        break;
      case 'delete':
        _showDeleteConfirmation(controller, subjectId, context);
        break;
    }
  }

  void _showDeleteConfirmation(
    AttendanceController controller,
    String subjectId,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text(
          'Are you sure you want to delete this subject? All attendance records will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteSubject(subjectId);
              Navigator.pop(context);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.criticalColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
