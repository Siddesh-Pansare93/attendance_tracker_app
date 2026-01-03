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
import 'package:smart_attendance_app/features/settings/controller/settings_controller.dart';

/// Main home page with bottom navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    TodayAttendancePage(),
    TimetablePage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize all controllers
    Get.put(DashboardController());
    Get.put(AttendanceController());
    Get.put(TimetableController());
    Get.put(CalendarController());
    Get.put(SettingsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
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
