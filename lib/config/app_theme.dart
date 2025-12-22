import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF0F4F8);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF111A22);
  static const Color darkCardBackground = Color(0xFF16202C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF1E2A3C);

  // Common Colors
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color iconBlue = Color(0xFF42A5F5);
  static const Color iconGreen = Color(0xFF66BB6A);
  static const Color iconPurple = Color(0xFFAB47BC);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: accentBlue,
    cardColor: lightCardBackground,
    dividerColor: lightBorder,
    colorScheme: const ColorScheme.light(
      primary: accentBlue,
      secondary: accentBlue,
      surface: lightCardBackground,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.w300,
        color: lightTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: accentBlue,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: lightTextSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: lightTextSecondary),
    ),
    iconTheme: const IconThemeData(color: lightTextPrimary),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: accentBlue,
    cardColor: darkCardBackground,
    dividerColor: darkBorder,
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentBlue,
      surface: darkCardBackground,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.w300,
        color: darkTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: accentBlue,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: darkTextSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: darkTextSecondary),
    ),
    iconTheme: const IconThemeData(color: darkTextPrimary),
  );
}
