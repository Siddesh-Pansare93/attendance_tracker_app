import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/repositories/settings_repository.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';

/// Controller for AddSubjectPage - handles form state and logic
///
/// This follows Single Responsibility Principle (SRP):
/// - Only handles form state for adding/editing a subject
/// - Delegates actual CRUD to AttendanceController
class AddSubjectController extends GetxController {
  // Dependencies
  AttendanceController get _attendanceController =>
      Get.find<AttendanceController>();
  SettingsRepository get _settingsRepo => Get.find<SettingsRepository>();

  // Form controllers
  final nameController = TextEditingController();
  final thresholdController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observable state
  final isLoading = false.obs;
  final isEdit = false.obs;
  String? editId;

  @override
  void onInit() {
    super.onInit();
    // Set default threshold
    thresholdController.text = _settingsRepo
        .getAttendanceThreshold()
        .toStringAsFixed(0);
  }

  /// Initialize for editing an existing subject
  void initForEdit(String id) {
    isEdit.value = true;
    editId = id;
    final subject = _attendanceController.getSubject(id);
    if (subject != null) {
      nameController.text = subject.name;
      thresholdController.text = subject.minimumRequiredPercentage
          .toStringAsFixed(0);
    }
  }

  /// Save subject (add new or update existing)
  Future<void> saveSubject() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final name = nameController.text.trim();
      final threshold = double.parse(thresholdController.text);

      if (isEdit.value && editId != null) {
        // Update existing subject
        final subject = _attendanceController.getSubject(editId!);
        if (subject != null) {
          subject.name = name;
          subject.minimumRequiredPercentage = threshold;
          await _attendanceController.updateSubject(subject);
        }
      } else {
        // Add new subject
        await _attendanceController.addSubject(name, minPercentage: threshold);
      }

      Get.back();
      Get.snackbar(
        'Success',
        isEdit.value ? 'Subject updated!' : 'Subject added!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save subject. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    thresholdController.dispose();
    super.onClose();
  }
}
