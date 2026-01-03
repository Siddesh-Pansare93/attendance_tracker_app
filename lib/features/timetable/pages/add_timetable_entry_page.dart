import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';

/// Page for adding or editing a timetable entry
class AddTimetableEntryPage extends StatefulWidget {
  final bool isEdit;

  const AddTimetableEntryPage({super.key, this.isEdit = false});

  @override
  State<AddTimetableEntryPage> createState() => _AddTimetableEntryPageState();
}

class _AddTimetableEntryPageState extends State<AddTimetableEntryPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSubjectId;
  int _selectedDay = 1; // Monday
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedType = 'Lecture';

  late String? _editId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<TimetableController>();
    _selectedDay = controller.selectedDay.value;

    if (widget.isEdit) {
      _editId = Get.parameters['id'];
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    if (_editId == null) return;
    final controller = Get.find<TimetableController>();
    final entry = controller.getEntry(_editId!);
    if (entry != null) {
      setState(() {
        _selectedSubjectId = entry.subjectId;
        _selectedDay = entry.dayOfWeek;
        _startTime = _parseTime(entry.startTime);
        _endTime = _parseTime(entry.endTime);
        _selectedType = entry.type;
      });
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimetableController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit Entry' : 'Add Class')),
      body: Obx(() {
        final subjects = controller.subjects;

        if (subjects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 64,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text('No Subjects Found', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Please add subjects first before creating a timetable.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Subject dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Icons.book),
                ),
                items: subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject.id,
                    child: Text(subject.name),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSubjectId = value),
                validator: (value) {
                  if (value == null) return 'Please select a subject';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Day of week
              DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: List.generate(7, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(kDayNames[index]),
                  );
                }),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDay = value);
                },
              ),
              const SizedBox(height: 16),

              // Time row
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      'Start Time',
                      _startTime,
                      (time) => setState(() => _startTime = time),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      'End Time',
                      _endTime,
                      (time) => setState(() => _endTime = time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Class type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Class Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: kClassTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEntry,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.isEdit ? 'Save Changes' : 'Add Entry'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time),
        ),
        child: Text(time.format(context), style: theme.textTheme.bodyLarge),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate times
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) {
      Get.snackbar(
        'Invalid Time',
        'End time must be after start time',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = Get.find<TimetableController>();

      if (widget.isEdit && _editId != null) {
        // Delete old entry and create new one with same ID
        await controller.deleteEntry(_editId!);
        await controller.addEntry(
          subjectId: _selectedSubjectId!,
          dayOfWeek: _selectedDay,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          type: _selectedType,
        );
      } else {
        await controller.addEntry(
          subjectId: _selectedSubjectId!,
          dayOfWeek: _selectedDay,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          type: _selectedType,
        );
      }

      Get.back();
      Get.snackbar(
        'Success',
        widget.isEdit ? 'Entry updated!' : 'Entry added!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save entry. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
