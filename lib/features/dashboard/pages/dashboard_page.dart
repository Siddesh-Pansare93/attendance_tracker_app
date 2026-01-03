import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/common/widgets/attendance_indicator.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Main Dashboard/Home page showing overall attendance and subjects
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildOverallCard(context, controller),
                ),
                title: const Text('Dashboard'),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Today's classes section
                      _buildTodaySection(context, controller),
                      const SizedBox(height: 24),

                      // Subjects section
                      _buildSubjectsSection(context, controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          _buildMiniStat(
                            context,
                            '${controller.subjects.length}',
                            'Subjects',
                          ),
                          const SizedBox(width: 16),
                          _buildMiniStat(
                            context,
                            '${controller.subjectsAboveThreshold}',
                            'Safe',
                            color: AppTheme.safeColor,
                          ),
                          const SizedBox(width: 16),
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
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  /// Today's classes section
  Widget _buildTodaySection(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Classes",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.today),
              child: const Text('Mark Attendance →'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Obx(() {
          if (controller.todayClasses.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available,
                      color: AppTheme.safeColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'No classes scheduled today!',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.todayClasses.length,
              itemBuilder: (context, index) {
                final entry = controller.todayClasses[index];
                return _buildTodayClassCard(context, entry, controller);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTodayClassCard(
    BuildContext context,
    TimetableEntry entry,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);
    final subjectName = controller.getSubjectName(entry.subjectId);
    final isMarked = controller.isAttendanceMarkedToday(entry.subjectId);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.today),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subjectName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMarked)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.safeColor,
                        size: 18,
                      ),
                  ],
                ),
                Text(
                  AttendanceUtils.formatTimeRange(
                    entry.startTime,
                    entry.endTime,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.type,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Subjects list section
  Widget _buildSubjectsSection(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Subjects',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.addSubject),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Obx(() {
          if (controller.subjects.isEmpty) {
            return NoSubjectsEmpty(
              onAdd: () => Get.toNamed(AppRoutes.addSubject),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.subjects.length,
            itemBuilder: (context, index) {
              final subject = controller.subjects[index];
              return _buildSubjectCard(context, subject, controller);
            },
          );
        }),
      ],
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    Subject subject,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);
    final percentage = subject.attendancePercentage;
    final statusMessage = AttendanceUtils.getStatusMessage(
      subject.attendedClasses,
      subject.totalClasses,
      controller.threshold.value,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.toNamed('/subject/${subject.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Percentage indicator
              AttendanceIndicator(
                percentage: percentage,
                threshold: controller.threshold.value,
                size: 56,
                showLabel: false,
              ),
              const SizedBox(width: 16),

              // Subject info
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
                    const SizedBox(height: 4),
                    Text(
                      '${subject.attendedClasses} / ${subject.totalClasses} classes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getStatusColor(
                          percentage,
                          controller.threshold.value,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              StatusBadge(
                percentage: percentage,
                threshold: controller.threshold.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
