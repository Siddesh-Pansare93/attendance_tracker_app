import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/common/widgets/attendance_indicator.dart';
import 'package:smart_attendance_app/common/widgets/today_class_tile.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Main Dashboard/Home page showing overall attendance and subjects
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

        return Column(
          children: [
            // Fixed analytics header
            _buildOverallCard(context, controller),

            // Today's classes section (vertical scrollable list) - MAIN CONTENT
            Expanded(child: _buildTodayClassesSection(context, controller)),
          ],
        );
      }),
    );
  }

  /// Overall attendance card in the app bar
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

  /// Today's classes section - vertical scrollable list with inline attendance marking
  Widget _buildTodayClassesSection(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            "Today's Classes",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (controller.todayClasses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        color: AppTheme.safeColor,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'No classes scheduled today!',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.todayClasses.length,
              itemBuilder: (context, index) {
                final entry = controller.todayClasses[index];
                return _buildTodayClassTile(context, entry, controller);
              },
            );
          }),
        ),
      ],
    );
  }

  /// Build a single class tile with inline attendance buttons
  Widget _buildTodayClassTile(
    BuildContext context,
    TimetableEntry entry,
    DashboardController controller,
  ) {
    final subjectName = controller.getSubjectName(entry.subjectId);

    return Obx(
      () {
        final currentStatus = controller.getTodayStatus(entry.id);
        final isMarking = controller.markingInProgress.value == entry.id;

        return TodayClassTile(
          subjectName: subjectName,
          classType: entry.type,
          startTime: entry.startTime,
          endTime: entry.endTime,
          currentStatus: currentStatus,
          isMarking: isMarking,
          onPresent: () {
            controller.markAttendance(
              entry.subjectId,
              'present',
              timetableEntryId: entry.id,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marked as Present'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          onAbsent: () {
            controller.markAttendance(
              entry.subjectId,
              'absent',
              timetableEntryId: entry.id,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marked as Absent'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          onCancelled: () {
            controller.markAttendance(
              entry.subjectId,
              'cancelled',
              timetableEntryId: entry.id,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lecture Cancelled'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          onChangeStatus: () {
            _showChangeStatusDialog(context, controller, entry);
          },
        );
      },
    );
  }

  /// Show dialog to change attendance status
  void _showChangeStatusDialog(
    BuildContext context,
    DashboardController controller,
    TimetableEntry entry,
  ) {
    final currentStatus = controller.getTodayStatus(entry.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Attendance Status'),
        content: const Text('Select new attendance status:'),
        actions: [
          if (currentStatus != 'present')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.markAttendance(
                  entry.subjectId,
                  'present',
                  timetableEntryId: entry.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updated to Present'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Present'),
            ),
          if (currentStatus != 'absent')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.markAttendance(
                  entry.subjectId,
                  'absent',
                  timetableEntryId: entry.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updated to Absent'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Absent'),
            ),
          if (currentStatus != 'cancelled')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.markAttendance(
                  entry.subjectId,
                  'cancelled',
                  timetableEntryId: entry.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updated to Cancelled'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Lecture Cancelled'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
