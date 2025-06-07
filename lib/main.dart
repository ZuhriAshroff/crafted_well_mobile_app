import 'package:crafted_well_mobile_app/screens/auth_screen.dart';
import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/providers/app_provider.dart'; // NEW
import 'package:provider/provider.dart'; // NEW
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
    return ChangeNotifierProvider(
      // NEW - Wrap with Provider
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'Skincare App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: AuthScreen(),
      ),
    );
  }
}
