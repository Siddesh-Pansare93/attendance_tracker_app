import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/features/dashboard/pages/dashboard_page.dart';
import 'package:smart_attendance_app/features/attendance/pages/today_attendance_page.dart';
import 'package:smart_attendance_app/features/timetable/pages/timetable_page.dart';
import 'package:smart_attendance_app/features/calendar/pages/calendar_page.dart';
import 'package:smart_attendance_app/features/settings/pages/settings_page.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';
import 'package:smart_attendance_app/features/calendar/controller/calendar_controller.dart';

/// Main home page with bottom navigation
///
/// REFACTORED:
/// - Removed Get.put() calls from initState()
/// - Controllers are now registered in InitialBinding at app startup
/// - Uses GetX reactive state for current index instead of setState
/// - Follows DIP - depends on abstractions, not concretions
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Pages in the bottom navigation
  static const List<Widget> _pages = [
    DashboardPage(),
    TodayAttendancePage(),
    TimetablePage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Use a simple reactive variable for tab index
    final currentIndex = 0.obs;

    return Scaffold(
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[currentIndex.value],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: currentIndex.value,
          onDestinationSelected: (index) {
            currentIndex.value = index;
            // Refresh data when switching tabs
            _refreshCurrentTab(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule_outlined),
              selectedIcon: Icon(Icons.schedule),
              label: 'Timetable',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _refreshCurrentTab(int index) {
    switch (index) {
      case 0:
        Get.find<DashboardController>().refreshData();
        break;
      case 1:
        Get.find<AttendanceController>().loadTodayClasses();
        break;
      case 2:
        Get.find<TimetableController>().loadTimetable();
        break;
      case 3:
        Get.find<CalendarController>().loadRecords();
        break;
    }
  }
}
