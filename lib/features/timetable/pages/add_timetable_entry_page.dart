import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/features/timetable/controller/timetable_controller.dart';

/// Page for adding or editing a timetable entry
/// Simplified to just select subject and day - no timing or type needed
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
      });
    }
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
                initialValue: _selectedSubjectId,
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
                initialValue: _selectedDay,
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
                      : Text(widget.isEdit ? 'Save Changes' : 'Add Class'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = Get.find<TimetableController>();

      if (widget.isEdit && _editId != null) {
        await controller.deleteEntry(_editId!);
      }

      await controller.addEntry(
        subjectId: _selectedSubjectId!,
        dayOfWeek: _selectedDay,
      );

      Get.back();
      Get.snackbar(
        'Success',
        widget.isEdit ? 'Class updated!' : 'Class added!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
