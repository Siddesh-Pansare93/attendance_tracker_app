import 'package:flutter/material.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';

/// Reusable empty state widget with premium styling
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                    colorScheme.secondary.withValues(
                      alpha: isDark ? 0.15 : 0.08,
                    ),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, size: 44, color: colorScheme.primary),
            ),
            const SizedBox(height: 28),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for no subjects
class NoSubjectsEmpty extends StatelessWidget {
  final VoidCallback? onAdd;

  const NoSubjectsEmpty({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.school_rounded,
      title: 'No Subjects Yet',
      subtitle:
          'Add your first subject to start tracking your attendance journey',
      actionLabel: 'Add Subject',
      onAction: onAdd,
    );
  }
}

/// Empty state for no timetable
class NoTimetableEmpty extends StatelessWidget {
  final VoidCallback? onAdd;

  const NoTimetableEmpty({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_rounded,
      title: 'No Classes Scheduled',
      subtitle: 'Add classes to your timetable for this day',
      actionLabel: 'Add Class',
      onAction: onAdd,
    );
  }
}

/// Empty state for no classes today
class NoClassesTodayEmpty extends StatelessWidget {
  const NoClassesTodayEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.safeColor.withValues(alpha: isDark ? 0.2 : 0.15),
                    const Color(
                      0xFF22C55E,
                    ).withValues(alpha: isDark ? 0.15 : 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 44,
                color: AppTheme.safeColor,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Day Off! 🎉',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No classes scheduled for today.\nEnjoy your free time!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for no attendance records
class NoAttendanceRecordsEmpty extends StatelessWidget {
  const NoAttendanceRecordsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.history_rounded,
      title: 'No History Yet',
      subtitle: 'Start marking attendance to see your history here',
    );
  }
}
