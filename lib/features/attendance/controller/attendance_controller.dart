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
  final todayRecords =
      <String, AttendanceRecord>{}.obs; // timetableEntryId -> record
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

      // Load today's attendance records - keyed by timetableEntryId or subjectId for backwards compat
      final todayStr = AttendanceUtils.getTodayString();
      final records = _storage.getAttendanceForDate(todayStr);
      todayRecords.clear();
      for (final record in records) {
        // Use timetableEntryId as key if available, otherwise fall back to subjectId
        final key = record.timetableEntryId ?? record.subjectId;
        todayRecords[key] = record;
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

  /// Check if attendance is already marked for a specific timetable entry today
  bool isMarkedToday(String entryId) {
    return todayRecords.containsKey(entryId);
  }

  /// Get attendance status for a specific timetable entry today
  String? getTodayStatus(String entryId) {
    return todayRecords[entryId]?.status;
  }

  /// Mark attendance for a specific timetable entry today
  /// Now tracks by timetableEntryId to support multiple lectures of same subject
  /// Status can be: 'present', 'absent', or 'cancelled'
  Future<void> markAttendance(
    String subjectId,
    String status, {
    String? timetableEntryId,
  }) async {
    final todayStr = AttendanceUtils.getTodayString();
    final subject = getSubject(subjectId);
    if (subject == null) return;

    // Use timetableEntryId as key if provided, otherwise fall back to subjectId
    final recordKey = timetableEntryId ?? subjectId;

    // Check if already marked
    final existingRecord = todayRecords[recordKey];

    if (existingRecord != null) {
      // Update existing record
      final oldStatus = existingRecord.status;
      existingRecord.status = status;
      await _storage.saveAttendanceRecord(existingRecord);

      // Update subject counts based on status changes
      if (oldStatus != status) {
        // Handle old status
        if (oldStatus == 'present') {
          subject.attendedClasses -= 1;
        }
        if (oldStatus != 'cancelled') {
          subject.totalClasses -= 1;
        }

        // Handle new status
        if (status == 'present') {
          subject.attendedClasses += 1;
        }
        if (status != 'cancelled') {
          subject.totalClasses += 1;
        }

        await _storage.saveSubject(subject);
      }
    } else {
      // Create new record with timetableEntryId
      final record = AttendanceRecord(
        id: _uuid.v4(),
        subjectId: subjectId,
        date: todayStr,
        status: status,
        timetableEntryId: timetableEntryId,
      );
      await _storage.saveAttendanceRecord(record);
      todayRecords[recordKey] = record;

      // Update subject counts (cancelled doesn't count towards total)
      if (status != 'cancelled') {
        subject.totalClasses += 1;
        if (status == 'present') {
          subject.attendedClasses += 1;
        }
        await _storage.saveSubject(subject);
      }
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

    // Refresh dashboard
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
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
      final key = record.timetableEntryId ?? record.subjectId;
      todayRecords.remove(key);
    }

    // Refresh dashboard
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }
}
