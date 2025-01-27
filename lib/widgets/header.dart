import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  final ThemeMode? currentThemeMode;

  const HeaderSection({
    Key? key,
    this.onThemeModeChanged,
    this.currentThemeMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo on the left
          Image.asset(
            'assets/Crafted Well Logo (2).png',
            height: 100,
          ),

          // Theme toggle on the right
          if (onThemeModeChanged != null && currentThemeMode != null)
            PopupMenuButton<ThemeMode>(
              icon: Icon(
                currentThemeMode == ThemeMode.system
                    ? Icons.brightness_auto
                    : currentThemeMode == ThemeMode.light
                        ? Icons.light_mode
                        : Icons.dark_mode,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              onSelected: onThemeModeChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      Icon(Icons.brightness_auto),
                      SizedBox(width: 8),
                      Text('System'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      Icon(Icons.light_mode),
                      SizedBox(width: 8),
                      Text('Light'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode),
                      SizedBox(width: 8),
                      Text('Dark'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
