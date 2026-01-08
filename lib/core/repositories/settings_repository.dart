/// Repository interface for App Settings
/// Following Interface Segregation Principle - focused on Settings only
abstract class SettingsRepository {
  double getAttendanceThreshold();
  Future<void> setAttendanceThreshold(double threshold);

  bool getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);

  bool isSetupComplete();
  Future<void> setSetupComplete(bool complete);

  bool isDarkMode();
  Future<void> setDarkMode(bool darkMode);

  Future<void> resetAll();
}
