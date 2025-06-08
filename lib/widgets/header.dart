import 'package:crafted_well_mobile_app/screens/product_list_screen.dart';
import 'package:crafted_well_mobile_app/utils/navigation_state.dart';
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:crafted_well_mobile_app/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    // MODIFIED: Always allow access to products (demo or personalized)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListScreen(),
      ),
    );
  }

  void _handleProfileNavigation(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final bool hasPersonalizedAccess = provider.isOnline &&
            NavigationState.hasCompletedSurvey &&
            UserManager.isLoggedIn;

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
                                  Icons.account_circle,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'My Profile',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () =>
                                Future(() => _handleProfileNavigation(context)),
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Products',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        hasPersonalizedAccess
                                            ? 'Personalized recommendations'
                                            : 'Demo products available',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: hasPersonalizedAccess
                                              ? Colors.green[600]
                                              : Colors.orange[600],
                                        ),
                                      ),
                                    ],
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
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
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
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
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
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
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
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
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
      },
    );
  }
}
