import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/core/repositories/timetable_repository.dart';
import 'package:smart_attendance_app/core/repositories/attendance_repository.dart';
import 'package:smart_attendance_app/core/repositories/settings_repository.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';

/// Controller for app settings
///
/// REFACTORED: Uses injected repositories
class SettingsController extends GetxController {
  // Dependencies - using Get.find() to get injected repositories
  SubjectRepository get _subjectRepo => Get.find<SubjectRepository>();
  TimetableRepository get _timetableRepo => Get.find<TimetableRepository>();
  AttendanceRepository get _attendanceRepo => Get.find<AttendanceRepository>();
  SettingsRepository get _settingsRepo => Get.find<SettingsRepository>();

  // Observable state
  final threshold = kDefaultAttendanceThreshold.obs;
  final notificationsEnabled = true.obs;
  final isDarkMode = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load all settings
  void loadSettings() {
    threshold.value = _settingsRepo.getAttendanceThreshold();
    notificationsEnabled.value = _settingsRepo.getNotificationsEnabled();
    isDarkMode.value = _settingsRepo.isDarkMode();
  }

  /// Update attendance threshold
  Future<void> updateThreshold(double value) async {
    threshold.value = value;
    await _settingsRepo.setAttendanceThreshold(value);
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _settingsRepo.setNotificationsEnabled(enabled);
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode(bool enabled) async {
    isDarkMode.value = enabled;
    await _settingsRepo.setDarkMode(enabled);
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  /// Reset all data
  Future<void> resetAllData() async {
    isLoading.value = true;
    try {
      await _settingsRepo.resetAll();
      // Navigate to welcome screen
      Get.offAllNamed('/welcome');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get total statistics
  Map<String, dynamic> getStatistics() {
    final subjects = _subjectRepo.getAll();
    final records = _attendanceRepo.getAll();
    final timetable = _timetableRepo.getAll();

    int totalClasses = 0;
    int totalAttended = 0;
    for (final subject in subjects) {
      totalClasses += subject.totalClasses;
      totalAttended += subject.attendedClasses;
    }

    return {
      'subjectsCount': subjects.length,
      'totalClasses': totalClasses,
      'totalAttended': totalAttended,
      'recordsCount': records.length,
      'timetableEntries': timetable.length,
    };
  }
}
