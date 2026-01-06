import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';
import 'package:smart_attendance_app/features/calendar/controller/calendar_controller.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';

/// Calendar page showing attendance history
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();
    final theme = Theme.of(context);
    final storage = StorageService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
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
                Card(
                  margin: const EdgeInsets.all(16),
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppTheme.safeColor,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
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
                          bottom: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (presentCount > 0)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1,
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
                                    horizontal: 1,
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
                                    horizontal: 1,
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

                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(context, AppTheme.safeColor, 'Present'),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        context,
                        AppTheme.criticalColor,
                        'Absent',
                      ),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        context,
                        AppTheme.warningColor,
                        'Cancelled',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selected date details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AttendanceUtils.formatDateLong(
                                controller.selectedDate.value,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (controller.recordsForDate.isNotEmpty)
                            Text(
                              '${controller.recordsForDate.length} classes',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () => Get.toNamed(
                              AppRoutes.editAttendance,
                              arguments: controller.selectedDate.value,
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (controller.recordsForDate.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_available,
                                  size: 48,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No attendance recorded',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...controller.recordsForDate.map(
                          (record) =>
                              _buildRecordItem(context, record, storage),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildRecordItem(
    BuildContext context,
    AttendanceRecord record,
    StorageService storage,
  ) {
    final theme = Theme.of(context);
    final subject = storage.getSubject(record.subjectId);

    // Determine status color and text
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (record.isPresent) {
      statusColor = AppTheme.safeColor;
      statusIcon = Icons.check;
      statusText = 'Present';
    } else if (record.isCancelled) {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.event_busy;
      statusText = 'Cancelled';
    } else {
      statusColor = AppTheme.criticalColor;
      statusIcon = Icons.close;
      statusText = 'Absent';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          subject?.name ?? 'Unknown Subject',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
