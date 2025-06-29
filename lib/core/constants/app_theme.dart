import 'package:expense/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<bool>((ref) => false); // false = light

class AppTheme {
  // Consistent font sizes for the entire app
  static const double fontSizeXs = 10.0; // Extra small (labels, badges)
  static const double fontSizeSm = 12.0; // Small (captions, secondary text)
  static const double fontSizeMd = 14.0; // Medium (body text)
  static const double fontSizeLg = 16.0; // Large (subheadings, buttons)
  static const double fontSizeXl = 18.0; // Extra large (headings)
  static const double fontSizeXxl = 20.0; // 2X large (main headings)
  static const double fontSizeXxxl = 24.0; // 3X large (page titles)

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.teal,
    ),
    textTheme: const TextTheme(
      // Headlines
      displayLarge: TextStyle(
        fontSize: fontSizeXxxl,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXxl,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: fontSizeXl,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      // Headlines
      headlineLarge: TextStyle(
        fontSize: fontSizeXl,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headlineSmall: TextStyle(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      // Titles
      titleLarge: TextStyle(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      titleSmall: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      // Body
      bodyLarge: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      // Labels
      labelLarge: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      labelMedium: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      labelSmall: TextStyle(
        fontSize: fontSizeXs,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
    ),
    bottomAppBarTheme: BottomAppBarTheme(color: Constants.blackColor),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Constants.whiteColor,
      selectedItemColor: Constants.blackColor,
      unselectedItemColor: Constants.gray,
    ),
    textTheme: const TextTheme(
      // Headlines
      displayLarge: TextStyle(
        fontSize: fontSizeXxxl,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXxl,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: fontSizeXl,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      // Headlines
      headlineLarge: TextStyle(
        fontSize: fontSizeXl,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      // Titles
      titleLarge: TextStyle(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      // Body
      bodyLarge: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      // Labels
      labelLarge: TextStyle(
        fontSize: fontSizeMd,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontSize: fontSizeSm,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelSmall: TextStyle(
        fontSize: fontSizeXs,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
  );
}
