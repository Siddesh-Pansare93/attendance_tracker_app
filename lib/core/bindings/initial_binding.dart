import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/core/repositories/timetable_repository.dart';
import 'package:smart_attendance_app/core/repositories/attendance_repository.dart';
import 'package:smart_attendance_app/core/repositories/settings_repository.dart';
import 'package:smart_attendance_app/core/repositories/impl/hive_subject_repository.dart';
import 'package:smart_attendance_app/core/repositories/impl/hive_timetable_repository.dart';
import 'package:smart_attendance_app/core/repositories/impl/hive_attendance_repository.dart';
import 'package:smart_attendance_app/core/repositories/impl/prefs_settings_repository.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';
import 'package:smart_attendance_app/features/calendar/controller/calendar_controller.dart';
import 'package:smart_attendance_app/features/settings/controller/settings_controller.dart';

/// Initial Binding - Registers all core dependencies at app startup
/// This follows Dependency Inversion Principle (DIP) -
/// high-level modules don't depend on low-level modules,
/// both depend on abstractions (interfaces)
class InitialBinding extends Bindings {
  final SharedPreferences prefs;
  final Box<Subject> subjectsBox;
  final Box<TimetableEntry> timetableBox;
  final Box<AttendanceRecord> attendanceBox;

  InitialBinding({
    required this.prefs,
    required this.subjectsBox,
    required this.timetableBox,
    required this.attendanceBox,
  });

  @override
  void dependencies() {
    // Register Repositories (abstractions) - can be easily swapped for testing
    Get.put<SubjectRepository>(
      HiveSubjectRepository(subjectsBox),
      permanent: true,
    );
    Get.put<TimetableRepository>(
      HiveTimetableRepository(timetableBox),
      permanent: true,
    );
    Get.put<AttendanceRepository>(
      HiveAttendanceRepository(attendanceBox),
      permanent: true,
    );
    Get.put<SettingsRepository>(
      PrefsSettingsRepository(prefs),
      permanent: true,
    );

    // Register Controllers - they depend on repositories (abstractions)
    Get.put(DashboardController(), permanent: true);
    Get.put(AttendanceController(), permanent: true);
    Get.put(TimetableController(), permanent: true);
    Get.put(CalendarController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}
