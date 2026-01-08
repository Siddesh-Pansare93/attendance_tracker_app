import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/core/repositories/timetable_repository.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Controller for timetable management
///
/// REFACTORED: Now uses injected repositories instead of StorageService singleton
class TimetableController extends GetxController {
  // Dependencies - using Get.find() to get injected repositories
  SubjectRepository get _subjectRepo => Get.find<SubjectRepository>();
  TimetableRepository get _timetableRepo => Get.find<TimetableRepository>();

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
      allEntries.value = _timetableRepo.getAll();
      subjects.value = _subjectRepo.getAll();
      _filterEntriesForDay();
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter entries for selected day
  void _filterEntriesForDay() {
    entriesForDay.value = allEntries
        .where((e) => e.dayOfWeek == selectedDay.value)
        .toList();
  }

  /// Get subject by ID
  Subject? getSubject(String id) {
    try {
      return subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return _subjectRepo.getById(id);
    }
  }

  /// Get subject name by ID
  String getSubjectName(String subjectId) {
    final subject = getSubject(subjectId);
    return subject?.name ?? 'Unknown';
  }

  /// Get entries for a specific day
  List<TimetableEntry> getEntriesForDay(int day) {
    return allEntries.where((e) => e.dayOfWeek == day).toList();
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
    String startTime = '09:00',
    String endTime = '10:00',
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
    await _timetableRepo.save(entry);
    await loadTimetable();
  }

  /// Update an existing entry
  Future<void> updateEntry(TimetableEntry entry) async {
    await _timetableRepo.save(entry);
    await loadTimetable();
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    await _timetableRepo.delete(id);
    await loadTimetable();
  }

  /// Get entry by ID
  TimetableEntry? getEntry(String id) {
    try {
      return allEntries.firstWhere((e) => e.id == id);
    } catch (e) {
      return _timetableRepo.getById(id);
    }
  }

  /// Get day name
  String getDayName(int day) => kDayNames[day];

  /// Get short day name
  String getShortDayName(int day) => kShortDayNames[day];
}
