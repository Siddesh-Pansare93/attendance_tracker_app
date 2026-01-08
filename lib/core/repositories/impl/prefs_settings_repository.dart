import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/core/repositories/settings_repository.dart';

/// SharedPreferences implementation of SettingsRepository
class PrefsSettingsRepository implements SettingsRepository {
  final SharedPreferences _prefs;

  PrefsSettingsRepository(this._prefs);

  @override
  double getAttendanceThreshold() {
    return _prefs.getDouble(kPrefThreshold) ?? kDefaultAttendanceThreshold;
  }

  @override
  Future<void> setAttendanceThreshold(double threshold) async {
    await _prefs.setDouble(kPrefThreshold, threshold);
  }

  @override
  bool getNotificationsEnabled() {
    return _prefs.getBool(kPrefNotifications) ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(kPrefNotifications, enabled);
  }

  @override
  bool isSetupComplete() {
    return _prefs.getBool(kPrefSetupComplete) ?? false;
  }

  @override
  Future<void> setSetupComplete(bool complete) async {
    await _prefs.setBool(kPrefSetupComplete, complete);
  }

  @override
  bool isDarkMode() {
    return _prefs.getBool(kPrefDarkMode) ?? false;
  }

  @override
  Future<void> setDarkMode(bool darkMode) async {
    await _prefs.setBool(kPrefDarkMode, darkMode);
  }

  @override
  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
