import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Modern timetable page with clean design
class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimetableController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBgPrimary : AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => controller.loadTimetable(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addTimetableEntry),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Day tabs
            _buildDayTabs(context, controller, isDark),

            // Entries for selected day
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTimetable,
                child: _buildEntriesList(context, controller, isDark),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDayTabs(
    BuildContext context,
    TimetableController controller,
    bool isDark,
  ) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDark ? AppTheme.darkBgPrimary : AppTheme.bgPrimary,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = index;
          return Obx(() {
            final isSelected = controller.selectedDay.value == day;
            final hasClasses = controller.hasClassesOnDay(day);
            final classCount = controller.getClassCountForDay(day);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => controller.selectedDay.value = day,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDark
                              ? AppTheme.darkSurfaceDefault
                              : AppTheme.surfaceDefault),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (isDark
                                ? AppTheme.darkBorderSubtle
                                : AppTheme.borderSubtle),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        kShortDayNames[day],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textSecondary),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasClasses)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$classCount',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildEntriesList(
    BuildContext context,
    TimetableController controller,
    bool isDark,
  ) {
    return Obx(() {
      final entries = controller.entriesForDay;

      if (entries.isEmpty) {
        return NoTimetableEmpty(
          onAdd: () => Get.toNamed(AppRoutes.addTimetableEntry),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildEntryCard(context, entry, controller, isDark);
        },
      );
    });
  }

  Widget _buildEntryCard(
    BuildContext context,
    TimetableEntry entry,
    TimetableController controller,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final subjectName = controller.getSubjectName(entry.subjectId);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.criticalColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) => controller.deleteEntry(entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.schedule_outlined,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Subject info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.startTime} - ${entry.endTime} (${entry.type})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextMuted
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppTheme.criticalColor.withValues(alpha: 0.7),
                size: 20,
              ),
              onPressed: () async {
                final confirm = await _confirmDelete(context);
                if (confirm) controller.deleteEntry(entry.id);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark
                ? AppTheme.darkSurfaceDefault
                : AppTheme.surfaceDefault,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Delete Class'),
            content: const Text(
              'Are you sure you want to remove this class from the timetable?',
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
}
