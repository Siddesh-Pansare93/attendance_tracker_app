import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_attendance_app/core/repositories/timetable_repository.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';

/// Hive implementation of TimetableRepository
class HiveTimetableRepository implements TimetableRepository {
  final Box<TimetableEntry> _box;

  HiveTimetableRepository(this._box);

  @override
  List<TimetableEntry> getAll() {
    return _box.values.toList();
  }

  @override
  List<TimetableEntry> getByDay(int dayOfWeek) {
    return _box.values.where((entry) => entry.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  TimetableEntry? getById(String id) {
    return _box.get(id);
  }

  @override
  Future<void> save(TimetableEntry entry) async {
    await _box.put(entry.id, entry);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteBySubjectId(String subjectId) async {
    final entries = _box.values.where((e) => e.subjectId == subjectId).toList();
    for (final entry in entries) {
      await _box.delete(entry.id);
    }
  }
}
