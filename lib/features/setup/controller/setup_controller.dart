import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Controller for the first-time setup flow
class SetupController extends GetxController {
  final StorageService _storage = StorageService.instance;
  final _uuid = const Uuid();

  // Observable state
  final currentStep = 0.obs; // 0: welcome, 1: subjects, 2: timetable
  final subjects = <Subject>[].obs;
  final timetableEntries = <TimetableEntry>[].obs;
  final threshold = kDefaultAttendanceThreshold.obs;
  final isLoading = false.obs;

  /// Add a new subject during setup
  void addSubject(String name) {
    final subject = Subject(
      id: _uuid.v4(),
      name: name.trim(),
      minimumRequiredPercentage: threshold.value,
    );
    subjects.add(subject);
  }

  /// Remove a subject during setup
  void removeSubject(String id) {
    subjects.removeWhere((s) => s.id == id);
    // Also remove related timetable entries
    timetableEntries.removeWhere((e) => e.subjectId == id);
  }

  /// Add a timetable entry during setup
  void addTimetableEntry({
    required String subjectId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String type = 'Lecture',
  }) {
    final entry = TimetableEntry(
      id: _uuid.v4(),
      subjectId: subjectId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      type: type,
    );
    timetableEntries.add(entry);
  }

  /// Remove a timetable entry during setup
  void removeTimetableEntry(String id) {
    timetableEntries.removeWhere((e) => e.id == id);
  }

  /// Update threshold
  void updateThreshold(double value) {
    threshold.value = value;
    // Update all subjects with new threshold
    for (final subject in subjects) {
      subject.minimumRequiredPercentage = value;
    }
  }

  /// Complete setup and save all data
  Future<void> completeSetup() async {
    isLoading.value = true;
    try {
      // Save threshold
      await _storage.setAttendanceThreshold(threshold.value);

      // Save all subjects
      for (final subject in subjects) {
        await _storage.saveSubject(subject);
      }

      // Save all timetable entries
      for (final entry in timetableEntries) {
        await _storage.saveTimetableEntry(entry);
      }

      // Mark setup as complete
      await _storage.setSetupComplete(true);

      // Navigate to home
      Get.offAllNamed('/home');
    } finally {
      isLoading.value = false;
    }
  }

  /// Skip setup (for users who want to configure later)
  Future<void> skipSetup() async {
    await _storage.setSetupComplete(true);
    Get.offAllNamed('/home');
  }

  /// Go to next step
  void nextStep() {
    currentStep.value++;
  }

  /// Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Get subject name by ID
  String getSubjectName(String id) {
    try {
      return subjects.firstWhere((s) => s.id == id).name;
    } catch (e) {
      return 'Unknown';
    }
  }
}
