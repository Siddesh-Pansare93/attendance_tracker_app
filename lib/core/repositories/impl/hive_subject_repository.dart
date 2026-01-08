import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_attendance_app/core/repositories/subject_repository.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';

/// Hive implementation of SubjectRepository
/// This separates the storage mechanism from the interface
class HiveSubjectRepository implements SubjectRepository {
  final Box<Subject> _box;

  HiveSubjectRepository(this._box);

  @override
  List<Subject> getAll() {
    return _box.values.toList();
  }

  @override
  Subject? getById(String id) {
    return _box.get(id);
  }

  @override
  Future<void> save(Subject subject) async {
    await _box.put(subject.id, subject);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
