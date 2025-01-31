// lib/screens/homepage.dart
import 'package:crafted_well_mobile_app/screens/survey_screen_1.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/widgets/bottom_nav.dart';
import 'package:crafted_well_mobile_app/widgets/header.dart';
import 'package:crafted_well_mobile_app/widgets/preloader_widget.dart';
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: Container(
        decoration: AppTheme.getGradientBackground(context),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Updated HeaderSection with theme toggle
                          HeaderSection(
                            onThemeModeChanged: onThemeModeChanged,
                            currentThemeMode: currentThemeMode,
                          ),

                          const SizedBox(height: 20),

                          // Main content wrapped in an Expanded to use remaining space
                          Expanded(
                            child: isLandscape
                                ? _buildLandscapeLayout(context, isDarkMode)
                                : _buildPortraitLayout(context, isDarkMode),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Custom Skincare,\nPowered by Your\nAnswers',
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'We listen to your unique skin story through a comprehensive survey, crafting precise wellness products that match your exact skin type, concerns, and lifestyle. Personalized skincare, tailored to you—because your skin deserves a solution as individual as you are.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildActionButton(context, isDarkMode),
        const SizedBox(height: 40),
        _buildCircularProductDisplay(isDarkMode),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Custom Skincare,\nPowered by Your\nAnswers',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'We listen to your unique skin story through a comprehensive survey, crafting precise wellness products that match your exact skin type, concerns, and lifestyle.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildActionButton(context, isDarkMode),
            ],
          ),
        ),
        Expanded(
          child: _buildCircularProductDisplay(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool isDarkMode) {
    return Hero(
      tag: 'blend_button',
      child: ElevatedButton(
        onPressed: () async {
          // Make onPressed async
          // Show loading screen
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) {
                return const SurveyLoader(
                  message: "Preparing your personalized survey...",
                );
              },
            ),
          );

          // Add a small delay to show the animation
          await Future.delayed(const Duration(milliseconds: 1500));

          // Remove the loader and navigate to survey
          if (context.mounted) {
            // Check if context is still valid
            Navigator.of(context).pop(); // Remove loader
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SurveyScreen1(),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
          backgroundColor: isDarkMode ? Colors.white : Colors.black87,
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
            'assets/images/Dark Glass Bottle Mocha 1.png',
            width: 900,
            height: 900,
          ),
        ],
      ),
    );
  }
}
