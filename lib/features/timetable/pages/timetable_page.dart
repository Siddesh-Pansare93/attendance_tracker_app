import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/common/widgets/empty_state.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Page displaying weekly timetable - simplified to just show subjects per day
class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimetableController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            onPressed: () => controller.loadTimetable(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addTimetableEntry),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Day tabs
            _buildDayTabs(context, controller),

            // Entries for selected day
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTimetable,
                child: _buildEntriesList(context, controller),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDayTabs(BuildContext context, TimetableController controller) {
    final theme = Theme.of(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                onTap: () {
                  controller.selectedDay.value = day;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
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
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (hasClasses)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$classCount',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
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
  ) {
    return Obx(() {
      final entries = controller.entriesForDay;

      if (entries.isEmpty) {
        return NoTimetableEmpty(
          onAdd: () => Get.toNamed(AppRoutes.addTimetableEntry),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildEntryCard(context, entry, controller);
        },
      );
    });
  }

  Widget _buildEntryCard(
    BuildContext context,
    TimetableEntry entry,
    TimetableController controller,
  ) {
    final theme = Theme.of(context);
    final subjectName = controller.getSubjectName(entry.subjectId);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) => controller.deleteEntry(entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161622) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A3C) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Subject icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.book_rounded,
                color: theme.colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Subject info
            Expanded(
              child: Text(
                subjectName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error.withValues(alpha: 0.7),
              ),
              onPressed: () async {
                final confirm = await _confirmDelete(context);
                if (confirm) controller.deleteEntry(entry.id);
              },
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
