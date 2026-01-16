import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Subject' : 'Add Subject'),
        elevation: 0,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject name field
              Text(
                'Subject Details',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Subject name
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g., Mathematics, Physics',
                  prefixIcon: const Icon(Icons.book, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                ),
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
                decoration: InputDecoration(
                  labelText: 'Minimum Required Attendance (%)',
                  hintText: 'e.g., 75',
                  prefixIcon: const Icon(Icons.percent, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  suffixText: '%',
                  suffixStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                ),
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
              const SizedBox(height: 28),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.infoColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppTheme.infoColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The app will alert you when your attendance falls below the minimum required percentage.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button - reactive to isLoading
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveSubject,
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
                            isEdit ? 'Save Changes' : 'Add Subject',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button (secondary)
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
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
