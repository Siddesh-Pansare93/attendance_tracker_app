import 'package:hive/hive.dart';

part 'attendance_record_model.g.dart';

/// Model representing an attendance record for a specific date
@HiveType(typeId: 1)
class AttendanceRecord extends HiveObject {
  /// Unique identifier
  @HiveField(0)
  final String id;

  /// Subject ID this record belongs to
  @HiveField(1)
  final String subjectId;

  /// Date in YYYY-MM-DD format
  @HiveField(2)
  final String date;

  /// Attendance status: "present" or "absent"
  @HiveField(3)
  String status;

  /// Timetable entry ID for tracking individual lecture instances
  @HiveField(4)
  final String? timetableEntryId;

  AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.status,
    this.timetableEntryId,
  });

  /// Check if marked as present
  bool get isPresent => status == 'present';

  /// Check if marked as absent
  bool get isAbsent => status == 'absent';

  /// Check if marked as cancelled
  bool get isCancelled => status == 'cancelled';

  /// Create a copy with updated values
  AttendanceRecord copyWith({
    String? id,
    String? subjectId,
    String? date,
    String? status,
    String? timetableEntryId,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      status: status ?? this.status,
      timetableEntryId: timetableEntryId ?? this.timetableEntryId,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'date': date,
      'status': status,
      'timetableEntryId': timetableEntryId,
    };
  }

  /// Create from JSON map
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      timetableEntryId: json['timetableEntryId'] as String?,
    );
  }

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, subjectId: $subjectId, date: $date, status: $status, entryId: $timetableEntryId)';
  }
}
