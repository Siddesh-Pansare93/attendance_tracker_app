import 'package:flutter/material.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';

/// Circular attendance indicator with percentage and status color
class AttendanceIndicator extends StatelessWidget {
  final double percentage;
  final double threshold;
  final double size;
  final bool showLabel;

  const AttendanceIndicator({
    super.key,
    required this.percentage,
    required this.threshold,
    this.size = 80,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(percentage, threshold);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: size * 0.1,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.2)),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              strokeWidth: size * 0.1,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Percentage text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.22,
                  color: color,
                ),
              ),
              if (showLabel)
                Text(
                  AppTheme.getStatusText(percentage, threshold),
                  style: textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: size * 0.12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Linear attendance indicator bar
class AttendanceBar extends StatelessWidget {
  final double percentage;
  final double threshold;
  final double height;

  const AttendanceBar({
    super.key,
    required this.percentage,
    required this.threshold,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(percentage, threshold);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (percentage / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// Small status badge showing Safe/Warning/Critical
class StatusBadge extends StatelessWidget {
  final double percentage;
  final double threshold;

  const StatusBadge({
    super.key,
    required this.percentage,
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(percentage, threshold);
    final statusText = AppTheme.getStatusText(percentage, threshold);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
