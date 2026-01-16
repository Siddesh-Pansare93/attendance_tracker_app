import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
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

    // Initialize for edit mode if needed
    if (isEdit) {
      final editId = Get.parameters['id'];
      if (editId != null) {
        controller.initForEdit(editId);
      }
    }

    final theme = Theme.of(context);

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
                  const Icon(
                    Icons.warning_amber,
                    size: 64,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text('No Subjects Found', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Please add subjects first before creating a timetable.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Subject dropdown - auto-selects
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Icons.book),
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

            // Day of week - auto-selects
            Obx(
              () => DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  prefixIcon: Icon(Icons.calendar_today),
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
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveEntry,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Save Changes' : 'Add Class'),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
