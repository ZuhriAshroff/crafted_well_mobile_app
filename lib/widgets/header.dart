import 'package:crafted_well_mobile_app/screens/product_list_screen.dart';
import 'package:crafted_well_mobile_app/utils/navigation_state.dart';
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

  void _handleLogout(BuildContext context) {
    UserManager.logout();
    NavigationState.resetState();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _handleProductNavigation(BuildContext context) {
    if (NavigationState.hasCompletedSurvey) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductListScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the survey first to view products'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
            'assets/images/Crafted Well Logo (2).png',
            height: 100,
          ),
          Row(
            children: [
              if (UserManager.isLoggedIn)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.person,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Products',
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        onTap: () =>
                            Future(() => _handleProductNavigation(context)),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Future(() => _handleLogout(context)),
                      ),
                    ],
                  ),
                ),

              // Theme toggle
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
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'System',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
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
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Light',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
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
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dark',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
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
      ),
    );
  }
}
