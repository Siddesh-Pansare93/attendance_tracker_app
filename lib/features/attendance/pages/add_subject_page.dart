import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/features/attendance/controller/add_subject_controller.dart';

/// Page for adding or editing a subject
///
/// REFACTORED: Now a StatelessWidget using AddSubjectController
/// - No more setState() - uses GetX reactive state
/// - Form controllers moved to AddSubjectController
/// - Follows SRP - UI only handles presentation
class AddSubjectPage extends StatelessWidget {
  final bool isEdit;

  const AddSubjectPage({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    // Create controller for this page
    final controller = Get.put(AddSubjectController());

    // Initialize for edit mode if needed
    if (isEdit) {
      final editId = Get.parameters['id'];
      if (editId != null) {
        controller.initForEdit(editId);
      }
    }

    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(isEdit ? 'Edit Subject' : 'Add Subject')),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Subject name
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g., Mathematics, Physics',
                  prefixIcon: Icon(Icons.book),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Minimum attendance
              TextFormField(
                controller: controller.thresholdController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Required Attendance (%)',
                  hintText: 'e.g., 75',
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a percentage';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0 || num > 100) {
                    return 'Enter a value between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The app will alert you when your attendance falls below the minimum required percentage.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button - reactive to isLoading
              Obx(
                () => SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveSubject,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Save Changes' : 'Add Subject'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
