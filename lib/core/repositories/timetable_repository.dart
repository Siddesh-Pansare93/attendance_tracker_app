import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Repository interface for Timetable data operations
/// Following Interface Segregation Principle - focused on Timetable only
abstract class TimetableRepository {
  List<TimetableEntry> getAll();
  List<TimetableEntry> getByDay(int dayOfWeek);
  TimetableEntry? getById(String id);
  Future<void> save(TimetableEntry entry);
  Future<void> delete(String id);
  Future<void> deleteBySubjectId(String subjectId);
}
