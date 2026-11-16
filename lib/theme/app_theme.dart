import 'package:flutter/material.dart';

const Color primaryTeal = Color(0xFF087F8C);
const Color lightTeal = Color(0xFFE6F5F5);
const Color darkText = Color(0xFF1F2937);
const Color secondaryText = Color(0xFF6B7280);
const Color pageBackground = Color(0xFFF7F9FA);
const Color successGreen = Color(0xFF10B981);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: pageBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: pageBackground,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
