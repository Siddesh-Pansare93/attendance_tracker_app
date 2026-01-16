import 'package:flutter/material.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';

/// Reusable tile widget for displaying today's classes with inline attendance buttons
///
/// This widget displays a class/lecture and allows users to mark attendance directly
/// without navigating to a separate page.
class TodayClassTile extends StatelessWidget {
  /// Subject name
  final String subjectName;

  /// Class type (Lecture, Lab, Tutorial, Seminar)
  final String classType;

  /// Start time in HH:MM format
  final String startTime;

  /// End time in HH:MM format
  final String endTime;

  /// Current attendance status (null if not marked)
  final String? currentStatus;

  /// Whether attendance marking is in progress
  final bool isMarking;

  /// Callback when Present button is pressed
  final VoidCallback onPresent;

  /// Callback when Absent button is pressed
  final VoidCallback onAbsent;

  /// Callback when Lecture Cancelled button is pressed
  final VoidCallback onCancelled;

  /// Callback to change status (only shown if already marked)
  final VoidCallback? onChangeStatus;

  const TodayClassTile({
    super.key,
    required this.subjectName,
    required this.classType,
    required this.startTime,
    required this.endTime,
    this.currentStatus,
    this.isMarking = false,
    required this.onPresent,
    required this.onAbsent,
    required this.onCancelled,
    this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subject name, class type, and action buttons
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AttendanceUtils.formatTimeRange(startTime, endTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Class type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    classType,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Action buttons row
                if (currentStatus != null)
                  _buildStatusIndicator(context)
                else
                  _buildCompactActionButtons(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build compact circular action buttons for the header row
  Widget _buildCompactActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    if (isMarking) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Absent button - small circular
        SizedBox(
          width: 28,
          height: 28,
          child: Tooltip(
            message: 'Absent',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAbsent,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.criticalColor,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppTheme.criticalColor,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Present button - small circular
        SizedBox(
          width: 28,
          height: 28,
          child: Tooltip(
            message: 'Present',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPresent,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.safeColor,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Cancelled button - small circular
        SizedBox(
          width: 28,
          height: 28,
          child: Tooltip(
            message: 'Cancelled',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCancelled,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.warningColor,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.event_busy,
                    color: AppTheme.warningColor,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build status indicator for when attendance is already marked
  Widget _buildStatusIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final (statusColor, statusIcon, _) = _getStatusInfo();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator circle
        SizedBox(
          width: 28,
          height: 28,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.2),
              border: Border.all(
                color: statusColor,
                width: 1.5,
              ),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 14,
            ),
          ),
        ),
        if (onChangeStatus != null) ...[
          const SizedBox(width: 6),
          // Edit button - small circular
          SizedBox(
            width: 28,
            height: 28,
            child: Tooltip(
              message: 'Change',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onChangeStatus,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: theme.colorScheme.primary,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Get status display info
  (Color, IconData, String) _getStatusInfo() {
    switch (currentStatus) {
      case 'present':
        return (AppTheme.safeColor, Icons.check_circle, 'Marked Present');
      case 'cancelled':
        return (AppTheme.warningColor, Icons.event_busy, 'Lecture Cancelled');
      default:
        return (AppTheme.criticalColor, Icons.cancel, 'Marked Absent');
    }
  }

}
