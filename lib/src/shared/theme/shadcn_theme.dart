import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color sage = Color(0xFF7A9A65);
  static const Color background = Color(0xFFF8F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkGreen = Color(0xFF1C3A2A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textCaption = Color(0xFF9CA3AF);
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFFF8E7);
  static const Color amberVeryLight = Color(0xFFFFFBF0);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF0F0EE);
  static const Color destructive = Color(0xFFEF4444);

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x09000000),
    blurRadius: 12,
    offset: Offset(0, 2),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: sage,
        onPrimary: surface,
        secondary: sage,
        onSecondary: surface,
        error: destructive,
        onError: surface,
        surface: surface,
        onSurface: darkGreen,
        outline: border,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 48, fontWeight: FontWeight.bold, color: darkGreen),
        displayMedium: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.bold, color: darkGreen),
        displaySmall: GoogleFonts.playfairDisplay(fontSize: 30, fontWeight: FontWeight.bold, color: darkGreen),
        headlineLarge: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.normal, color: darkGreen),
        headlineMedium: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: darkGreen),
        headlineSmall: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: darkGreen),
        titleLarge: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.normal, color: darkGreen),
        titleMedium: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.normal, color: darkGreen),
        titleSmall: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.normal, color: darkGreen),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: darkGreen, height: 1.7),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkGreen, height: 1.5),
        bodySmall: GoogleFonts.inter(fontSize: 13, color: textMuted, height: 1.5),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: darkGreen),
        labelMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: darkGreen),
        labelSmall: GoogleFonts.inter(fontSize: 12, color: textCaption),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkGreen),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkGreen,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sage,
          foregroundColor: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGreen,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: sage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: destructive),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textCaption),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return sage;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(surface),
        side: const BorderSide(color: sage, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1, space: 0),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: sage,
        foregroundColor: surface,
        elevation: 2,
      ),
    );
  }
}
