import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CraftedWell());
}

class CraftedWell extends StatelessWidget {
  const CraftedWell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skincare App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
