import 'package:flutter/material.dart';
import 'package:ysyw/config/theme/colors.dart';

final appTheme = ThemeData(
  // Primary color for the app (used in AppBar, buttons, etc.)
  primaryColor: AppColors.primary,

  // Background color for scaffolds
  scaffoldBackgroundColor: AppColors.background,

  // Color scheme for better control over theme colors
  colorScheme: ColorScheme(
    primary: AppColors.primary,
    primaryContainer: AppColors.lightPrimary, // Lighter shade for containers
    secondary: AppColors.gloss, // Used for accents like FABs
    secondaryContainer: AppColors.gloss.withOpacity(0.2),
    surface: AppColors.background,
    background: AppColors.background,
    error: Colors.red, // Default error color
    onPrimary: Colors.white, // Text/icon color on primary
    onSecondary: Colors.white, // Text/icon color on secondary
    onSurface: Colors.black, // Text/icon color on surface
    onBackground: Colors.black, // Text/icon color on background
    onError: Colors.white,
    brightness: Brightness.light, // Light theme
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white, // Text/icon color
  ),

  // Button theme (e.g., ElevatedButton)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),

      backgroundColor: AppColors.lightPrimary, // Button background
      foregroundColor: Colors.white, // Text/icon color
    ),
  ),

  // FloatingActionButton theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.gloss,
    foregroundColor: Colors.white,
  ),

  // Text theme (optional, for consistency)
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
    headlineSmall: TextStyle(color: AppColors.primary),
  ),
);
