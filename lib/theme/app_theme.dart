import 'package:flutter/material.dart';

class AppTheme {
  // Colors based on wireframes
  static const Color primaryBlue = Color(0xFF1E3A5F);
  static const Color lightBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0F1E3A);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFE8E8E8);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF27AE60);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static ThemeData getTheme(
      {required bool isDarkMode, required double fontSize}) {
    return isDarkMode ? _darkTheme(fontSize) : _lightTheme(fontSize);
  }

  static ThemeData _lightTheme(double fontSize) => ThemeData(
        useMaterial3:
            false, // Set to false to ensure Material Icons work properly
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: lightBlue,
          error: errorRed,
          surface: Colors.white,
          background: backgroundColor,
          onSurface:
              textPrimary, // Text color on surfaces (including input fields)
          onBackground: textPrimary, // Text color on background
          onPrimary: Colors.white, // Text color on primary color
          onSecondary: Colors.white, // Text color on secondary color
          onError: Colors.white, // Text color on error color
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: lightBlue, width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          labelStyle: const TextStyle(color: textPrimary),
          helperStyle: const TextStyle(color: textSecondary),
          errorStyle: const TextStyle(color: errorRed),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: lightBlue,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSize, color: textPrimary),
          bodyMedium: TextStyle(fontSize: fontSize - 2, color: textPrimary),
          bodySmall: TextStyle(fontSize: fontSize - 4, color: textSecondary),
          titleLarge: TextStyle(
              fontSize: fontSize + 6,
              fontWeight: FontWeight.bold,
              color: textPrimary),
          titleMedium: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: textPrimary),
          titleSmall: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
              color: textPrimary),
          displayLarge: TextStyle(fontSize: fontSize + 8, color: textPrimary),
          displayMedium: TextStyle(fontSize: fontSize + 6, color: textPrimary),
          displaySmall: TextStyle(fontSize: fontSize + 4, color: textPrimary),
          labelLarge: TextStyle(fontSize: fontSize, color: textPrimary),
          labelMedium: TextStyle(fontSize: fontSize - 2, color: textPrimary),
          labelSmall: TextStyle(fontSize: fontSize - 4, color: textSecondary),
        ),
      );

  static ThemeData _darkTheme(double fontSize) => ThemeData(
        useMaterial3:
            false, // Set to false to ensure Material Icons work properly
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: lightBlue,
          secondary: lightBlue,
          error: errorRed,
          surface: darkCardBackground,
        ),
        scaffoldBackgroundColor: darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkCardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: lightBlue, width: 2),
          ),
          hintStyle: const TextStyle(color: darkTextSecondary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: lightBlue,
          ),
        ),
        cardTheme: CardThemeData(
          color: darkCardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSize, color: darkTextPrimary),
          bodyMedium: TextStyle(fontSize: fontSize - 2, color: darkTextPrimary),
          bodySmall:
              TextStyle(fontSize: fontSize - 4, color: darkTextSecondary),
          titleLarge: TextStyle(
              fontSize: fontSize + 6,
              fontWeight: FontWeight.bold,
              color: darkTextPrimary),
          titleMedium: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: darkTextPrimary),
          titleSmall: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
              color: darkTextPrimary),
        ),
      );
}
