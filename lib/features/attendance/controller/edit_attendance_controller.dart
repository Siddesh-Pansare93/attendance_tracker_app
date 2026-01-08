import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/core/repositories/timetable_repository.dart';
import 'package:smart_attendance_app/core/repositories/attendance_repository.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';

/// Controller for EditAttendancePage - handles form state and logic
///
/// This follows Single Responsibility Principle (SRP):
/// - Only handles attendance editing for a specific date
/// - Properly separates UI state from business logic
class EditAttendanceController extends GetxController {
  // Dependencies - using Get.find() to get injected repositories
  SubjectRepository get _subjectRepo => Get.find<SubjectRepository>();
  TimetableRepository get _timetableRepo => Get.find<TimetableRepository>();
  AttendanceRepository get _attendanceRepo => Get.find<AttendanceRepository>();

  final _uuid = const Uuid();

  // Observable state
  final date = DateTime.now().obs;
  final entries = <TimetableEntry>[].obs;
  final records = <AttendanceRecord>[].obs;
  final subjects = <Subject>[].obs;
  final isLoading = true.obs;


  /// Initialize with a specific date
  void initWithDate(DateTime selectedDate) {
    date.value = selectedDate;
    loadData();
  }

  /// Load data for the selected date
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final dayOfWeek = date.value.weekday % 7; // Convert to 0-6 (Sun-Sat)
      entries.value = _timetableRepo
          .getAll()
          .where((e) => e.dayOfWeek == dayOfWeek)
          .toList();

      subjects.value = _subjectRepo.getAll();

      final dateStr = AttendanceUtils.formatDateForStorage(date.value);
      records.value = _attendanceRepo.getByDate(dateStr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get record status for an entry
  String? getRecordStatus(String entryId) {
    try {
      final record = records.firstWhere((r) => r.timetableEntryId == entryId);
      return record.status;
    } catch (_) {
      return null;
    }
  }

  /// Get subject by ID
  Subject? getSubject(String id) {
    try {
      return subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mark attendance for an entry
  Future<void> markAttendance(TimetableEntry entry, String status) async {
    final dateStr = AttendanceUtils.formatDateForStorage(date.value);
    final subject = getSubject(entry.subjectId);
    if (subject == null) return;

    // Find existing record
    AttendanceRecord? existingRecord;
    try {
      existingRecord = records.firstWhere(
        (r) => r.timetableEntryId == entry.id,
      );
    } catch (_) {}

    if (existingRecord != null) {
      // Update existing record
      final oldStatus = existingRecord.status;
      existingRecord.status = status;
      await _attendanceRepo.save(existingRecord);

      // Update subject counts
      if (oldStatus != status) {
        if (oldStatus == 'present') subject.attendedClasses -= 1;
        if (oldStatus != 'cancelled') subject.totalClasses -= 1;
        if (status == 'present') subject.attendedClasses += 1;
        if (status != 'cancelled') subject.totalClasses += 1;
        await _subjectRepo.save(subject);
      }
    } else {
      // Create new record
      final record = AttendanceRecord(
        id: _uuid.v4(),
        subjectId: entry.subjectId,
        date: dateStr,
        status: status,
        timetableEntryId: entry.id,
      );
      await _attendanceRepo.save(record);

      if (status != 'cancelled') {
        subject.totalClasses += 1;
        if (status == 'present') subject.attendedClasses += 1;
        await _subjectRepo.save(subject);
      }
    }

    // Reload data
    await loadData();

    // Notify other controllers
    _notifyOtherControllers();
  }

  /// Notify other controllers to refresh
  void _notifyOtherControllers() {
    if (Get.isRegistered<AttendanceController>()) {
      Get.find<AttendanceController>().loadTodayClasses();
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }
}
