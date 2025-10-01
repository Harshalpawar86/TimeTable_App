import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final AppTheme _instance = AppTheme._internal();
  AppTheme._internal();
  factory AppTheme() {
    return _instance;
  }

  final ThemeData lightTheme = ThemeData(
    timePickerTheme: TimePickerThemeData(
      dayPeriodColor: const Color(0xFF90CAF9),
    ),
    primaryColor: const Color(0xFF1976D2),
    scaffoldBackgroundColor: const Color(0xFFF5F9FF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1976D2),
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.black,
      error: Color(0xFFD32F2F),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF212121),
      surfaceContainer: Color(0xFFF5F9FF),
    ),

    textTheme: GoogleFonts.poppinsTextTheme(),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1976D2),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
    ),
  );

  final ThemeData darkTheme = ThemeData(
    timePickerTheme: TimePickerThemeData(
      dayPeriodColor: const Color(0xFF90CAF9),
    ),
    primaryColor: const Color(0xFF90CAF9),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      onPrimary: Color(0xFF0D47A1),
      secondary: Color(0xFF2C2C2C),
      onSecondary: Colors.white,
      error: Color(0xFFCF6679),
      onError: Color(0xFF000000),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE0E0E0),
      surfaceContainer: Color(0xFF121212),
    ),

    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF90CAF9),
      foregroundColor: Color(0xFF0D47A1),
    ),
  );
}
