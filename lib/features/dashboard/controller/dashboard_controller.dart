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

/// Controller for the Dashboard/Home screen
///
/// REFACTORED: Now uses injected repositories instead of direct StorageService
/// This follows Dependency Inversion Principle (DIP)
class DashboardController extends GetxController {
  // Dependencies injected via Get.find() - relies on abstractions
  SubjectRepository get _subjectRepo => Get.find<SubjectRepository>();
  TimetableRepository get _timetableRepo => Get.find<TimetableRepository>();
  AttendanceRepository get _attendanceRepo => Get.find<AttendanceRepository>();
  SettingsRepository get _settingsRepo => Get.find<SettingsRepository>();

  final _uuid = const Uuid();

  // Observable state
  final subjects = <Subject>[].obs;
  final todayClasses = <TimetableEntry>[].obs;
  final todayRecords = <String, AttendanceRecord>{}.obs; // entryId -> record
  final extraLectures = <AttendanceRecord>[].obs; // Extra lectures (manual entries)
  final isLoading = true.obs;
  final overallPercentage = 0.0.obs;
  final threshold = 75.0.obs;
  final markingInProgress = Rxn<String>(); // entryId being marked
  
  // Analytics filters
  final analyticsFilter = 'monthly'.obs; // 'weekly', 'monthly', 'from-to'
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

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

      // Load today's attendance records
      final todayStr = AttendanceUtils.getTodayString();
      final records = _attendanceRepo.getByDate(todayStr);
      todayRecords.clear();
      extraLectures.clear();
      for (final record in records) {
        if (record.timetableEntryId == null) {
          // Extra lecture (manual entry)
          extraLectures.add(record);
        } else {
          // Scheduled class
          todayRecords[record.timetableEntryId!] = record;
        }
      }

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

  /// Check if attendance is marked for a specific timetable entry today
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
    final entryId = timetableEntryId ?? subjectId;
    
    try {
      markingInProgress.value = entryId;

      final todayStr = AttendanceUtils.getTodayString();
      final subject = _subjectRepo.getById(subjectId);
      if (subject == null) return;

      final existingRecord = todayRecords[entryId];

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
        todayRecords[entryId] = record;

        // Update subject counts (cancelled doesn't count towards total)
        if (status != 'cancelled') {
          subject.totalClasses += 1;
          if (status == 'present') {
            subject.attendedClasses += 1;
          }
          await _subjectRepo.save(subject);
        }
      }

       // Refresh data
       await loadData();
     } finally {
       markingInProgress.value = null;
     }
   }

  // ============== Extra Lecture Management ==============

  /// Add an extra lecture for a specific date
  Future<void> addExtraLecture(
    String subjectId,
    String date,
    String status, // 'present', 'absent', or 'cancelled'
  ) async {
    try {
      final subject = _subjectRepo.getById(subjectId);
      if (subject == null) return;

      final record = AttendanceRecord(
        id: _uuid.v4(),
        subjectId: subjectId,
        date: date,
        status: status,
        timetableEntryId: null, // null indicates extra lecture
      );
      await _attendanceRepo.save(record);

      // Update subject counts (cancelled doesn't count towards total)
      if (status != 'cancelled') {
        subject.totalClasses += 1;
        if (status == 'present') {
          subject.attendedClasses += 1;
        }
        await _subjectRepo.save(subject);
      }

      // Refresh data
      await loadData();
    } catch (e) {
      // Error handled silently - attendance system should be resilient
    }
  }

  /// Update an extra lecture
  Future<void> updateExtraLecture(
    String recordId,
    String subjectId,
    String date,
    String newStatus,
  ) async {
    try {
      final record = _attendanceRepo.getById(recordId);
      if (record == null) return;

      final oldStatus = record.status;
      final subject = _subjectRepo.getById(subjectId);
      if (subject == null) return;

      record.status = newStatus;
      await _attendanceRepo.save(record);

      // Update subject counts based on status changes
      if (oldStatus != newStatus) {
        if (oldStatus == 'present') {
          subject.attendedClasses -= 1;
        }
        if (oldStatus != 'cancelled') {
          subject.totalClasses -= 1;
        }
        if (newStatus == 'present') {
          subject.attendedClasses += 1;
        }
        if (newStatus != 'cancelled') {
          subject.totalClasses += 1;
        }
        await _subjectRepo.save(subject);
      }

      // Refresh data
      await loadData();
    } catch (e) {
      // Error handled silently
    }
  }

  /// Delete an extra lecture
  Future<void> deleteExtraLecture(String recordId) async {
    try {
      final record = _attendanceRepo.getById(recordId);
      if (record == null) return;

      final subject = _subjectRepo.getById(record.subjectId);
      if (subject != null) {
        if (record.status != 'cancelled') {
          subject.totalClasses -= 1;
          if (record.status == 'present') {
            subject.attendedClasses -= 1;
          }
          await _subjectRepo.save(subject);
        }
      }

      await _attendanceRepo.delete(recordId);
      
      // Refresh data
      await loadData();
    } catch (e) {
      // Error handled silently
    }
  }

  // ============== Analytics Methods ==============

  /// Get analytics data for the selected period
  Map<String, dynamic> getAnalyticsData() {
    final records = _getRecordsForPeriod();
    
    int totalClasses = 0;
    int totalPresent = 0;
    int totalAbsent = 0;
    
    final subjectStats = <String, Map<String, int>>{};

    for (final record in records) {
      if (record.status != 'cancelled') {
        totalClasses++;
        
        final subject = _subjectRepo.getById(record.subjectId);
        final subjectName = subject?.name ?? 'Unknown';
        
        if (!subjectStats.containsKey(subjectName)) {
          subjectStats[subjectName] = {'classes': 0, 'present': 0, 'absent': 0};
        }
        
        subjectStats[subjectName]!['classes'] = subjectStats[subjectName]!['classes']! + 1;
        
        if (record.status == 'present') {
          totalPresent++;
          subjectStats[subjectName]!['present'] = subjectStats[subjectName]!['present']! + 1;
        } else {
          totalAbsent++;
          subjectStats[subjectName]!['absent'] = subjectStats[subjectName]!['absent']! + 1;
        }
      }
    }

    final overallPercentage = totalClasses > 0 ? (totalPresent / totalClasses * 100) : 0.0;

    return {
      'totalClasses': totalClasses,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'overallPercentage': overallPercentage,
      'subjectStats': subjectStats,
    };
  }

  /// Get records for the current analytics period
  List<AttendanceRecord> _getRecordsForPeriod() {
    List<AttendanceRecord> records = [];
    
    if (analyticsFilter.value == 'weekly') {
      // Last 7 days
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = AttendanceUtils.formatDateForStorage(date);
        records.addAll(_attendanceRepo.getByDate(dateStr));
      }
    } else if (analyticsFilter.value == 'monthly') {
      // Current month
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      
      for (int i = 0; i <= lastDay.difference(firstDay).inDays; i++) {
        final date = firstDay.add(Duration(days: i));
        final dateStr = AttendanceUtils.formatDateForStorage(date);
        records.addAll(_attendanceRepo.getByDate(dateStr));
      }
    } else if (analyticsFilter.value == 'from-to' && fromDate.value != null && toDate.value != null) {
      // Custom range
      final start = fromDate.value!;
      final end = toDate.value!;
      
      for (int i = 0; i <= end.difference(start).inDays; i++) {
        final date = start.add(Duration(days: i));
        final dateStr = AttendanceUtils.formatDateForStorage(date);
        records.addAll(_attendanceRepo.getByDate(dateStr));
      }
    }
    
    return records;
  }

  /// Set analytics filter to weekly
  void setAnalyticsFilterWeekly() {
    analyticsFilter.value = 'weekly';
  }

  /// Set analytics filter to monthly
  void setAnalyticsFilterMonthly() {
    analyticsFilter.value = 'monthly';
  }

  /// Set analytics filter to from-to
  void setAnalyticsFilterFromTo(DateTime from, DateTime to) {
    fromDate.value = from;
    toDate.value = to;
    analyticsFilter.value = 'from-to';
  }
}
