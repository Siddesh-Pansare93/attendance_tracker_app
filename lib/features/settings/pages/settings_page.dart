import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/features/settings/controller/settings_controller.dart';

/// Settings page for app configuration
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        final stats = controller.getStatistics();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Statistics card
            _buildStatsCard(context, stats),
            const SizedBox(height: 24),

            // Appearance section
            _buildSectionHeader(context, 'Appearance'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark color theme'),
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleDarkMode,
                    secondary: Icon(
                      controller.isDarkMode.value
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Attendance section
            _buildSectionHeader(context, 'Attendance Settings'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minimum Attendance',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${controller.threshold.value.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: controller.threshold.value,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      label:
                          '${controller.threshold.value.toStringAsFixed(0)}%',
                      onChanged: controller.updateThreshold,
                    ),
                    Text(
                      'You will be warned when your attendance falls below this percentage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications section
            _buildSectionHeader(context, 'Notifications'),
            Card(
              child: SwitchListTile(
                title: const Text('Enable Alerts'),
                subtitle: const Text('Show in-app attendance warnings'),
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
                secondary: const Icon(Icons.notifications_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Danger zone
            _buildSectionHeader(context, 'Data Management', isWarning: true),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: AppTheme.criticalColor,
                ),
                title: const Text(
                  'Reset All Data',
                  style: TextStyle(color: AppTheme.criticalColor),
                ),
                subtitle: const Text(
                  'Delete all subjects, timetable, and attendance',
                ),
                onTap: () => _showResetDialog(context, controller),
              ),
            ),
            const SizedBox(height: 32),

            // App info
            Center(
              child: Column(
                children: [
                  Text(
                    'Smart Attendance Tracker',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '100% Offline • No Data Sharing',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.safeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsCard(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Your Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '${stats['subjectsCount']}',
                  'Subjects',
                ),
                _buildStatItem(context, '${stats['totalAttended']}', 'Present'),
                _buildStatItem(
                  context,
                  '${stats['totalClasses'] - stats['totalAttended']}',
                  'Absent',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: isWarning
              ? AppTheme.criticalColor
              : theme.colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.criticalColor),
            const SizedBox(width: 8),
            const Text('Reset All Data'),
          ],
        ),
        content: const Text(
          'This will delete ALL your data including:\n\n'
          '• All subjects\n'
          '• All timetable entries\n'
          '• All attendance records\n'
          '• All settings\n\n'
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.resetAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.criticalColor,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }
}
