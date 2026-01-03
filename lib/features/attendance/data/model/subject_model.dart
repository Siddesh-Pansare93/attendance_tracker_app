import 'package:hive/hive.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';

part 'subject_model.g.dart';

/// Model representing a subject/course
@HiveType(typeId: 0)
class Subject extends HiveObject {
  /// Unique identifier
  @HiveField(0)
  final String id;

  /// Subject name (e.g., "Mathematics", "Physics")
  @HiveField(1)
  String name;

  /// Total number of classes held
  @HiveField(2)
  int totalClasses;

  /// Number of classes attended
  @HiveField(3)
  int attendedClasses;

  /// Minimum required attendance percentage for this subject
  @HiveField(4)
  double minimumRequiredPercentage;

  Subject({
    required this.id,
    required this.name,
    this.totalClasses = 0,
    this.attendedClasses = 0,
    this.minimumRequiredPercentage = kDefaultAttendanceThreshold,
  });

  /// Calculate current attendance percentage
  double get attendancePercentage {
    if (totalClasses == 0) return 0.0;
    return (attendedClasses / totalClasses) * 100;
  }

  /// Check if attendance is at or above minimum required
  bool get isAboveThreshold =>
      attendancePercentage >= minimumRequiredPercentage;

  /// Create a copy with updated values
  Subject copyWith({
    String? id,
    String? name,
    int? totalClasses,
    int? attendedClasses,
    double? minimumRequiredPercentage,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      minimumRequiredPercentage:
          minimumRequiredPercentage ?? this.minimumRequiredPercentage,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'minimumRequiredPercentage': minimumRequiredPercentage,
    };
  }

  /// Create from JSON map
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      totalClasses: json['totalClasses'] as int? ?? 0,
      attendedClasses: json['attendedClasses'] as int? ?? 0,
      minimumRequiredPercentage:
          (json['minimumRequiredPercentage'] as num?)?.toDouble() ??
          kDefaultAttendanceThreshold,
    );
  }

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, attended: $attendedClasses/$totalClasses)';
  }
}
