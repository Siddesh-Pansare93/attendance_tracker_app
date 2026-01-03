import 'package:get/get.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Controller for the Dashboard/Home screen
class DashboardController extends GetxController {
  final StorageService _storage = StorageService.instance;

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
      // Load subjects
      subjects.value = _storage.getAllSubjects();

      // Load today's classes
      final today = AttendanceUtils.getCurrentDayOfWeek();
      todayClasses.value = _storage.getTimetableForDay(today);

      // Load threshold setting
      threshold.value = _storage.getAttendanceThreshold();

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
    final subject = _storage.getSubject(subjectId);
    return subject?.name ?? 'Unknown Subject';
  }

  /// Check if attendance is marked for a timetable entry today
  bool isAttendanceMarkedToday(String subjectId) {
    final today = AttendanceUtils.getTodayString();
    return _storage.isAttendanceMarked(subjectId, today);
  }

  /// Get count of subjects above/below threshold
  int get subjectsAboveThreshold =>
      subjects.where((s) => s.attendancePercentage >= threshold.value).length;

  int get subjectsBelowThreshold =>
      subjects.where((s) => s.attendancePercentage < threshold.value).length;

  /// Get subjects sorted by attendance (lowest first for priority)
  List<Subject> get subjectsByPriority {
    final sorted = List<Subject>.from(subjects);
    sorted.sort((a, b) => a.attendancePercentage.compareTo(b.attendancePercentage));
    return sorted;
  }
}
