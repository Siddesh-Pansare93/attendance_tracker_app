import 'package:flutter/material.dart';

/// Modern SaaS-inspired theme configuration with light and dark modes
/// Inspired by Twenty.com CRM - clean, minimal, professional
class AppTheme {
  AppTheme._();

  // ============== LIGHT THEME COLORS ==============

  // Backgrounds
  static const Color bgPrimary = Color(0xFFFAFAFA); // #FAFAFA
  static const Color bgSecondary = Color(0xFFF4F4F5); // #F4F4F5
  static const Color surfaceDefault = Color(0xFFFFFFFF); // #FFFFFF
  static const Color surfaceElevated = Color(0xFFFCFCFC); // #FCFCFC

  // Borders
  static const Color borderSubtle = Color(0xFFE4E4E7); // #E4E4E7
  static const Color borderStrong = Color(0xFFD4D4D8); // #D4D4D8

  // Text
  static const Color textPrimary = Color(0xFF18181B); // #18181B
  static const Color textSecondary = Color(0xFF3F3F46); // #3F3F46
  static const Color textMuted = Color(0xFF71717A); // #71717A
  static const Color textDisabled = Color(0xFFA1A1AA); // #A1A1AA

  // Primary (Indigo/Purple)
  static const Color primaryColor = Color(0xFF4F46E5); // #4F46E5
  static const Color primaryHover = Color(0xFF6366F1); // #6366F1
  static const Color primarySoft = Color(0xFFE0E7FF); // #E0E7FF

  // Status Colors (Semantic)
  static const Color safeColor = Color(0xFF16A34A); // #16A34A - Green
  static const Color safeSoft = Color(0xFFDCFCE7); // #DCFCE7

  static const Color warningColor = Color(0xFFCA8A04); // #CA8A04 - Amber
  static const Color warningSoft = Color(0xFFFEF3C7); // #FEF3C7

  static const Color criticalColor = Color(0xFFDC2626); // #DC2626 - Red
  static const Color criticalSoft = Color(0xFFFEE2E2); // #FEE2E2

  static const Color infoColor = Color(0xFF0284C7); // #0284C7 - Blue
  static const Color infoSoft = Color(0xFFE0F2FE); // #E0F2FE

  // Shadow
  static const Color shadowSoft = Color.fromARGB(
    15,
    0,
    0,
    0,
  ); // rgba(0,0,0,0.06)

  // ============== Light Theme ==============
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryColor,
      onSecondary: Colors.white,
      error: criticalColor,
      onError: Colors.white,
      surface: surfaceDefault,
      onSurface: textPrimary,
      outline: borderSubtle,
      outlineVariant: borderStrong,
    ),
    scaffoldBackgroundColor: bgPrimary,
    fontFamily: 'Inter',

    // AppBar - Minimal, clean
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.4,
      ),
    ),

    // Cards - Subtle borders, no shadows
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: borderSubtle),
      ),
      color: surfaceDefault,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    // Elevated Button - Primary solid color
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Outlined Button - Subtle border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: borderStrong),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        foregroundColor: textPrimary,
      ),
    ),

    // Text Button - Minimal
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        foregroundColor: primaryColor,
      ),
    ),

    // Input Decoration - Subtle
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: criticalColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: criticalColor, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
    ),

    // Navigation Bar - Minimal bottom nav
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: surfaceDefault,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 24);
        }
        return const IconThemeData(color: textMuted, size: 24);
      }),
    ),

    // FAB - Subtle but visible
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Chips - Subtle background
    chipTheme: ChipThemeData(
      backgroundColor: bgSecondary,
      selectedColor: primarySoft,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: borderSubtle),
      ),
      side: const BorderSide(color: borderSubtle),
    ),

    // Divider - Subtle
    dividerTheme: const DividerThemeData(
      color: borderSubtle,
      thickness: 1,
      space: 1,
    ),

    // SnackBar - Modern
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    ),
  );

  // ============== DARK THEME COLORS ==============

  // Backgrounds (Dark)
  static const Color darkBgPrimary = Color(0xFF121218); // #121218
  static const Color darkBgSecondary = Color(0xFF1B1B20); // #1B1B20
  static const Color darkSurfaceDefault = Color(0xFF1E1E2E); // #1E1E2E
  static const Color darkSurfaceElevated = Color(0xFF2A2A3C); // #2A2A3C

  // Borders (Dark)
  static const Color darkBorderSubtle = Color(0xFF3B3B4A); // #3B3B4A
  static const Color darkBorderStrong = Color(0xFF4B4B5A); // #4B4B5A

  // Text (Dark)
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // #FAFAFA
  static const Color darkTextSecondary = Color(0xFFB0B0B8); // #B0B0B8
  static const Color darkTextMuted = Color(0xFF7F7F88); // #7F7F88
  static const Color darkTextDisabled = Color(0xFF5B5B64); // #5B5B64

  // ============== Dark Theme ==============
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryColor,
      onSecondary: Colors.white,
      error: criticalColor,
      onError: Colors.white,
      surface: darkSurfaceDefault,
      onSurface: darkTextPrimary,
      outline: darkBorderSubtle,
      outlineVariant: darkBorderStrong,
    ),
    scaffoldBackgroundColor: darkBgPrimary,
    fontFamily: 'Inter',

    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: darkTextPrimary,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -0.4,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: darkBorderSubtle),
      ),
      color: darkSurfaceDefault,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: darkBorderStrong),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        foregroundColor: darkTextPrimary,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        foregroundColor: primaryHover,
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: criticalColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: criticalColor, width: 1.5),
      ),
      hintStyle: const TextStyle(color: darkTextMuted, fontSize: 14),
      labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: darkSurfaceDefault,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: darkTextMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 24);
        }
        return const IconThemeData(color: darkTextMuted, size: 24);
      }),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: darkBgSecondary,
      selectedColor: primaryColor.withValues(alpha: 0.2),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: darkBorderSubtle),
      ),
      side: const BorderSide(color: darkBorderSubtle),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: darkBorderSubtle,
      thickness: 1,
      space: 1,
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: darkBgSecondary,
      contentTextStyle: const TextStyle(color: darkTextPrimary, fontSize: 14),
    ),
  );

  /// Get status color based on attendance percentage
  static Color getStatusColor(double percentage, double threshold) {
    if (percentage >= threshold + 10) {
      return safeColor;
    } else if (percentage >= threshold) {
      return warningColor;
    } else {
      return criticalColor;
    }
  }

  /// Get status text based on attendance percentage
  static String getStatusText(double percentage, double threshold) {
    if (percentage >= threshold + 10) {
      return 'Safe';
    } else if (percentage >= threshold) {
      return 'At Risk';
    } else {
      return 'Critical';
    }
  }

  /// Get soft background color for status
  static Color getStatusSoftColor(double percentage, double threshold) {
    if (percentage >= threshold + 10) {
      return safeSoft;
    } else if (percentage >= threshold) {
      return warningSoft;
    } else {
      return criticalSoft;
    }
  }
}
