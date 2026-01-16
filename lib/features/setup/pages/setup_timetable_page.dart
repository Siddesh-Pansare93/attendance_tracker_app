import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_app/core/constants/app_constants.dart';
import 'package:smart_attendance_app/features/setup/controller/setup_controller.dart';

/// Page for creating timetable during first-time setup
/// Simplified - just select subject and day, no timing needed
class SetupTimetablePage extends StatefulWidget {
  const SetupTimetablePage({super.key});

  @override
  State<SetupTimetablePage> createState() => _SetupTimetablePageState();
}

class _SetupTimetablePageState extends State<SetupTimetablePage> {
  int _selectedDay = 1; // Monday

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SetupController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Timetable')),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What classes do you have each day?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a day and add which subjects you have. You can edit this later.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Day tabs
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedDay == index;
                        final classCount = controller.timetableEntries
                            .where((e) => e.dayOfWeek == index)
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              '${kShortDayNames[index]}${classCount > 0 ? ' ($classCount)' : ''}',
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedDay = index);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add entry card - simplified, auto-submit on dropdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Subject to Add',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: controller.subjects.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              _addEntry(controller, v);
                            }
                          },
                          hint: const Text('Select Subject'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Entries list for selected day
                  Row(
                    children: [
                      Text(
                        '${kDayNames[_selectedDay]} Classes',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Obx(() {
                        final count = controller.timetableEntries
                            .where((e) => e.dayOfWeek == _selectedDay)
                            .length;
                        return Text(
                          '$count class${count != 1 ? 'es' : ''}',
                          style: theme.textTheme.bodySmall,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Obx(() {
                      final entries = controller.timetableEntries
                          .where((e) => e.dayOfWeek == _selectedDay)
                          .toList();

                      if (entries.isEmpty) {
                        return Center(
                          child: Text(
                            'No classes added for ${kDayNames[_selectedDay]}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.book,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                controller.getSubjectName(entry.subjectId),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    controller.removeTimetableEntry(entry.id),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.completeSetup,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Finish Setup'),
                                  SizedBox(width: 8),
                                  Icon(Icons.check, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addEntry(SetupController controller, String subjectId) {
    controller.addTimetableEntry(
      subjectId: subjectId,
      dayOfWeek: _selectedDay,
    );

    // No reset needed - dropdown auto-clears
  }
}
