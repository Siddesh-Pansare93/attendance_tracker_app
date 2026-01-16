import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/features/settings/controller/settings_controller.dart';

/// Modern minimalist settings page with clean controls
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBgPrimary : AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.value(null),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          children: [
            // Statistics section
            _buildStatsCard(context, controller.getStatistics(), isDark),
            const SizedBox(height: 24),

            // Appearance section
            _buildSectionHeader(context, 'Appearance', isDark),
            _buildAppearanceCard(context, controller, isDark),
            const SizedBox(height: 24),

            // Attendance section
            _buildSectionHeader(context, 'Attendance Settings', isDark),
            _buildAttendanceCard(context, controller, isDark),
            const SizedBox(height: 24),

            // Notifications section
            _buildSectionHeader(context, 'Notifications', isDark),
            _buildNotificationsCard(context, controller, isDark),
            const SizedBox(height: 24),

            // Data Management section
            _buildSectionHeader(
              context,
              'Data Management',
              isDark,
              isWarning: true,
            ),
            _buildDataManagementCard(context, controller, isDark),
            const SizedBox(height: 32),

            // App info footer
            _buildAppInfoFooter(context, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Statistics card
  Widget _buildStatsCard(
    BuildContext context,
    Map<String, dynamic> stats,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
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
                isDark,
              ),
              _buildStatItem(
                context,
                '${stats['totalAttended']}',
                'Present',
                isDark,
                color: AppTheme.safeColor,
              ),
              _buildStatItem(
                context,
                '${stats['totalClasses'] - stats['totalAttended']}',
                'Absent',
                isDark,
                color: AppTheme.criticalColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Single stat item
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    bool isDark, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Section header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isDark, {
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isWarning
              ? AppTheme.criticalColor
              : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Appearance card
  Widget _buildAppearanceCard(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      child: Obx(
        () => SwitchListTile(
          title: Text(
            'Dark Mode',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Use dark color theme',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
            ),
          ),
          value: controller.isDarkMode.value,
          onChanged: controller.toggleDarkMode,
          secondary: Icon(
            controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
            color: AppTheme.primaryColor,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  /// Attendance settings card
  Widget _buildAttendanceCard(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum Attendance',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryColor.withValues(alpha: 0.15)
                        : AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${controller.threshold.value.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: controller.threshold.value,
                min: 50,
                max: 100,
                divisions: 10,
                activeColor: AppTheme.primaryColor,
                inactiveColor: isDark
                    ? AppTheme.darkBorderSubtle
                    : AppTheme.borderSubtle,
                label: '${controller.threshold.value.toStringAsFixed(0)}%',
                onChanged: controller.updateThreshold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will be warned when your attendance falls below this percentage',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Notifications card
  Widget _buildNotificationsCard(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      child: Obx(
        () => SwitchListTile(
          title: Text(
            'Enable Alerts',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Show in-app attendance warnings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
            ),
          ),
          value: controller.notificationsEnabled.value,
          onChanged: controller.toggleNotifications,
          secondary: const Icon(
            Icons.notifications_outlined,
            color: AppTheme.primaryColor,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  /// Data management card
  Widget _buildDataManagementCard(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceDefault : AppTheme.surfaceDefault,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderSubtle : AppTheme.borderSubtle,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.criticalColor.withValues(alpha: 0.15)
                : AppTheme.criticalColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: AppTheme.criticalColor,
            size: 22,
          ),
        ),
        title: Text(
          'Reset All Data',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.criticalColor,
          ),
        ),
        subtitle: Text(
          'Delete all subjects, timetable, and attendance',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
          ),
        ),
        onTap: () => _showResetDialog(context, controller),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  /// App info footer
  Widget _buildAppInfoFooter(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
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
            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.safeColor.withValues(alpha: 0.15)
                : AppTheme.safeSoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '100% Offline • No Data Sharing',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.safeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Show reset confirmation dialog
  void _showResetDialog(BuildContext context, SettingsController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppTheme.darkSurfaceDefault
            : AppTheme.surfaceDefault,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.warning_outlined, color: AppTheme.criticalColor),
            const SizedBox(width: 8),
            const Text('Reset All Data'),
          ],
        ),
        content: Text(
          'This will delete ALL your data including:\n\n'
          '• All subjects\n'
          '• All timetable entries\n'
          '• All attendance records\n'
          '• All settings\n\n'
          'This action cannot be undone!',
          style: Theme.of(context).textTheme.bodyMedium,
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
