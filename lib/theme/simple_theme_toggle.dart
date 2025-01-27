// Simple theme toggle for quick light/dark switching
import 'package:crafted_well_mobile_app/theme/theme_switcher.dart';
import 'package:flutter/material.dart';

class SimpleThemeToggle extends StatelessWidget {
  final ThemeModeNotifier themeModeNotifier;

  const SimpleThemeToggle({
    Key? key,
    required this.themeModeNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeModeNotifier,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return IconButton(
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            themeModeNotifier.setThemeMode(
              isDark ? ThemeMode.light : ThemeMode.dark,
            );
          },
          tooltip: 'Toggle theme',
        );
      },
    );
  }
}
