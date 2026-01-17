import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';

/// Modern minimalist dashboard page with clean SaaS design
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBgPrimary : AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => Future.value(controller.refreshData()),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Overall attendance card
                _buildOverallCard(context, controller, isDark),
                const SizedBox(height: 24),

                // Today's classes section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Classes",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Obx(
                                () => Text(
                                  '${controller.todayClasses.length} classes',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppTheme.darkTextMuted
                                            : AppTheme.textMuted,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showAddExtraLectureModal(context, controller),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Classes list
                      _buildClassesList(context, controller, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Overall attendance card with circular indicator
  Widget _buildOverallCard(
    BuildContext context,
    DashboardController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryColor.withValues(alpha: 0.15)
                        : AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment_outlined,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Attendance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => Text(
                        '${controller.overallPercentage.value.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                              fontSize: 28,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            Obx(
              () => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: controller.overallPercentage.value / 100,
                  backgroundColor: isDark
                      ? AppTheme.darkBgSecondary
                      : AppTheme.bgSecondary,
                  valueColor: AlwaysStoppedAnimation(
                    AppTheme.getStatusColor(
                      controller.overallPercentage.value,
                      controller.threshold.value,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBadge(
                    context,
                    '${controller.subjects.length}',
                    'Subjects',
                    isDark,
                  ),
                  _buildStatBadge(
                    context,
                    '${controller.subjectsAboveThreshold}',
                    'Safe',
                    isDark,
                    color: AppTheme.safeColor,
                  ),
                  _buildStatBadge(
                    context,
                    '${controller.subjectsBelowThreshold}',
                    'At Risk',
                    isDark,
                    color: AppTheme.criticalColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small stat badge
  Widget _buildStatBadge(
    BuildContext context,
    String value,
    String label,
    bool isDark, {
    Color? color,
  }) {
    final finalColor = color ?? AppTheme.primaryColor;

    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: finalColor,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Classes list view
  Widget _buildClassesList(
    BuildContext context,
    DashboardController controller,
    bool isDark,
  ) {
    return Obx(() {
      if (controller.todayClasses.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBgSecondary : AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 48,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'No classes today',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.todayClasses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = controller.todayClasses[index];
          return _buildClassTile(context, entry, controller, isDark);
        },
      );
    });
  }

  /// Individual class tile
  Widget _buildClassTile(
    BuildContext context,
    TimetableEntry entry,
    DashboardController controller,
    bool isDark,
  ) {
    final subjectName = controller.getSubjectName(entry.subjectId);

    return Obx(() {
      final currentStatus = controller.getTodayStatus(entry.id);
      final isMarking = controller.markingInProgress.value == entry.id;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Subject info
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Time indicator
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryColor.withValues(alpha: 0.12)
                        : AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${entry.startTime} - ${entry.endTime}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextMuted
                              : AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _buildStatusBadge(context, currentStatus, isDark),
              ],
            ),
            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    context,
                    'Present',
                    Icons.check,
                    AppTheme.safeColor,
                    isMarking,
                    () => controller.markAttendance(
                      entry.subjectId,
                      'present',
                      timetableEntryId: entry.id,
                    ),
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    context,
                    'Absent',
                    Icons.close,
                    AppTheme.criticalColor,
                    isMarking,
                    () => controller.markAttendance(
                      entry.subjectId,
                      'absent',
                      timetableEntryId: entry.id,
                    ),
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    context,
                    'Cancel',
                    Icons.event_busy_outlined,
                    AppTheme.warningColor,
                    isMarking,
                    () => controller.markAttendance(
                      entry.subjectId,
                      'cancelled',
                      timetableEntryId: entry.id,
                    ),
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Status badge
  Widget _buildStatusBadge(BuildContext context, String? status, bool isDark) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'present':
        statusColor = AppTheme.safeColor;
        statusIcon = Icons.check_circle;
        statusText = 'Present';
        break;
      case 'absent':
        statusColor = AppTheme.criticalColor;
        statusIcon = Icons.cancel;
        statusText = 'Absent';
        break;
      case 'cancelled':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.event_busy;
        statusText = 'Cancel';
        break;
      default:
        statusColor = isDark
            ? AppTheme.darkBorderSubtle
            : AppTheme.borderSubtle;
        statusIcon = Icons.circle_outlined;
        statusText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? statusColor.withValues(alpha: 0.12)
            : statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Action button
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool isLoading,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      ),
    );
  }

  /// Show add extra lecture modal
  void _showAddExtraLectureModal(
    BuildContext context,
    DashboardController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedSubjectId;
    DateTime selectedDate = DateTime.now();
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Extra Lecture'),
              backgroundColor: isDark
                  ? AppTheme.darkSurfaceDefault
                  : AppTheme.surfaceDefault,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select Subject'),
                        value: selectedSubjectId,
                        items: controller.subjects.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedSubjectId = value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorderSubtle
                                : AppTheme.borderSubtle,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AttendanceUtils.formatDateForDisplay(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select Status'),
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'present',
                          child: Text('Present'),
                        ),
                        DropdownMenuItem(
                          value: 'absent',
                          child: Text('Absent'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedStatus = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedSubjectId != null && selectedStatus != null
                      ? () {
                          final dateStr = AttendanceUtils.formatDateForStorage(
                            selectedDate,
                          );
                          controller.addExtraLecture(
                            selectedSubjectId!,
                            dateStr,
                            selectedStatus!,
                          );
                          Navigator.pop(context);
                          Get.snackbar(
                            'Success',
                            'Extra lecture added!',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
