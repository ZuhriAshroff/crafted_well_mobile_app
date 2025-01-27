import 'package:crafted_well_mobile_app/screens/auth_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mail),
          label: 'Contact',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Login',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 1:
            // Handle Contact navigation
            break;
          case 2:
            // Handle Login navigation
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
