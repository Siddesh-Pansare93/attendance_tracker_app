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
import 'package:smart_attendance_app/core/theme/app_theme.dart';

/// Main home page with modern minimal navigation bar
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

  static const List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.dashboard_outlined,
      'selectedIcon': Icons.dashboard,
      'label': 'Home',
    },
    {
      'icon': Icons.bar_chart_outlined,
      'selectedIcon': Icons.bar_chart,
      'label': 'Analytics',
    },
    {
      'icon': Icons.schedule_outlined,
      'selectedIcon': Icons.schedule,
      'label': 'Schedule',
    },
    {
      'icon': Icons.calendar_month_outlined,
      'selectedIcon': Icons.calendar_month,
      'label': 'Calendar',
    },
    {
      'icon': Icons.settings_outlined,
      'selectedIcon': Icons.settings,
      'label': 'Settings',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;

    return Scaffold(
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[currentIndex.value],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkBorderSubtle
                    : AppTheme.borderSubtle,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex.value,
            onDestinationSelected: (index) {
              currentIndex.value = index;
              _refreshCurrentTab(index);
            },
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            destinations: [
              for (int i = 0; i < _navItems.length; i++)
                NavigationDestination(
                  icon: Icon(_navItems[i]['icon'] as IconData),
                  selectedIcon: Icon(_navItems[i]['selectedIcon'] as IconData),
                  label: _navItems[i]['label'] as String,
                ),
            ],
          ),
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
