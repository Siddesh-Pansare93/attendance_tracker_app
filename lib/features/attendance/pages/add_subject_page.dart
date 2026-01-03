import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/features/attendance/controller/attendance_controller.dart';

/// Page for adding or editing a subject
class AddSubjectPage extends StatefulWidget {
  final bool isEdit;

  const AddSubjectPage({super.key, this.isEdit = false});

  @override
  State<AddSubjectPage> createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _thresholdController = TextEditingController();

  late String? _editId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _editId = Get.parameters['id'];
      _loadExistingData();
    } else {
      // Set default threshold
      final controller = Get.find<AttendanceController>();
      _thresholdController.text = controller.threshold.value.toStringAsFixed(0);
    }
  }

  void _loadExistingData() {
    if (_editId == null) return;
    final controller = Get.find<AttendanceController>();
    final subject = controller.getSubject(_editId!);
    if (subject != null) {
      _nameController.text = subject.name;
      _thresholdController.text = subject.minimumRequiredPercentage
          .toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Subject' : 'Add Subject'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Subject name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                hintText: 'e.g., Mathematics, Physics',
                prefixIcon: Icon(Icons.book),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Minimum attendance
            TextFormField(
              controller: _thresholdController,
              decoration: const InputDecoration(
                labelText: 'Minimum Required Attendance (%)',
                hintText: 'e.g., 75',
                prefixIcon: Icon(Icons.percent),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a percentage';
                }
                final num = double.tryParse(value);
                if (num == null || num < 0 || num > 100) {
                  return 'Enter a value between 0 and 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The app will alert you when your attendance falls below the minimum required percentage.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSubject,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEdit ? 'Save Changes' : 'Add Subject'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = Get.find<AttendanceController>();
      final name = _nameController.text.trim();
      final threshold = double.parse(_thresholdController.text);

      if (widget.isEdit && _editId != null) {
        // Update existing subject
        final subject = controller.getSubject(_editId!);
        if (subject != null) {
          subject.name = name;
          subject.minimumRequiredPercentage = threshold;
          await controller.updateSubject(subject);
        }
      } else {
        // Add new subject
        await controller.addSubject(name, minPercentage: threshold);
      }

      Get.back();
      Get.snackbar(
        'Success',
        widget.isEdit ? 'Subject updated!' : 'Subject added!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save subject. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
