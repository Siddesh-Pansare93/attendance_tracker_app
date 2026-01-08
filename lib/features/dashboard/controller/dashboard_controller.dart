import 'package:get/get.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/core/repositories/timetable_repository.dart';
import 'package:smart_attendance_app/core/repositories/attendance_repository.dart';
import 'package:smart_attendance_app/core/repositories/settings_repository.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Controller for the Dashboard/Home screen
///
/// REFACTORED: Now uses injected repositories instead of direct StorageService
/// This follows Dependency Inversion Principle (DIP)
class DashboardController extends GetxController {
  // Dependencies injected via Get.find() - relies on abstractions
  SubjectRepository get _subjectRepo => Get.find<SubjectRepository>();
  TimetableRepository get _timetableRepo => Get.find<TimetableRepository>();
  SettingsRepository get _settingsRepo => Get.find<SettingsRepository>();

  // Observable state
  final subjects = <Subject>[].obs;
  final todayClasses = <TimetableEntry>[].obs;
  final isLoading = true.obs;
  final overallPercentage = 0.0.obs;
  final threshold = 75.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load all dashboard data
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Load subjects from repository
      subjects.value = _subjectRepo.getAll();

      // Load today's classes from repository
      final today = AttendanceUtils.getCurrentDayOfWeek();
      todayClasses.value = _timetableRepo.getByDay(today);

      // Load threshold setting from repository
      threshold.value = _settingsRepo.getAttendanceThreshold();

      // Calculate overall attendance
      _calculateOverallAttendance();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refreshData() async {
    await loadData();
  }

  /// Calculate overall attendance across all subjects
  void _calculateOverallAttendance() {
    if (subjects.isEmpty) {
      overallPercentage.value = 0.0;
      return;
    }

    int totalClasses = 0;
    int totalAttended = 0;

    for (final subject in subjects) {
      totalClasses += subject.totalClasses;
      totalAttended += subject.attendedClasses;
    }

    overallPercentage.value = AttendanceUtils.calculatePercentage(
      totalAttended,
      totalClasses,
    );
  }

  /// Get subject name by ID
  String getSubjectName(String subjectId) {
    final subject = _subjectRepo.getById(subjectId);
    return subject?.name ?? 'Unknown Subject';
  }

  /// Check if attendance is marked for a timetable entry today
  bool isAttendanceMarkedToday(String subjectId) {
    final today = AttendanceUtils.getTodayString();
    final attendanceRepo = Get.find<AttendanceRepository>();
    return attendanceRepo.isMarked(subjectId, today);
  }

  /// Get count of subjects above/below threshold
  int get subjectsAboveThreshold =>
      subjects.where((s) => s.attendancePercentage >= threshold.value).length;

  int get subjectsBelowThreshold =>
      subjects.where((s) => s.attendancePercentage < threshold.value).length;

  /// Get subjects sorted by attendance (lowest first for priority)
  List<Subject> get subjectsByPriority {
    final sorted = List<Subject>.from(subjects);
    sorted.sort(
      (a, b) => a.attendancePercentage.compareTo(b.attendancePercentage),
    );
    return sorted;
  }
}
