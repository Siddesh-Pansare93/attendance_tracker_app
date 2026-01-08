import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_attendance_app/core/repositories/attendance_repository.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';

/// Hive implementation of AttendanceRepository
class HiveAttendanceRepository implements AttendanceRepository {
  final Box<AttendanceRecord> _box;

  HiveAttendanceRepository(this._box);

  @override
  List<AttendanceRecord> getAll() {
    return _box.values.toList();
  }

  @override
  List<AttendanceRecord> getBySubjectId(String subjectId) {
    return _box.values.where((record) => record.subjectId == subjectId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  @override
  List<AttendanceRecord> getByDate(String date) {
    return _box.values.where((record) => record.date == date).toList();
  }

  @override
  AttendanceRecord? getById(String id) {
    return _box.get(id);
  }

  @override
  AttendanceRecord? getBySubjectAndDate(String subjectId, String date) {
    try {
      return _box.values.firstWhere(
        (record) => record.subjectId == subjectId && record.date == date,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  bool isMarked(String subjectId, String date) {
    return _box.values.any(
      (record) => record.subjectId == subjectId && record.date == date,
    );
  }

  @override
  Future<void> save(AttendanceRecord record) async {
    await _box.put(record.id, record);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteBySubjectId(String subjectId) async {
    final records = _box.values.where((r) => r.subjectId == subjectId).toList();
    for (final record in records) {
      await _box.delete(record.id);
    }
  }
}
