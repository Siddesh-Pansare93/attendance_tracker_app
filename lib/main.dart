import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/routes/app_routes.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';

/// Main entry point for the Smart Attendance Tracker app
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage services (Hive + SharedPreferences)
  await StorageService.init();

  runApp(const SmartAttendanceApp());
}

/// Root widget of the application
class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if setup is complete to determine initial route
    final storage = StorageService.instance;
    final isSetupComplete = storage.isSetupComplete();
    final isDarkMode = storage.isDarkMode();

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
