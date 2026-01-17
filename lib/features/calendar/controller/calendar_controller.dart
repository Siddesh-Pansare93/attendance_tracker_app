import 'package:get/get.dart';
import 'package:smart_attendance_app/core/repositories/attendance_repository.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';

/// Controller for the calendar view
///
/// REFACTORED: Uses injected repositories
class CalendarController extends GetxController {
  // Dependency - using Get.find() to get injected repository
  AttendanceRepository get _attendanceRepo => Get.find<AttendanceRepository>();

  // Observable state
  final selectedDate = DateTime.now().obs;
  final focusedDate = DateTime.now().obs;
  final allRecords = <AttendanceRecord>[].obs;
  final recordsForDate = <AttendanceRecord>[].obs;
  final isLoading = false.obs;

  // Map of date strings to list of records (for calendar markers)
  final recordsByDate = <String, List<AttendanceRecord>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
    // Watch for date selection changes
    ever(selectedDate, (_) => _loadRecordsForDate());
  }

  /// Load all attendance records
  Future<void> loadRecords() async {
    isLoading.value = true;
    try {
      allRecords.value = _attendanceRepo.getAll();
      _buildRecordsByDate();
      _loadRecordsForDate();
    } finally {
      isLoading.value = false;
    }
  }

  /// Build map of records grouped by date
  void _buildRecordsByDate() {
    recordsByDate.clear();
    final grouped = <String, Map<String, AttendanceRecord>>{};

    for (final record in allRecords) {
      final dateKey = record.date;
      grouped.putIfAbsent(dateKey, () => {});
      final dateMap = grouped[dateKey]!;

      if (record.timetableEntryId == null) {
        dateMap.putIfAbsent(record.subjectId, () => record);
      } else {
        dateMap.remove(record.subjectId);
        dateMap[record.timetableEntryId!] = record;
      }
    }

    for (final entry in grouped.entries) {
      recordsByDate[entry.key] = entry.value.values.toList();
    }
  }

  /// Load records for the selected date
  void _loadRecordsForDate() {
    final dateStr = _formatDate(selectedDate.value);
    recordsForDate.value = recordsByDate[dateStr] ?? [];
  }

  /// Check if a date has records
  bool hasRecordsOnDate(DateTime date) {
    final dateStr = _formatDate(date);
    return recordsByDate.containsKey(dateStr);
  }

  /// Get records for a specific date
  List<AttendanceRecord> getRecordsForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return recordsByDate[dateStr] ?? [];
  }

  /// Count present/absent for a date
  int getPresentCount(DateTime date) {
    return getRecordsForDate(date).where((r) => r.isPresent).length;
  }

  int getAbsentCount(DateTime date) {
    return getRecordsForDate(date).where((r) => r.isAbsent).length;
  }

  /// Format date to storage format
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Select a date
  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  /// Change focused month
  void onPageChanged(DateTime focusedDay) {
    focusedDate.value = focusedDay;
  }
}
