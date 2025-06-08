// lib/widgets/bottom_nav.dart
import 'package:crafted_well_mobile_app/main.dart';
import 'package:crafted_well_mobile_app/providers/app_provider.dart';
import 'package:crafted_well_mobile_app/screens/auth_screen.dart';
import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/screens/product_list_screen.dart';
import 'package:crafted_well_mobile_app/screens/survey_screen_1.dart';
import 'package:crafted_well_mobile_app/screens/survey_screen_2.dart';
import 'package:crafted_well_mobile_app/screens/survey_screen_3.dart';
import 'package:crafted_well_mobile_app/utils/navigation_state.dart';
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          selectedItemColor: Theme.of(context).textTheme.bodyLarge?.color,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Discover',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.face_retouching_natural),
              label: 'Skin Type',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.landscape_rounded),
              label: 'Lifestyle',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety_rounded),
              label: 'Allergies',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.person_rounded),
                  // Show different indicators based on state
                  if (NavigationState.hasCompletedSurvey &&
                      UserManager.isLoggedIn)
                    // Green dot: Perfect state
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  else if (!provider.isOnline)
                    // Orange dot: Offline mode available
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            _handleNavigation(context, index, provider);
          },
        );
      },
    );
  }

  void _handleNavigation(
      BuildContext context, int index, AppProvider provider) {
    switch (index) {
      case 0: // Discover/Home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomePage(
              currentThemeMode: Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              onThemeModeChanged: (ThemeMode mode) {
                final craftedWellState =
                    context.findAncestorStateOfType<State<CraftedWell>>();
                if (craftedWellState != null &&
                    craftedWellState is State<CraftedWell>) {
                  (craftedWellState as dynamic).toggleTheme(mode);
                }
              },
            ),
          ),
          (route) => false,
        );
        break;

      case 1: // Skin Type Survey
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SurveyScreen1(),
          ),
        );
        break;

      case 2: // Lifestyle Survey
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SurveyScreen2(),
          ),
        );
        break;

      case 3: // Allergies Survey
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SurveyScreen3(),
          ),
        );
        break;

      case 4: // Profile - Smart routing with offline support
        _handleProfileNavigation(context, provider);
        break;
    }
  }

  void _handleProfileNavigation(
      BuildContext context, AppProvider provider) async {
    // Force refresh UserManager state before checking
    await UserManager.forceRefresh();

    print('🔍 Profile navigation check:');
    print('   - Survey completed: ${NavigationState.hasCompletedSurvey}');
    print('   - User logged in: ${UserManager.isLoggedIn}');
    print('   - Online: ${provider.isOnline}');

    // NEW LOGIC: Allow offline access to demo products
    if (!provider.isOnline) {
      print('📴 Offline mode: Allowing profile access to demo products');
      _showOfflineProfileDialog(context);
      return;
    }

    // ONLINE LOGIC: Original requirements
    if (NavigationState.hasCompletedSurvey && UserManager.isLoggedIn) {
      // ✅ PERFECT: Survey completed AND logged in → Products
      print('✅ Perfect state: Navigating to products');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductListScreen(),
        ),
      );
    } else if (!NavigationState.hasCompletedSurvey && !UserManager.isLoggedIn) {
      // ❌ NEED BOTH: No survey, no login → Start survey first
      print('❌ Need both: Prompting to start survey');
      _showStartSurveyDialog(context);
    } else if (!NavigationState.hasCompletedSurvey && UserManager.isLoggedIn) {
      // ⚠️ LOGGED IN BUT NO SURVEY: → Complete survey
      print('⚠️ Logged in but no survey: Prompting survey');
      _showSurveyRequiredDialog(context);
    } else if (NavigationState.hasCompletedSurvey && !UserManager.isLoggedIn) {
      // ⚠️ SURVEY DONE BUT NOT LOGGED IN: → Login
      print('⚠️ Survey done but not logged in: Prompting login');
      _showLoginRequiredDialog(context);
    }
  }

  // NEW: Show offline profile access dialog
  void _showOfflineProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Offline Mode'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'re currently offline. You can:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Browse demo products without survey',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info, size: 16, color: Colors.blue.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Connect to internet for personalized products',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListScreen(),
                  ),
                );
              },
              child: Text('Browse Demo'),
            ),
          ],
        );
      },
    );
  }

  void _showStartSurveyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.assignment, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text('Start Your Journey'),
            ],
          ),
          content: Text(
            'Welcome! To access your personalized profile, please complete our skin survey first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurveyScreen1(),
                  ),
                );
              },
              child: Text('Start Survey'),
            ),
          ],
        );
      },
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.login, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text('Login Required'),
            ],
          ),
          content: Text(
            'Great! Your survey is complete. Please log in to view your personalized product recommendations.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(initialTabIndex: 0),
                  ),
                );
              },
              child: Text('Login Now'),
            ),
          ],
        );
      },
    );
  }

  void _showSurveyRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.assignment, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text('Survey Required'),
            ],
          ),
          content: Text(
            'To view personalized products, please complete our skin type survey first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurveyScreen1(),
                  ),
                );
              },
              child: Text('Start Survey'),
            ),
          ],
        );
      },
    );
  }
}
