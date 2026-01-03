import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Controller for timetable management
class TimetableController extends GetxController {
  final StorageService _storage = StorageService.instance;
  final _uuid = const Uuid();

  // Observable state
  final allEntries = <TimetableEntry>[].obs;
  final subjects = <Subject>[].obs;
  final selectedDay = 1.obs; // Monday by default
  final entriesForDay = <TimetableEntry>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTimetable();
    // Watch for day changes
    ever(selectedDay, (_) => _filterEntriesForDay());
  }

  /// Load all timetable data
  Future<void> loadTimetable() async {
    isLoading.value = true;
    try {
      allEntries.value = _storage.getAllTimetableEntries();
      subjects.value = _storage.getAllSubjects();
      _filterEntriesForDay();
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter entries for selected day
  void _filterEntriesForDay() {
    entriesForDay.value =
        allEntries.where((e) => e.dayOfWeek == selectedDay.value).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get subject by ID
  Subject? getSubject(String id) {
    try {
      return subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return _storage.getSubject(id);
    }
  }

  /// Get subject name by ID
  String getSubjectName(String subjectId) {
    final subject = getSubject(subjectId);
    return subject?.name ?? 'Unknown';
  }

  /// Get entries for a specific day
  List<TimetableEntry> getEntriesForDay(int day) {
    return allEntries.where((e) => e.dayOfWeek == day).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Check if a day has any classes
  bool hasClassesOnDay(int day) {
    return allEntries.any((e) => e.dayOfWeek == day);
  }

  /// Get count of classes for a day
  int getClassCountForDay(int day) {
    return allEntries.where((e) => e.dayOfWeek == day).length;
  }

  // ============== CRUD Operations ==============

  /// Add a new timetable entry
  Future<void> addEntry({
    required String subjectId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String type = 'Lecture',
  }) async {
    final entry = TimetableEntry(
      id: _uuid.v4(),
      subjectId: subjectId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      type: type,
    );
    await _storage.saveTimetableEntry(entry);
    await loadTimetable();
  }

  /// Update an existing entry
  Future<void> updateEntry(TimetableEntry entry) async {
    await _storage.saveTimetableEntry(entry);
    await loadTimetable();
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    await _storage.deleteTimetableEntry(id);
    await loadTimetable();
  }

  /// Get entry by ID
  TimetableEntry? getEntry(String id) {
    try {
      return allEntries.firstWhere((e) => e.id == id);
    } catch (e) {
      return _storage.getTimetableEntry(id);
    }
  }

  /// Get day name
  String getDayName(int day) => kDayNames[day];

  /// Get short day name
  String getShortDayName(int day) => kShortDayNames[day];
}
