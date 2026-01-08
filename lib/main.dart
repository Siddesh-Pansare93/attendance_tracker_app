import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/core/bindings/initial_binding.dart';
import 'package:smart_attendance_app/core/repositories/settings_repository.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Main entry point for the Smart Attendance Tracker app
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(TimetableEntryAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());

  // Open boxes
  final subjectsBox = await Hive.openBox<Subject>(kSubjectsBox);
  final timetableBox = await Hive.openBox<TimetableEntry>(kTimetableBox);
  final attendanceBox = await Hive.openBox<AttendanceRecord>(kAttendanceBox);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Run app with dependency injection binding
  runApp(
    SmartAttendanceApp(
      binding: InitialBinding(
        prefs: prefs,
        subjectsBox: subjectsBox,
        timetableBox: timetableBox,
        attendanceBox: attendanceBox,
      ),
    ),
  );
}

/// Root widget of the application
class SmartAttendanceApp extends StatelessWidget {
  final InitialBinding binding;

  const SmartAttendanceApp({super.key, required this.binding});

  @override
  Widget build(BuildContext context) {
    // Bind dependencies first
    binding.dependencies();

    // Now we can safely access settings
    final settings = Get.find<SettingsRepository>();
    final isSetupComplete = settings.isSetupComplete();
    final isDarkMode = settings.isDarkMode();

    return GetMaterialApp(
      title: 'Smart Attendance Tracker',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Initial route based on setup status
      initialRoute: isSetupComplete ? AppRoutes.home : AppRoutes.welcome,

      // All app routes
      getPages: AppRoutes.pages,

      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Scroll behavior for smooth scrolling
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
