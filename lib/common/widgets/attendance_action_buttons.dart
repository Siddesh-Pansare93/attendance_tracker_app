import 'package:flutter/material.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';

/// Reusable widget for attendance action buttons (Present/Absent/Cancelled)
///
/// This follows DRY principle - extracted from TodayAttendancePage
/// and EditAttendancePage to avoid code duplication
class AttendanceActionButtons extends StatelessWidget {
  final VoidCallback onPresent;
  final VoidCallback onAbsent;
  final VoidCallback onCancelled;

  const AttendanceActionButtons({
    super.key,
    required this.onPresent,
    required this.onAbsent,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAbsent,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Absent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.criticalColor,
                  side: const BorderSide(color: AppTheme.criticalColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPresent,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Present'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.safeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCancelled,
            icon: const Icon(Icons.event_busy, size: 18),
            label: const Text('Lecture Cancelled'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.warningColor,
              side: const BorderSide(color: AppTheme.warningColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
