import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/core/utils/attendance_utils.dart';
import 'package:smart_attendance_app/core/services/storage_service.dart';
import 'package:smart_attendance_app/features/attendance/data/model/attendance_record_model.dart';
import 'package:smart_attendance_app/features/attendance/data/model/subject_model.dart';
import 'package:smart_attendance_app/features/timetable/data/model/timetable_entry_model.dart';
import 'package:uuid/uuid.dart';

/// Page for editing attendance on any date
class EditAttendancePage extends StatefulWidget {
  const EditAttendancePage({super.key});

  @override
  State<EditAttendancePage> createState() => _EditAttendancePageState();
}

class _EditAttendancePageState extends State<EditAttendancePage> {
  final _storage = StorageService.instance;
  final _uuid = const Uuid();

  late DateTime _date;
  List<TimetableEntry> _entries = [];
  List<AttendanceRecord> _records = [];
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _date = Get.arguments as DateTime? ?? DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final dayOfWeek = _date.weekday % 7; // Convert to 0-6 (Sun-Sat)
    _entries = _storage
        .getAllTimetableEntries()
        .where((e) => e.dayOfWeek == dayOfWeek)
        .toList();

    _subjects = _storage.getAllSubjects();

    final dateStr = AttendanceUtils.formatDateForStorage(_date);
    _records = _storage.getAttendanceForDate(dateStr);

    setState(() => _isLoading = false);
  }

  String? _getRecordStatus(String entryId) {
    try {
      final record = _records.firstWhere((r) => r.timetableEntryId == entryId);
      return record.status;
    } catch (_) {
      return null;
    }
  }

  Future<void> _markAttendance(TimetableEntry entry, String status) async {
    final dateStr = AttendanceUtils.formatDateForStorage(_date);
    final subject = _subjects.firstWhere((s) => s.id == entry.subjectId);

    // Find existing record
    AttendanceRecord? existingRecord;
    try {
      existingRecord = _records.firstWhere(
        (r) => r.timetableEntryId == entry.id,
      );
    } catch (_) {}

    if (existingRecord != null) {
      // Update existing
      final oldStatus = existingRecord.status;
      existingRecord.status = status;
      await _storage.saveAttendanceRecord(existingRecord);

      // Update subject counts
      if (oldStatus != status) {
        if (oldStatus == 'present') subject.attendedClasses -= 1;
        if (oldStatus != 'cancelled') subject.totalClasses -= 1;
        if (status == 'present') subject.attendedClasses += 1;
        if (status != 'cancelled') subject.totalClasses += 1;
        await _storage.saveSubject(subject);
      }
    } else {
      // Create new
      final record = AttendanceRecord(
        id: _uuid.v4(),
        subjectId: entry.subjectId,
        date: dateStr,
        status: status,
        timetableEntryId: entry.id,
      );
      await _storage.saveAttendanceRecord(record);

      if (status != 'cancelled') {
        subject.totalClasses += 1;
        if (status == 'present') subject.attendedClasses += 1;
        await _storage.saveSubject(subject);
      }
    }

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(AttendanceUtils.formatDateLong(_date))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No classes scheduled',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'on ${AttendanceUtils.formatDateLong(_date)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, index) =>
                  _buildClassCard(context, _entries[index], isDark),
            ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    TimetableEntry entry,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final subject = _subjects.firstWhere(
      (s) => s.id == entry.subjectId,
      orElse: () => Subject(id: '', name: 'Unknown'),
    );
    final status = _getRecordStatus(entry.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161622) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3C) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.book_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${subject.attendancePercentage.toStringAsFixed(1)}% attendance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status buttons or marked status
            if (status != null)
              _buildMarkedStatus(context, status, entry)
            else
              _buildActionButtons(context, entry),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TimetableEntry entry) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatusButton(
                context,
                entry,
                'absent',
                'Absent',
                Icons.close_rounded,
                AppTheme.criticalColor,
                filled: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusButton(
                context,
                entry,
                'present',
                'Present',
                Icons.check_rounded,
                AppTheme.safeColor,
                filled: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildStatusButton(
          context,
          entry,
          'cancelled',
          'Lecture Cancelled',
          Icons.event_busy_rounded,
          AppTheme.warningColor,
          filled: false,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    TimetableEntry entry,
    String status,
    String label,
    IconData icon,
    Color color, {
    bool filled = false,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: filled
          ? ElevatedButton.icon(
              onPressed: () => _markAttendance(entry, status),
              icon: Icon(icon, size: 20),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: () => _markAttendance(entry, status),
              icon: Icon(icon, size: 20),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }

  Widget _buildMarkedStatus(
    BuildContext context,
    String status,
    TimetableEntry entry,
  ) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'present':
        statusColor = AppTheme.safeColor;
        statusIcon = Icons.check_circle;
        statusText = 'Marked Present';
        break;
      case 'cancelled':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.event_busy;
        statusText = 'Lecture Cancelled';
        break;
      default:
        statusColor = AppTheme.criticalColor;
        statusIcon = Icons.cancel;
        statusText = 'Marked Absent';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _showChangeDialog(context, entry, status),
          child: Text(
            'Change',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  void _showChangeDialog(
    BuildContext context,
    TimetableEntry entry,
    String currentStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Attendance'),
        content: const Text('Select new attendance status:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (currentStatus != 'absent')
            TextButton(
              onPressed: () {
                _markAttendance(entry, 'absent');
                Navigator.pop(context);
              },
              child: Text(
                'Absent',
                style: TextStyle(color: AppTheme.criticalColor),
              ),
            ),
          if (currentStatus != 'present')
            ElevatedButton(
              onPressed: () {
                _markAttendance(entry, 'present');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.safeColor,
              ),
              child: const Text('Present'),
            ),
          if (currentStatus != 'cancelled')
            TextButton(
              onPressed: () {
                _markAttendance(entry, 'cancelled');
                Navigator.pop(context);
              },
              child: Text(
                'Cancelled',
                style: TextStyle(color: AppTheme.warningColor),
              ),
            ),
        ],
      ),
    );
  }
}
