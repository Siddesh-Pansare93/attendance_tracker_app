import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/core/repositories/timetable_repository.dart';
import 'package:smart_attendance_app/core/repositories/attendance_repository.dart';
import 'package:smart_attendance_app/core/repositories/settings_repository.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';

/// Controller for attendance marking and subject management
///
/// REFACTORED: Now uses injected repositories instead of StorageService singleton
/// This follows Dependency Inversion Principle (DIP) and Single Responsibility Principle (SRP)
class AttendanceController extends GetxController {
  // Dependencies - using Get.find() to get injected repositories
  SubjectRepository get _subjectRepo => Get.find<SubjectRepository>();
  TimetableRepository get _timetableRepo => Get.find<TimetableRepository>();
  AttendanceRepository get _attendanceRepo => Get.find<AttendanceRepository>();
  SettingsRepository get _settingsRepo => Get.find<SettingsRepository>();

  final _uuid = const Uuid();

  // Observable state
  final subjects = <Subject>[].obs;
  final todayClasses = <TimetableEntry>[].obs;
  final todayRecords = <String, AttendanceRecord>{}.obs; // entryId -> record
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
      // Load threshold from settings repository
      threshold.value = _settingsRepo.getAttendanceThreshold();

      // Load subjects from repository
      subjects.value = _subjectRepo.getAll();

      // Load today's timetable entries from repository
      final today = AttendanceUtils.getCurrentDayOfWeek();
      todayClasses.value = _timetableRepo.getByDay(today);

      // Load today's attendance records
      final todayStr = AttendanceUtils.getTodayString();
      final records = _attendanceRepo.getByDate(todayStr);
      todayRecords.clear();
      for (final record in records) {
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
      return _subjectRepo.getById(id);
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
  /// Status can be: 'present', 'absent', or 'cancelled'
  Future<void> markAttendance(
    String subjectId,
    String status, {
    String? timetableEntryId,
  }) async {
    final todayStr = AttendanceUtils.getTodayString();
    final subject = getSubject(subjectId);
    if (subject == null) return;

    final recordKey = timetableEntryId ?? subjectId;
    final existingRecord = todayRecords[recordKey];

    if (existingRecord != null) {
      // Update existing record
      final oldStatus = existingRecord.status;
      existingRecord.status = status;
      await _attendanceRepo.save(existingRecord);

      // Update subject counts based on status changes
      if (oldStatus != status) {
        if (oldStatus == 'present') {
          subject.attendedClasses -= 1;
        }
        if (oldStatus != 'cancelled') {
          subject.totalClasses -= 1;
        }
        if (status == 'present') {
          subject.attendedClasses += 1;
        }
        if (status != 'cancelled') {
          subject.totalClasses += 1;
        }
        await _subjectRepo.save(subject);
      }
    } else {
      // Create new record
      final record = AttendanceRecord(
        id: _uuid.v4(),
        subjectId: subjectId,
        date: todayStr,
        status: status,
        timetableEntryId: timetableEntryId,
      );
      await _attendanceRepo.save(record);
      todayRecords[recordKey] = record;

      // Update subject counts (cancelled doesn't count towards total)
      if (status != 'cancelled') {
        subject.totalClasses += 1;
        if (status == 'present') {
          subject.attendedClasses += 1;
        }
        await _subjectRepo.save(subject);
      }
    }

    // Refresh subjects list
    subjects.value = _subjectRepo.getAll();

    // Notify dashboard to refresh
    _notifyDashboard();
  }

  /// Load subject detail with history
  Future<void> loadSubjectDetail(String subjectId) async {
    isLoading.value = true;
    try {
      threshold.value = _settingsRepo.getAttendanceThreshold();
      selectedSubject.value = _subjectRepo.getById(subjectId);
      subjectHistory.value = _attendanceRepo.getBySubjectId(subjectId);
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
    await _subjectRepo.save(subject);
    subjects.value = _subjectRepo.getAll();
    _notifyDashboard();
  }

  /// Update an existing subject
  Future<void> updateSubject(Subject subject) async {
    await _subjectRepo.save(subject);
    subjects.value = _subjectRepo.getAll();
    if (selectedSubject.value?.id == subject.id) {
      selectedSubject.value = subject;
    }
    _notifyDashboard();
  }

  /// Delete a subject and all related data
  Future<void> deleteSubject(String id) async {
    // Delete related timetable entries
    await _timetableRepo.deleteBySubjectId(id);
    // Delete related attendance records
    await _attendanceRepo.deleteBySubjectId(id);
    // Delete the subject
    await _subjectRepo.delete(id);

    subjects.value = _subjectRepo.getAll();
    if (selectedSubject.value?.id == id) {
      selectedSubject.value = null;
    }
    _notifyDashboard();
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
      await _subjectRepo.save(subject);
    }

    // Delete record
    await _attendanceRepo.delete(record.id);

    // Refresh data
    subjectHistory.value = _attendanceRepo.getBySubjectId(record.subjectId);
    subjects.value = _subjectRepo.getAll();

    // Remove from today's records if applicable
    final todayStr = AttendanceUtils.getTodayString();
    if (record.date == todayStr) {
      final key = record.timetableEntryId ?? record.subjectId;
      todayRecords.remove(key);
    }

    _notifyDashboard();
  }

  /// Notify dashboard to refresh - using reactive approach
  void _notifyDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }
}
