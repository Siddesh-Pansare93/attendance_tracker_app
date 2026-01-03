import 'package:hive/hive.dart';

part 'timetable_entry_model.g.dart';

/// Model representing a timetable entry (a class scheduled for a day)
@HiveType(typeId: 2)
class TimetableEntry extends HiveObject {
  /// Unique identifier
  @HiveField(0)
  final String id;

  /// Subject ID this entry belongs to
  @HiveField(1)
  final String subjectId;

  /// Day of week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
  @HiveField(2)
  int dayOfWeek;

  /// Start time in 24-hour format (e.g., "10:00")
  @HiveField(3)
  String startTime;

  /// End time in 24-hour format (e.g., "11:00")
  @HiveField(4)
  String endTime;

  /// Type of class (e.g., "Lecture", "Lab", "Tutorial")
  @HiveField(5)
  String type;

  TimetableEntry({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.type = 'Lecture',
  });

  /// Create a copy with updated values
  TimetableEntry copyWith({
    String? id,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? type,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
    };
  }

  /// Create from JSON map
  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      type: json['type'] as String? ?? 'Lecture',
    );
  }

  @override
  String toString() {
    return 'TimetableEntry(id: $id, subjectId: $subjectId, day: $dayOfWeek, time: $startTime-$endTime)';
  }
}
