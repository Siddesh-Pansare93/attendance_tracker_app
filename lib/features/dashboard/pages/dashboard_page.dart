import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/common/widgets/attendance_indicator.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';

/// Main Dashboard/Home page showing overall attendance, analytics, and extra lectures
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Overall attendance card
              _buildOverallCard(context, controller),

              // Analytics section
              _buildAnalyticsSection(context, controller),

              // Extra lectures section
              _buildExtraLecturesSection(context, controller),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  /// Overall attendance card in the header
  Widget _buildOverallCard(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: AppTheme.primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          child: Row(
            children: [
              // Circular indicator
              Obx(
                () => AttendanceIndicator(
                  percentage: controller.overallPercentage.value,
                  threshold: controller.threshold.value,
                  size: 100,
                ),
              ),
              const SizedBox(width: 24),

              // Stats
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Attendance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Row(
                        children: [
                          _buildMiniStat(
                            context,
                            '${controller.subjects.length}',
                            'Subjects',
                          ),
                          const SizedBox(width: 20),
                          _buildMiniStat(
                            context,
                            '${controller.subjectsAboveThreshold}',
                            'Safe',
                            color: AppTheme.safeColor,
                          ),
                          const SizedBox(width: 20),
                          _buildMiniStat(
                            context,
                            '${controller.subjectsBelowThreshold}',
                            'At Risk',
                            color: AppTheme.criticalColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String value,
    String label, {
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Analytics section with filters and stats
  Widget _buildAnalyticsSection(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Analytics" and "Add Extra Lecture" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddExtraLectureModal(context, controller),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Extra Lecture'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Analytics filter tabs
          _buildAnalyticsFilterTabs(context, controller),
          const SizedBox(height: 16),

          // Analytics stats cards
          Obx(
            () {
              final analytics = controller.getAnalyticsData();
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
      ),
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

  /// Extra lectures section
  Widget _buildExtraLecturesSection(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return Obx(
      () {
        if (controller.extraLectures.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Extra Lectures (Today)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...controller.extraLectures.map(
                (record) => _buildExtraLectureTile(context, controller, record),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExtraLectureTile(
    BuildContext context,
    DashboardController controller,
    dynamic record,
  ) {
    final theme = Theme.of(context);
    final subjectName = controller.getSubjectName(record.subjectId);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.status) {
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
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
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
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () =>
                _showEditExtraLectureModal(context, controller, record),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            color: AppTheme.criticalColor,
            onPressed: () => _showDeleteConfirmation(
              context,
              () => controller.deleteExtraLecture(record.id),
            ),
          ),
        ],
      ),
    );
  }

  /// Show modal to add extra lecture
  void _showAddExtraLectureModal(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);
    String? selectedSubjectId;
    DateTime selectedDate = DateTime.now();
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Extra Lecture'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject dropdown
                  Text(
                    'Subject',
                    style: theme.textTheme.bodySmall?.copyWith(
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
                      onChanged: (value) {
                        setState(() => selectedSubjectId = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  Text(
                    'Date',
                    style: theme.textTheme.bodySmall?.copyWith(
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
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AttendanceUtils.formatDateForDisplay(selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  Text(
                    'Status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select Status'),
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'present', child: Text('Present')),
                      DropdownMenuItem(value: 'absent', child: Text('Absent')),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedSubjectId != null && selectedStatus != null
                ? () {
                    final dateStr =
                        AttendanceUtils.formatDateForStorage(selectedDate);
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
                      duration: const Duration(seconds: 2),
                    );
                  }
                : null,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Show modal to edit extra lecture
  void _showEditExtraLectureModal(
    BuildContext context,
    DashboardController controller,
    dynamic record,
  ) {
    final theme = Theme.of(context);
    String? selectedSubjectId = record.subjectId;
    DateTime selectedDate = AttendanceUtils.parseDate(record.date);
    String? selectedStatus = record.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Extra Lecture'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject dropdown
                  Text(
                    'Subject',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButton<String>(
                      isExpanded: true,
                      value: selectedSubjectId,
                      items: controller.subjects.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedSubjectId = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  Text(
                    'Date',
                    style: theme.textTheme.bodySmall?.copyWith(
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
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AttendanceUtils.formatDateForDisplay(selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  Text(
                    'Status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'present', child: Text('Present')),
                      DropdownMenuItem(value: 'absent', child: Text('Absent')),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedSubjectId != null && selectedStatus != null
                ? () {
                    final dateStr =
                        AttendanceUtils.formatDateForStorage(selectedDate);
                    controller.updateExtraLecture(
                      record.id,
                      selectedSubjectId!,
                      dateStr,
                      selectedStatus!,
                    );
                    Navigator.pop(context);
                    Get.snackbar(
                      'Success',
                      'Extra lecture updated!',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  }
                : null,
            child: const Text('Update'),
          ),
        ],
      ),
    );
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

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Extra Lecture?'),
        content: const Text(
          'This will remove the extra lecture record and update attendance statistics.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              Get.snackbar(
                'Deleted',
                'Extra lecture removed',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
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
