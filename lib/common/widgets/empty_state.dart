import 'package:flutter/material.dart';

/// Reusable empty state widget for when no data exists
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animated container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state variants for common scenarios
class NoSubjectsEmpty extends StatelessWidget {
  final VoidCallback? onAdd;

  const NoSubjectsEmpty({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.school_outlined,
      title: 'No Subjects Yet',
      subtitle: 'Add your subjects to start tracking attendance',
      actionLabel: 'Add Subject',
      onAction: onAdd,
    );
  }
}

class NoTimetableEmpty extends StatelessWidget {
  final VoidCallback? onAdd;

  const NoTimetableEmpty({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No Classes Scheduled',
      subtitle: 'Add classes to your timetable for this day',
      actionLabel: 'Add Class',
      onAction: onAdd,
    );
  }
}

class NoClassesTodayEmpty extends StatelessWidget {
  const NoClassesTodayEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.event_available_outlined,
      title: 'No Classes Today',
      subtitle:
          'Enjoy your day off! Check your timetable for upcoming classes.',
    );
  }
}

class NoAttendanceRecordsEmpty extends StatelessWidget {
  const NoAttendanceRecordsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.history_outlined,
      title: 'No Attendance History',
      subtitle: 'Start marking attendance to see your history here',
    );
  }
}
