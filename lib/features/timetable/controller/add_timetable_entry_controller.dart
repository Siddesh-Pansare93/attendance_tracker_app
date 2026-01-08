import 'package:get/get.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';

/// Controller for AddTimetableEntryPage - handles form state and logic
///
/// This follows Single Responsibility Principle (SRP):
/// - Only handles form state for adding/editing a timetable entry
/// - Delegates actual CRUD to TimetableController
class AddTimetableEntryController extends GetxController {
  // Dependencies
  TimetableController get _timetableController =>
      Get.find<TimetableController>();

  // Observable form state
  final selectedSubjectId = Rxn<String>();
  final selectedDay = 1.obs; // Monday by default
  final isLoading = false.obs;
  final isEdit = false.obs;
  String? editId;

  @override
  void onInit() {
    super.onInit();
    // Set default day from timetable controller's selected day
    selectedDay.value = _timetableController.selectedDay.value;
  }

  /// Initialize for editing an existing entry
  void initForEdit(String id) {
    isEdit.value = true;
    editId = id;
    final entry = _timetableController.getEntry(id);
    if (entry != null) {
      selectedSubjectId.value = entry.subjectId;
      selectedDay.value = entry.dayOfWeek;
    }
  }

  /// Save timetable entry (add new or update existing)
  Future<void> saveEntry() async {
    if (selectedSubjectId.value == null) {
      Get.snackbar(
        'Error',
        'Please select a subject',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      if (isEdit.value && editId != null) {
        // Delete old entry and create new one (simpler than partial update)
        await _timetableController.deleteEntry(editId!);
      }

      await _timetableController.addEntry(
        subjectId: selectedSubjectId.value!,
        dayOfWeek: selectedDay.value,
      );

      Get.back();
      Get.snackbar(
        'Success',
        isEdit.value ? 'Class updated!' : 'Class added!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
