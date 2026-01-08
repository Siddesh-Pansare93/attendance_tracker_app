import 'package:flutter/material.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';

/// Reusable widget for displaying attendance status
///
/// This follows DRY principle - extracted from TodayAttendancePage
/// and EditAttendancePage to avoid code duplication
class AttendanceStatusBadge extends StatelessWidget {
  final String status;
  final VoidCallback? onChangePressed;

  const AttendanceStatusBadge({
    super.key,
    required this.status,
    this.onChangePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusColor, statusIcon, statusText) = _getStatusInfo();

    return Row(
      children: [
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Change button
        if (onChangePressed != null)
          TextButton(
            onPressed: onChangePressed,
            child: Text(
              'Change',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
      ],
    );
  }

  (Color, IconData, String) _getStatusInfo() {
    switch (status) {
      case 'present':
        return (AppTheme.safeColor, Icons.check_circle, 'Marked Present');
      case 'cancelled':
        return (AppTheme.warningColor, Icons.event_busy, 'Lecture Cancelled');
      default:
        return (AppTheme.criticalColor, Icons.cancel, 'Marked Absent');
    }
  }
}
