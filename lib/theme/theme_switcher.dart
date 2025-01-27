// lib/widgets/theme_switcher.dart
import 'package:flutter/material.dart';

// Theme mode provider to manage theme state across the app
class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isSystem => _themeMode == ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// Modern theme switcher with system/light/dark options
class AdaptiveThemeSwitcher extends StatelessWidget {
  final ThemeModeNotifier themeModeNotifier;

  const AdaptiveThemeSwitcher({
    Key? key,
    required this.themeModeNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListenableBuilder(
          listenable: themeModeNotifier,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // System default option
                RadioListTile<ThemeMode>(
                  title: Row(
                    children: [
                      Icon(
                        Icons.brightness_auto,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      const Text('System'),
                    ],
                  ),
                  value: ThemeMode.system,
                  groupValue: themeModeNotifier.themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) themeModeNotifier.setThemeMode(value);
                  },
                ),
                // Light theme option
                RadioListTile<ThemeMode>(
                  title: Row(
                    children: [
                      Icon(
                        Icons.light_mode,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      const Text('Light'),
                    ],
                  ),
                  value: ThemeMode.light,
                  groupValue: themeModeNotifier.themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) themeModeNotifier.setThemeMode(value);
                  },
                ),
                // Dark theme option
                RadioListTile<ThemeMode>(
                  title: Row(
                    children: [
                      Icon(
                        Icons.dark_mode,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      const Text('Dark'),
                    ],
                  ),
                  value: ThemeMode.dark,
                  groupValue: themeModeNotifier.themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) themeModeNotifier.setThemeMode(value);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
