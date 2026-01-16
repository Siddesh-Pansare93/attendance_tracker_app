import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';
import 'package:smart_attendance_app/features/timetable/controller/add_timetable_entry_controller.dart';

/// Page for adding or editing a timetable entry
///
/// REFACTORED: Now a StatelessWidget using AddTimetableEntryController
/// - No more setState() - uses GetX reactive state (.obs)
/// - Form state moved to AddTimetableEntryController
/// - Follows SRP - UI only handles presentation
class AddTimetableEntryPage extends StatelessWidget {
  final bool isEdit;

  const AddTimetableEntryPage({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    // Create controller for this page
    final controller = Get.put(AddTimetableEntryController());
    final timetableController = Get.find<TimetableController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Initialize for edit mode if needed
    if (isEdit) {
      final editId = Get.parameters['id'];
      if (editId != null) {
        controller.initForEdit(editId);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Entry' : 'Add Class')),
      body: Obx(() {
        final subjects = timetableController.subjects;

        if (subjects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warning_amber,
                      size: 40,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Subjects Found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please add subjects first before creating a timetable.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        elevation: 0,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Form section label
            Text(
              'Class Details',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Subject dropdown
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Select a subject',
                  prefixIcon: const Icon(Icons.book, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
                items: subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject.id,
                    child: Text(subject.name),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedSubjectId.value = value;
                },
                initialValue: controller.selectedSubjectId.value,
                validator: (value) {
                  if (value == null) return 'Please select a subject';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Day of week
            Obx(
              () => DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Day of Week',
                  hintText: 'Select a day',
                  prefixIcon: const Icon(Icons.calendar_today, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
                items: List.generate(7, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(kDayNames[index]),
                  );
                }),
                onChanged: (value) {
                  if (value != null) controller.selectedDay.value = value;
                },
                initialValue: controller.selectedDay.value,
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: isDark
                        ? AppTheme.darkBorderStrong
                        : AppTheme.borderStrong,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          isEdit ? 'Save Changes' : 'Add Class',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                  side: BorderSide(
                    color: isDark
                        ? AppTheme.darkBorderSubtle
                        : AppTheme.borderSubtle,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
