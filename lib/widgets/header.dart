import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Image.asset(
          'assets/Crafted Well Logo (2).png',
          height: 100,
        ),

        Row(
          children: [
            // Contact Us Button
            TextButton(
              onPressed: () {},
              child: Text(
                'Contact Us',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Login Button
            TextButton(
              onPressed: () {},
              child: Text(
                'Login',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
