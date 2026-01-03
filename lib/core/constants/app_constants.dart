/// App-wide constants for the Smart Attendance Tracker
library;

/// Default attendance threshold percentage
const double kDefaultAttendanceThreshold = 75.0;

/// Attendance status thresholds
const double kSafeThreshold = 85.0; // >= 85% is safe (green)
const double kWarningThreshold = 75.0; // 75-84% is warning (yellow)
// Below 75% is critical (red)

/// Day names for timetable
const List<String> kDayNames = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

/// Short day names
const List<String> kShortDayNames = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];

/// Class types
const List<String> kClassTypes = ['Lecture', 'Lab', 'Tutorial', 'Seminar'];

/// Hive box names
const String kSubjectsBox = 'subjects_box';
const String kTimetableBox = 'timetable_box';
const String kAttendanceBox = 'attendance_box';

/// SharedPreferences keys
const String kPrefThreshold = 'attendance_threshold';
const String kPrefNotifications = 'notifications_enabled';
const String kPrefSetupComplete = 'setup_complete';
const String kPrefDarkMode = 'dark_mode';
