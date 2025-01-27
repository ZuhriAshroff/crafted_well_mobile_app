// lib/main.dart
import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CraftedWell());
}

class CraftedWell extends StatefulWidget {
  const CraftedWell({Key? key}) : super(key: key);

  @override
  State<CraftedWell> createState() => _CraftedWellState();
}

class _CraftedWellState extends State<CraftedWell> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skincare App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomePage(
        onThemeModeChanged: toggleTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}
