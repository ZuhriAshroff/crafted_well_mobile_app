// lib/themes/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Define gradient colors
  static const lightGradient = [Color(0xFFFFBFE3), Color(0xFFFFE9BE)];
  static const darkGradient = [Color(0xFF2C2C2C), Color(0xFF1A1A1A)];

  // Define text styles
  static final TextStyle mainHeading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    fontFamily: 'Roboto',
  );

  static final TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.5,
    fontFamily: 'Roboto',
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightGradient[0],
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        // Define the text theme using our custom styles
        displayLarge: mainHeading.copyWith(color: Colors.black87),
        bodyLarge: bodyText.copyWith(color: Colors.black54),
      ),
      // Add other theme configurations as needed
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkGradient[0],
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        // Define the text theme using our custom styles
        displayLarge: mainHeading.copyWith(color: Colors.white),
        bodyLarge: bodyText.copyWith(color: Colors.white70),
      ),
      // Add other theme configurations as needed
    );
  }

  // Gradient background getter for easy reuse
  static BoxDecoration getGradientBackground(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode ? darkGradient : lightGradient,
      ),
    );
  }
}
