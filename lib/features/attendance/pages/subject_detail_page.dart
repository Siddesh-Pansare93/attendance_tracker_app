import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/common/widgets/attendance_indicator.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';

/// Page showing detailed information about a subject
class SubjectDetailPage extends StatefulWidget {
  const SubjectDetailPage({super.key});

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  late final String subjectId;

  @override
  void initState() {
    super.initState();
    subjectId = Get.parameters['id'] ?? '';
    Get.find<AttendanceController>().loadSubjectDetail(subjectId);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.selectedSubject.value?.name ?? 'Subject'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, controller),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.getStatusColor(
                            percentage,
                            controller.threshold.value,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusMessage,
                          style: TextStyle(
                            color: AppTheme.getStatusColor(
                              percentage,
                              controller.threshold.value,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 24),

              // History section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${controller.subjectHistory.length} records',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    color ??= theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    AttendanceRecord record,
    AttendanceController controller,
  ) {
    final theme = Theme.of(context);
    final date = AttendanceUtils.parseDate(record.date);
    final isPresent = record.isPresent;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppTheme.criticalColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) => controller.deleteAttendanceRecord(record),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isPresent ? AppTheme.safeColor : AppTheme.criticalColor)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPresent ? Icons.check : Icons.close,
              color: isPresent ? AppTheme.safeColor : AppTheme.criticalColor,
            ),
          ),
          title: Text(
            AttendanceUtils.formatDateForDisplay(date),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            AttendanceUtils.formatDateLong(date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isPresent ? AppTheme.safeColor : AppTheme.criticalColor)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isPresent ? 'Present' : 'Absent',
              style: TextStyle(
                color: isPresent ? AppTheme.safeColor : AppTheme.criticalColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
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

  void _handleMenuAction(String action, AttendanceController controller) {
    switch (action) {
      case 'edit':
        Get.toNamed('/subject/edit/$subjectId');
        break;
      case 'delete':
        _showDeleteConfirmation(controller);
        break;
    }
  }

  void _showDeleteConfirmation(AttendanceController controller) {
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
