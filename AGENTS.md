# Smart Attendance App - Developer & Agent Guidelines

## Build, Test & Lint Commands

### Flutter Commands
```bash
# Clean build artifacts
flutter clean

# Get/upgrade dependencies  
flutter pub get

# Run the app (debug)
flutter run

# Run the app (release)
flutter run --release

# Build APK
flutter build apk --release

# Static analysis
flutter analyze

# Format code
flutter format lib/

# Lint specific file
flutter analyze lib/features/dashboard/pages/dashboard_page.dart
```

### Testing
```bash
# Run all tests
flutter test

# Run tests from a single file
flutter test test/features/attendance/attendance_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests in verbose mode
flutter test --verbose
```

---

## Code Style Guidelines

### Import Organization (STRICT ORDER)
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:ui';

// 2. Package imports (alphabetical)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 3. Relative imports (alphabetical)
import 'package:smart_attendance_app/core/theme/app_theme.dart';
import 'package:smart_attendance_app/features/dashboard/controller/dashboard_controller.dart';
```

### Formatting & Structure
- **Line length**: 80 characters (soft limit), 120 (hard limit)
- **Indentation**: 2 spaces (NOT tabs)
- **Trailing commas**: Always add for multi-line lists/args
- **Spacing**: 1 blank line between methods/properties

### Naming Conventions
```dart
// Classes: PascalCase
class DashboardPage { }
class AttendanceIndicator { }

// Functions/Methods/Variables: camelCase
void loadTodayClasses() { }
final String userName = "John";
final List<String> subjectNames = [];

// Constants: camelCase (in app_constants.dart)
const double attendanceThreshold = 75.0;
const List<String> kShortDayNames = ['Sun', 'Mon', ...];

// Private members: leadingUnderscore
void _buildLayout() { }
final _controller = TextEditingController();

// File names: snake_case
dashboard_controller.dart
app_theme.dart
```

### Type Safety & Null Safety
```dart
// ALWAYS use type annotations
final String name = "John";  // ✅ Good
final name = "John";         // ❌ Avoid

// Prefer non-nullable types
String getUserName() => "John";  // ✅ Good
String? getUserName() => null;   // ❌ Only if nullable

// Use ?? for null coalescing
final value = controller.data ?? 'default';

// Use ! sparingly (only if 100% sure it's not null)
final controller = Get.find<DashboardController>()!;
```

### Error Handling
```dart
// Use try-catch for async operations
try {
  await controller.loadData();
} catch (e) {
  print('Error loading data: $e');
  // Show snackbar/dialog to user
}

// Use GetX error handling where available
Obx(() {
  if (controller.error.isNotEmpty) {
    return Center(child: Text('Error: ${controller.error}'));
  }
  return YourWidget();
});
```

---

## UI/Design System Rules (STRICT)

**Rules:**
- Use neutral colors for 90% of the UI
- Use Primary color (`#4F46E5`) ONLY for active states or important actions
- Never use pure black (`#000000`) or pure white (`#FFFFFF`)
- Attendance status colors are semantic-only (present/absent/late/leave)
- Prefer borders over heavy shadows
- Avoid high saturation and gradients

### Color Usage
```dart
// Background/Surfaces (90%)
AppTheme.bgPrimary          // Light gray bg
AppTheme.bgSecondary        // Slightly darker
AppTheme.surfaceDefault     // White cards
AppTheme.borderDefault      // Light borders
AppTheme.borderStrong       // Dividers

// Text (semantic)
AppTheme.textPrimary        // #18181B - Headings
AppTheme.textSecondary      // #3F3F46 - Labels
AppTheme.textMuted          // #71717A - Hints

// Accent (use sparingly!)
AppTheme.primaryColor       // #4F46E5 - Only for CTAs
AppTheme.primarySoft        // #E0E7FF - Badges

// Status (semantic only)
AppTheme.safeColor          // Green - Present
AppTheme.warningColor       // Amber - Late
AppTheme.criticalColor      // Red - Absent
AppTheme.infoColor          // Blue - Leave
```

### Widget Styling
```dart
// Cards: Use borders, not shadows
Container(
  decoration: BoxDecoration(
    color: AppTheme.surfaceDefault,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppTheme.borderDefault),
  ),
)

// Buttons: Solid colors only
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    elevation: 0,
  ),
)

// Progress bars: Use appTheme status colors
LinearProgressIndicator(
  backgroundColor: AppTheme.borderDefault,
  valueColor: AlwaysStoppedAnimation(AppTheme.safeColor),
)
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry, Hive setup, DI
├── core/
│   ├── bindings/                      # GetX dependency injection
│   ├── constants/app_constants.dart
│   ├── repositories/                  # Data abstraction layer
│   │   ├── impl/                      # Hive implementations
│   │   ├── subject_repository.dart
│   │   └── attendance_repository.dart
│   ├── routes/app_routes.dart
│   ├── services/
│   ├── theme/app_theme.dart           # 💎 Master theme file
│   └── utils/attendance_utils.dart
├── common/widgets/                    # Reusable components
│   ├── attendance_indicator.dart
│   ├── empty_state.dart
│   └── [other shared widgets]
└── features/
    ├── attendance/                    # Subject & attendance
    │   ├── pages/
    │   ├── controller/attendance_controller.dart
    │   └── data/model/subject_model.dart
    ├── dashboard/                     # Home page
    ├── timetable/                     # Weekly schedule
    ├── calendar/                      # Attendance calendar
    ├── settings/
    └── setup/                         # Onboarding
```

---

## Key Patterns & Best Practices

### GetX State Management
```dart
// Define reactive variable
final count = 0.obs;

// Watch for changes
ever(count, (value) => print('Count: $value'));

// Update UI reactively
Obx(() => Text('${controller.count}'));
```

### Repository Pattern
```dart
// Use abstractions, not concretions
final repo = Get.find<AttendanceRepository>();
final records = await repo.getRecords(date);
```

### Clean Architecture
- **Presentation**: Pages + Controllers (GetX)
- **Domain**: Models + Use Cases
- **Data**: Repositories + Local Storage (Hive)

---

## Testing Guidelines

```dart
// Follow arrange-act-assert pattern
test('loadTodayClasses returns classes for today', () {
  // Arrange
  final controller = DashboardController();
  
  // Act
  controller.loadTodayClasses();
  
  // Assert
  expect(controller.todayClasses.isNotEmpty, true);
});
```

---

## Git & Code Review Checklist

- [ ] Code follows naming conventions
- [ ] No unused imports or variables
- [ ] Null safety enforced (no ! unless necessary)
- [ ] UI follows minimalist design system
- [ ] No gradients or excessive shadows
- [ ] Error handling implemented
- [ ] Tests added for new features
- [ ] Commit message is clear and descriptive
