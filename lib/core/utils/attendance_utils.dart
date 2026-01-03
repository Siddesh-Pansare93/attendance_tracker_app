import 'package:intl/intl.dart';

/// Utility functions for attendance calculations and date formatting
class AttendanceUtils {
  AttendanceUtils._();

  /// Calculate attendance percentage
  /// Returns 0.0 if totalClasses is 0 (prevents division by zero)
  static double calculatePercentage(int attendedClasses, int totalClasses) {
    if (totalClasses == 0) return 0.0;
    return (attendedClasses / totalClasses) * 100;
  }

  /// Calculate how many classes can be missed while staying above threshold
  /// Returns negative number if already below threshold (need to attend more)
  static int classesCanMiss(
    int attendedClasses,
    int totalClasses,
    double threshold,
  ) {
    if (totalClasses == 0) return 0;

    // Let x = number of future classes we can miss
    // (attended) / (total + x) >= threshold/100
    // attended >= (total + x) * threshold/100
    // attended * 100 / threshold >= total + x
    // x <= (attended * 100 / threshold) - total

    final maxMissable = ((attendedClasses * 100) / threshold) - totalClasses;
    return maxMissable.floor();
  }

  /// Calculate how many consecutive classes must be attended to reach threshold
  /// Returns 0 if already at or above threshold
  static int classesToReachThreshold(
    int attendedClasses,
    int totalClasses,
    double threshold,
  ) {
    if (totalClasses == 0) return 0;

    final currentPercentage = calculatePercentage(
      attendedClasses,
      totalClasses,
    );
    if (currentPercentage >= threshold) return 0;

    // Let x = number of future classes to attend
    // (attended + x) / (total + x) >= threshold/100
    // (attended + x) * 100 >= (total + x) * threshold
    // attended * 100 + x * 100 >= total * threshold + x * threshold
    // x * (100 - threshold) >= total * threshold - attended * 100
    // x >= (total * threshold - attended * 100) / (100 - threshold)

    if (threshold >= 100) return -1; // Impossible to reach 100%+

    final required =
        ((totalClasses * threshold) - (attendedClasses * 100)) /
        (100 - threshold);
    return required.ceil();
  }

  /// Get attendance status message
  static String getStatusMessage(
    int attendedClasses,
    int totalClasses,
    double threshold,
  ) {
    if (totalClasses == 0) {
      return 'No classes yet';
    }

    final percentage = calculatePercentage(attendedClasses, totalClasses);
    final canMiss = classesCanMiss(attendedClasses, totalClasses, threshold);
    final needToAttend = classesToReachThreshold(
      attendedClasses,
      totalClasses,
      threshold,
    );

    if (percentage >= threshold) {
      if (canMiss > 0) {
        return 'You can miss $canMiss more class${canMiss == 1 ? '' : 'es'}';
      } else {
        return 'On the edge! Don\'t miss any class';
      }
    } else {
      if (needToAttend > 0) {
        return 'Attend next $needToAttend class${needToAttend == 1 ? '' : 'es'} to recover';
      } else {
        return 'Below required attendance';
      }
    }
  }

  /// Format date to YYYY-MM-DD (for storage)
  static String formatDateForStorage(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date for display (e.g., "Mon, Jan 6")
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  /// Format date for display (e.g., "January 6, 2026")
  static String formatDateLong(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Parse date from storage format
  static DateTime parseDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  /// Get today's date as string
  static String getTodayString() {
    return formatDateForStorage(DateTime.now());
  }

  /// Get current day of week (0 = Sunday, 6 = Saturday)
  static int getCurrentDayOfWeek() {
    return DateTime.now().weekday %
        7; // Convert from 1-7 (Mon-Sun) to 0-6 (Sun-Sat)
  }

  /// Format time for display (e.g., "10:00 AM")
  static String formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return time24;
    }
  }

  /// Format time range (e.g., "10:00 AM - 11:00 AM")
  static String formatTimeRange(String startTime, String endTime) {
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }
}
