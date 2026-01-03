import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Service for managing local storage using Hive and SharedPreferences
class StorageService {
  static StorageService? _instance;
  static late SharedPreferences _prefs;
  static late Box<Subject> _subjectsBox;
  static late Box<TimetableEntry> _timetableBox;
  static late Box<AttendanceRecord> _attendanceBox;

  StorageService._();

  /// Get singleton instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize all storage boxes and SharedPreferences
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register Hive adapters
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(TimetableEntryAdapter());
    Hive.registerAdapter(AttendanceRecordAdapter());

    // Open boxes
    _subjectsBox = await Hive.openBox<Subject>(kSubjectsBox);
    _timetableBox = await Hive.openBox<TimetableEntry>(kTimetableBox);
    _attendanceBox = await Hive.openBox<AttendanceRecord>(kAttendanceBox);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // ============== Subjects ==============

  /// Get all subjects
  List<Subject> getAllSubjects() {
    return _subjectsBox.values.toList();
  }

  /// Get subject by ID
  Subject? getSubject(String id) {
    return _subjectsBox.get(id);
  }

  /// Save or update a subject
  Future<void> saveSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, subject);
  }

  /// Delete a subject and its related data
  Future<void> deleteSubject(String id) async {
    await _subjectsBox.delete(id);
    // Also delete related timetable entries and attendance records
    final timetableEntries = _timetableBox.values
        .where((entry) => entry.subjectId == id)
        .toList();
    for (var entry in timetableEntries) {
      await _timetableBox.delete(entry.id);
    }
    final attendanceRecords = _attendanceBox.values
        .where((record) => record.subjectId == id)
        .toList();
    for (var record in attendanceRecords) {
      await _attendanceBox.delete(record.id);
    }
  }

  // ============== Timetable ==============

  /// Get all timetable entries
  List<TimetableEntry> getAllTimetableEntries() {
    return _timetableBox.values.toList();
  }

  /// Get timetable entries for a specific day
  List<TimetableEntry> getTimetableForDay(int dayOfWeek) {
    return _timetableBox.values
        .where((entry) => entry.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get timetable entry by ID
  TimetableEntry? getTimetableEntry(String id) {
    return _timetableBox.get(id);
  }

  /// Save or update a timetable entry
  Future<void> saveTimetableEntry(TimetableEntry entry) async {
    await _timetableBox.put(entry.id, entry);
  }

  /// Delete a timetable entry
  Future<void> deleteTimetableEntry(String id) async {
    await _timetableBox.delete(id);
  }

  // ============== Attendance Records ==============

  /// Get all attendance records
  List<AttendanceRecord> getAllAttendanceRecords() {
    return _attendanceBox.values.toList();
  }

  /// Get attendance records for a specific subject
  List<AttendanceRecord> getAttendanceForSubject(String subjectId) {
    return _attendanceBox.values
        .where((record) => record.subjectId == subjectId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Get attendance records for a specific date
  List<AttendanceRecord> getAttendanceForDate(String date) {
    return _attendanceBox.values
        .where((record) => record.date == date)
        .toList();
  }

  /// Check if attendance is already marked for a subject on a date
  bool isAttendanceMarked(String subjectId, String date) {
    return _attendanceBox.values.any(
      (record) => record.subjectId == subjectId && record.date == date,
    );
  }

  /// Get attendance record for a subject on a specific date
  AttendanceRecord? getAttendanceRecord(String subjectId, String date) {
    try {
      return _attendanceBox.values.firstWhere(
        (record) => record.subjectId == subjectId && record.date == date,
      );
    } catch (e) {
      return null;
    }
  }

  /// Save or update an attendance record
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    await _attendanceBox.put(record.id, record);
  }

  /// Delete an attendance record
  Future<void> deleteAttendanceRecord(String id) async {
    await _attendanceBox.delete(id);
  }

  // ============== App Settings (SharedPreferences) ==============

  /// Get attendance threshold
  double getAttendanceThreshold() {
    return _prefs.getDouble(kPrefThreshold) ?? kDefaultAttendanceThreshold;
  }

  /// Set attendance threshold
  Future<void> setAttendanceThreshold(double threshold) async {
    await _prefs.setDouble(kPrefThreshold, threshold);
  }

  /// Get notifications enabled
  bool getNotificationsEnabled() {
    return _prefs.getBool(kPrefNotifications) ?? true;
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(kPrefNotifications, enabled);
  }

  /// Check if first-time setup is complete
  bool isSetupComplete() {
    return _prefs.getBool(kPrefSetupComplete) ?? false;
  }

  /// Mark setup as complete
  Future<void> setSetupComplete(bool complete) async {
    await _prefs.setBool(kPrefSetupComplete, complete);
  }

  /// Get dark mode preference
  bool isDarkMode() {
    return _prefs.getBool(kPrefDarkMode) ?? false;
  }

  /// Set dark mode preference
  Future<void> setDarkMode(bool darkMode) async {
    await _prefs.setBool(kPrefDarkMode, darkMode);
  }

  // ============== Reset ==============

  /// Reset all data
  Future<void> resetAllData() async {
    await _subjectsBox.clear();
    await _timetableBox.clear();
    await _attendanceBox.clear();
    await _prefs.clear();
  }
}
