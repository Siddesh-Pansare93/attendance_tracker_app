import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/features/calendar/controller/calendar_controller.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';

/// Modern minimal calendar page with clean SaaS design
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();
    final theme = Theme.of(context);
    final subjectRepo = Get.find<SubjectRepository>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBgPrimary : AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => controller.loadRecords(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.loadRecords,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Calendar widget
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceDefault
                          : AppTheme.surfaceDefault,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorderSubtle
                            : AppTheme.borderSubtle,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: controller.focusedDate.value,
                      selectedDayPredicate: (day) =>
                          isSameDay(controller.selectedDate.value, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        controller.selectDate(selectedDay);
                        controller.onPageChanged(focusedDay);
                      },
                      onPageChanged: controller.onPageChanged,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: TextStyle(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                        defaultTextStyle: TextStyle(
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          size: 20,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          size: 20,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AppTheme.darkBorderSubtle
                                  : AppTheme.borderSubtle,
                            ),
                          ),
                        ),
                        headerPadding: const EdgeInsets.only(bottom: 12),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AppTheme.darkBorderSubtle
                                  : AppTheme.borderSubtle,
                            ),
                          ),
                        ),
                        weekdayStyle: TextStyle(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        weekendStyle: TextStyle(
                          color: isDark
                              ? AppTheme.darkTextMuted
                              : AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final records = controller.getRecordsForDate(date);
                          if (records.isEmpty) return null;

                          final presentCount = records
                              .where((r) => r.isPresent)
                              .length;
                          final absentCount = records
                              .where((r) => r.isAbsent)
                              .length;
                          final cancelledCount = records
                              .where((r) => r.isCancelled)
                              .length;

                          return Positioned(
                            bottom: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (presentCount > 0)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.safeColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (absentCount > 0)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.criticalColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (cancelledCount > 0)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.warningColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        context,
                        AppTheme.safeColor,
                        'Present',
                        isDark,
                      ),
                      const SizedBox(width: 20),
                      _buildLegendItem(
                        context,
                        AppTheme.criticalColor,
                        'Absent',
                        isDark,
                      ),
                      const SizedBox(width: 20),
                      _buildLegendItem(
                        context,
                        AppTheme.warningColor,
                        'Cancelled',
                        isDark,
                      ),
                    ],
                  ),
                ),

                // Selected date details
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date header with edit button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AttendanceUtils.formatDateLong(
                                  controller.selectedDate.value,
                                ),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(
                                () => Text(
                                  '${controller.recordsForDate.length} classes',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppTheme.darkTextMuted
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Get.toNamed(
                              AppRoutes.editAttendance,
                              arguments: controller.selectedDate.value,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
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

                      // Records list
                      if (controller.recordsForDate.isEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkBgSecondary
                                : AppTheme.bgSecondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorderSubtle
                                  : AppTheme.borderSubtle,
                            ),
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                size: 48,
                                color: isDark
                                    ? AppTheme.darkTextMuted
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No attendance recorded',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.recordsForDate.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final record = controller.recordsForDate[index];
                            return _buildRecordItem(
                              context,
                              record,
                              subjectRepo,
                              isDark,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    Color color,
    String label,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordItem(
    BuildContext context,
    AttendanceRecord record,
    SubjectRepository subjectRepo,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final subject = subjectRepo.getById(record.subjectId);

    // Determine status
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (record.isPresent) {
      statusColor = AppTheme.safeColor;
      statusIcon = Icons.check_circle_outlined;
      statusText = 'Present';
    } else if (record.isCancelled) {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.event_busy_outlined;
      statusText = 'Cancelled';
    } else {
      statusColor = AppTheme.criticalColor;
      statusIcon = Icons.cancel_outlined;
      statusText = 'Absent';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? statusColor.withValues(alpha: 0.15)
                  : statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),

          // Subject info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject?.name ?? 'Unknown Subject',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Class on ${AttendanceUtils.formatDateForDisplay(AttendanceUtils.parseDate(record.date))}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? statusColor.withValues(alpha: 0.15)
                  : statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
