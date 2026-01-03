import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';

/// Controller for attendance marking and subject management
class AttendanceController extends GetxController {
  final StorageService _storage = StorageService.instance;
  final _uuid = const Uuid();

  // Observable state
  final subjects = <Subject>[].obs;
  final todayClasses = <TimetableEntry>[].obs;
  final todayRecords = <String, AttendanceRecord>{}.obs; // subjectId -> record
  final selectedSubject = Rxn<Subject>();
  final subjectHistory = <AttendanceRecord>[].obs;
  final isLoading = true.obs;
  final threshold = 75.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTodayClasses();
  }

  /// Load today's scheduled classes
  Future<void> loadTodayClasses() async {
    isLoading.value = true;
    try {
      // Load threshold
      threshold.value = _storage.getAttendanceThreshold();

      // Load subjects
      subjects.value = _storage.getAllSubjects();

      // Load today's timetable entries
      final today = AttendanceUtils.getCurrentDayOfWeek();
      todayClasses.value = _storage.getTimetableForDay(today);

      // Load today's attendance records
      final todayStr = AttendanceUtils.getTodayString();
      final records = _storage.getAttendanceForDate(todayStr);
      todayRecords.clear();
      for (final record in records) {
        todayRecords[record.subjectId] = record;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Get subject by ID
  Subject? getSubject(String id) {
    try {
      return subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return _storage.getSubject(id);
    }
  }

  /// Check if attendance is already marked for subject today
  bool isMarkedToday(String subjectId) {
    return todayRecords.containsKey(subjectId);
  }

  /// Get attendance status for subject today
  String? getTodayStatus(String subjectId) {
    return todayRecords[subjectId]?.status;
  }

  /// Mark attendance for a subject today
  Future<void> markAttendance(String subjectId, bool isPresent) async {
    final todayStr = AttendanceUtils.getTodayString();
    final subject = getSubject(subjectId);
    if (subject == null) return;

    // Check if already marked
    final existingRecord = todayRecords[subjectId];

    if (existingRecord != null) {
      // Update existing record
      final oldStatus = existingRecord.status;
      existingRecord.status = isPresent ? 'present' : 'absent';
      await _storage.saveAttendanceRecord(existingRecord);

      // Update subject counts
      if (oldStatus != existingRecord.status) {
        if (isPresent) {
          // Changed from absent to present
          subject.attendedClasses += 1;
        } else {
          // Changed from present to absent
          subject.attendedClasses -= 1;
        }
        await _storage.saveSubject(subject);
      }
    } else {
      // Create new record
      final record = AttendanceRecord(
        id: _uuid.v4(),
        subjectId: subjectId,
        date: todayStr,
        status: isPresent ? 'present' : 'absent',
      );
      await _storage.saveAttendanceRecord(record);
      todayRecords[subjectId] = record;

      // Update subject counts
      subject.totalClasses += 1;
      if (isPresent) {
        subject.attendedClasses += 1;
      }
      await _storage.saveSubject(subject);
    }

    // Refresh subjects list
    subjects.value = _storage.getAllSubjects();

    // Also refresh dashboard if it's registered
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }

  /// Load subject detail with history
  Future<void> loadSubjectDetail(String subjectId) async {
    isLoading.value = true;
    try {
      threshold.value = _storage.getAttendanceThreshold();
      selectedSubject.value = _storage.getSubject(subjectId);
      subjectHistory.value = _storage.getAttendanceForSubject(subjectId);
    } finally {
      isLoading.value = false;
    }
  }

  // ============== Subject CRUD ==============

  /// Add a new subject
  Future<void> addSubject(String name, {double? minPercentage}) async {
    final subject = Subject(
      id: _uuid.v4(),
      name: name.trim(),
      minimumRequiredPercentage: minPercentage ?? threshold.value,
    );
    await _storage.saveSubject(subject);
    subjects.value = _storage.getAllSubjects();
  }

  /// Update an existing subject
  Future<void> updateSubject(Subject subject) async {
    await _storage.saveSubject(subject);
    subjects.value = _storage.getAllSubjects();
    if (selectedSubject.value?.id == subject.id) {
      selectedSubject.value = subject;
    }
    // Refresh dashboard
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }

  /// Delete a subject and all related data
  Future<void> deleteSubject(String id) async {
    await _storage.deleteSubject(id);
    subjects.value = _storage.getAllSubjects();
    if (selectedSubject.value?.id == id) {
      selectedSubject.value = null;
    }
    // Refresh dashboard
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }

  /// Delete an attendance record
  Future<void> deleteAttendanceRecord(AttendanceRecord record) async {
    // Update subject counts
    final subject = getSubject(record.subjectId);
    if (subject != null) {
      subject.totalClasses -= 1;
      if (record.isPresent) {
        subject.attendedClasses -= 1;
      }
      await _storage.saveSubject(subject);
    }

    // Delete record
    await _storage.deleteAttendanceRecord(record.id);

    // Refresh data
    subjectHistory.value = _storage.getAttendanceForSubject(record.subjectId);
    subjects.value = _storage.getAllSubjects();

    // Remove from today's records if applicable
    final todayStr = AttendanceUtils.getTodayString();
    if (record.date == todayStr) {
      todayRecords.remove(record.subjectId);
    }

    // Refresh dashboard
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }
}
