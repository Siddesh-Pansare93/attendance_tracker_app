import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';

/// Repository interface for Attendance data operations
/// Following Interface Segregation Principle - focused on Attendance only
abstract class AttendanceRepository {
  List<AttendanceRecord> getAll();
  List<AttendanceRecord> getBySubjectId(String subjectId);
  List<AttendanceRecord> getByDate(String date);
  AttendanceRecord? getById(String id);
  AttendanceRecord? getBySubjectAndDate(String subjectId, String date);
  bool isMarked(String subjectId, String date);
  Future<void> save(AttendanceRecord record);
  Future<void> delete(String id);
  Future<void> deleteBySubjectId(String subjectId);
}
