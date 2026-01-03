import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';

/// Controller for app settings
class SettingsController extends GetxController {
  final StorageService _storage = StorageService.instance;

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
    threshold.value = _storage.getAttendanceThreshold();
    notificationsEnabled.value = _storage.getNotificationsEnabled();
    isDarkMode.value = _storage.isDarkMode();
  }

  /// Update attendance threshold
  Future<void> updateThreshold(double value) async {
    threshold.value = value;
    await _storage.setAttendanceThreshold(value);
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _storage.setNotificationsEnabled(enabled);
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode(bool enabled) async {
    isDarkMode.value = enabled;
    await _storage.setDarkMode(enabled);
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  /// Reset all data
  Future<void> resetAllData() async {
    isLoading.value = true;
    try {
      await _storage.resetAllData();
      // Navigate to welcome screen
      Get.offAllNamed('/welcome');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get total statistics
  Map<String, dynamic> getStatistics() {
    final subjects = _storage.getAllSubjects();
    final records = _storage.getAllAttendanceRecords();
    final timetable = _storage.getAllTimetableEntries();

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
