import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';

/// Repository interface for Subject data operations
/// Following Interface Segregation Principle - focused on Subject only
abstract class SubjectRepository {
  List<Subject> getAll();
  Subject? getById(String id);
  Future<void> save(Subject subject);
  Future<void> delete(String id);
}
