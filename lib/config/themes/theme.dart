import 'package:flutter/material.dart';

ThemeData carServiceTheme() {
  // Define the color palette
  const primaryColor = Color(
    0xFF1A237E,
  ); // Deep navy blue for a professional look
  const secondaryColor = Color(
    0xFFFFA000,
  ); // Amber for accents (e.g., buttons, highlights)
  const backgroundColor = Color(0xFFF5F5F5); // Light gray for background
  const surfaceColor = Colors.white; // White for cards and surfaces
  const errorColor = Color(0xFFD32F2F); // Red for errors
  const textColor = Color(0xFF212121); // Dark gray for primary text
  const secondaryTextColor = Color(
    0xFF757575,
  ); // Lighter gray for secondary text

  // Typography settings
  const fontFamily = 'Roboto'; // Clean, modern font
  final textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: 0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: secondaryTextColor,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white, // For buttons
    ),
  );

  return ThemeData(
    // Core theme settings
    primaryColor: primaryColor,
    colorScheme: ColorScheme(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white, // Text/icon color on primary
      onSecondary: Colors.black, // Text/icon color on secondary
      onSurface: textColor, // Text/icon color on surface
      onBackground: textColor, // Text/icon color on background
      onError: Colors.white, // Text/icon color on error
      brightness: Brightness.light, // Light theme
    ),
    scaffoldBackgroundColor: backgroundColor,

    // Typography
    fontFamily: fontFamily,
    textTheme: textTheme,

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white, // Icons and text
      elevation: 4,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
    ),

    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor, // Amber buttons
        foregroundColor: Colors.black, // Text/icon color
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // TextField theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
      hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 6, 5, 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Icon theme
    iconTheme: IconThemeData(color: textColor, size: 24),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 16,
    ),
  );
}
