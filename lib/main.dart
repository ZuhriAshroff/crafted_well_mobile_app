// lib/main.dart
import 'package:crafted_well_mobile_app/screens/auth_screen.dart';
import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/providers/app_provider.dart';
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize user manager
  await UserManager.initialize();

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
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'Crafted Well Skincare',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: AuthScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
