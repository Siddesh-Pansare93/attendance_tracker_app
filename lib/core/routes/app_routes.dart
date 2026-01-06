import 'package:get/get.dart';
import 'package:smart_attendance_app/features/setup/pages/splash_page.dart';
import 'package:smart_attendance_app/features/setup/pages/welcome_page.dart';
import 'package:smart_attendance_app/features/dashboard/pages/home_page.dart';
import 'package:smart_attendance_app/features/setup/pages/setup_subjects_page.dart';
import 'package:smart_attendance_app/features/setup/pages/setup_timetable_page.dart';
import 'package:smart_attendance_app/features/attendance/pages/today_attendance_page.dart';
import 'package:smart_attendance_app/features/attendance/pages/subject_detail_page.dart';
import 'package:smart_attendance_app/features/attendance/pages/add_subject_page.dart';
import 'package:smart_attendance_app/features/attendance/pages/edit_attendance_page.dart';
import 'package:smart_attendance_app/features/timetable/pages/timetable_page.dart';
import 'package:smart_attendance_app/features/timetable/pages/add_timetable_entry_page.dart';
import 'package:smart_attendance_app/features/calendar/pages/calendar_page.dart';
import 'package:smart_attendance_app/features/settings/pages/settings_page.dart';

/// App route names
class AppRoutes {
  AppRoutes._();

  // Setup routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String setupSubjects = '/setup/subjects';
  static const String setupTimetable = '/setup/timetable';

  // Main routes
  static const String home = '/home';
  static const String today = '/today';
  static const String timetable = '/timetable';
  static const String calendar = '/calendar';
  static const String settings = '/settings';

  // Detail routes
  static const String subjectDetail = '/subject/:id';
  static const String addSubject = '/subject/add';
  static const String editSubject = '/subject/edit/:id';
  static const String addTimetableEntry = '/timetable/add';
  static const String editTimetableEntry = '/timetable/edit/:id';
  static const String editAttendance = '/attendance/edit';

  /// All app pages/routes
  static final List<GetPage> pages = [
    // Splash screen - initial route
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    // Setup flow
    GetPage(
      name: welcome,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: setupSubjects,
      page: () => const SetupSubjectsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: setupTimetable,
      page: () => const SetupTimetablePage(),
      transition: Transition.rightToLeft,
    ),

    // Main screens
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: today,
      page: () => const TodayAttendancePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: timetable,
      page: () => const TimetablePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: calendar,
      page: () => const CalendarPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.fadeIn,
    ),

    // Edit attendance for any date
    GetPage(
      name: editAttendance,
      page: () => const EditAttendancePage(),
      transition: Transition.rightToLeft,
    ),

    // Subject screens - ADD/EDIT routes must come before parameterized route
    GetPage(
      name: addSubject,
      page: () => const AddSubjectPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: editSubject,
      page: () => const AddSubjectPage(isEdit: true),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: subjectDetail,
      page: () => const SubjectDetailPage(),
      transition: Transition.rightToLeft,
    ),

    // Timetable entry screens
    GetPage(
      name: addTimetableEntry,
      page: () => const AddTimetableEntryPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: editTimetableEntry,
      page: () => const AddTimetableEntryPage(isEdit: true),
      transition: Transition.rightToLeft,
    ),
  ];
}
