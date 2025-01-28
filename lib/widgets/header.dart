import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HeaderSection({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
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
            Row(
              children: [
                if (UserManager.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.person,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),

                // Theme toggle on the right
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
                    PopupMenuItem(
                      value: ThemeMode.system,
                      child: Row(
                        children: [
                          Icon(
                            Icons.brightness_auto,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'System',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: ThemeMode.light,
                      child: Row(
                        children: [
                          Icon(
                            Icons.light_mode,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Light',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: ThemeMode.dark,
                      child: Row(
                        children: [
                          Icon(
                            Icons.dark_mode,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dark',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
