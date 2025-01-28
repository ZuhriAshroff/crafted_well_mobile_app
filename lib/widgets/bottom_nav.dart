import 'package:crafted_well_mobile_app/main.dart';
import 'package:crafted_well_mobile_app/screens/auth_screen.dart';
import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/screens/survey_screen_1.dart';
import 'package:crafted_well_mobile_app/screens/survey_screen_2.dart';
import 'package:crafted_well_mobile_app/screens/survey_screen_3.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: Theme.of(context).textTheme.bodyLarge?.color,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Discover',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.face_retouching_natural),
          label: 'Skin Type',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.landscape_rounded),
          label: 'Lifestyle',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.health_and_safety_rounded),
          label: 'Allergies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Navigate to HomePage with theme settings
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(
                  currentThemeMode:
                      Theme.of(context).brightness == Brightness.dark
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
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SurveyScreen1(),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SurveyScreen2(),
              ),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SurveyScreen3(),
              ),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthScreen(initialTabIndex: 0),
              ),
            );
            break;
        }
      },
    );
  }
}
