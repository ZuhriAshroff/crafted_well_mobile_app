// lib/screens/homepage.dart
import 'package:crafted_well_mobile_app/screens/survey_screen_1.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/widgets/bottom_nav.dart';
import 'package:crafted_well_mobile_app/widgets/header.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const HomePage({
    Key? key,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: AppTheme.getGradientBackground(context),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Updated HeaderSection with theme toggle
                  HeaderSection(
                    onThemeModeChanged: onThemeModeChanged,
                    currentThemeMode: currentThemeMode,
                  ),

                  const SizedBox(height: 20),

                  // Main heading
                  Text(
                    'Custom Skincare,\nPowered by Your\nAnswers',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),

                  const SizedBox(height: 24),

                  // Description text
                  Text(
                    'We listen to your unique skin story through a comprehensive survey, crafting precise wellness products that match your exact skin type, concerns, and lifestyle. Personalized skincare, tailored to you—because your skin deserves a solution as individual as you are.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 32),

                  // Action button with animation
                  Center(
                    child: Hero(
                      tag: 'blend_button',
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SurveyScreen1(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              isDarkMode ? Colors.black : Colors.white,
                          backgroundColor:
                              isDarkMode ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Design My Unique Blend'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Circular image with animation
                  Center(
                    child: _buildCircularProductDisplay(isDarkMode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildCircularProductDisplay(bool isDarkMode) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDarkMode ? Colors.white24 : Colors.black12,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
              );
            },
          ),
          Image.asset(
            'assets/Dark Glass Bottle Mocha 1.png',
            width: 900,
            height: 900,
          ),
        ],
      ),
    );
  }
}
