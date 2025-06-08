// lib/screens/survey_screen_1.dart
import 'dart:math';

import 'package:crafted_well_mobile_app/screens/survey_screen_2.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class SurveyScreen1 extends StatefulWidget {
  const SurveyScreen1({Key? key}) : super(key: key);

  @override
  State<SurveyScreen1> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen1>
    with SingleTickerProviderStateMixin {
  List<String> selectedSkinTypes = [];
  List<String> selectedConcerns = [];

  final skinTypes = ['DRY', 'OILY', 'COMBINATION', 'SENSITIVE'];
  final skinConcerns = ['BLEMISH', 'WRINKLE', 'SPOTS', 'SOOTHE'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Preselect a random skin type
    selectedSkinTypes = [skinTypes[Random().nextInt(skinTypes.length)]];
    // Preselect 2 random concerns
    final shuffledConcerns = List<String>.from(skinConcerns)..shuffle();
    selectedConcerns = shuffledConcerns.take(2).toList();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Header with Step Indicator
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Step 1 of 3 • Skin Analysis',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Enhanced Progress Indicator
                    const SizedBox(height: 20),
                    Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              gradient: index == 0
                                  ? LinearGradient(
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.7),
                                      ],
                                    )
                                  : null,
                              color: index == 0
                                  ? null
                                  : Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: index == 0
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Title
                    const SizedBox(height: 30),
                    Text(
                      'Discover Your Unique\nSkin Profile',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'TELL US ABOUT YOUR SKIN',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                    ),

                    // Selection Grid
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Skin Type Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Skin Type',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              ...skinTypes
                                  .map((type) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _ElegantSelectionButton(
                                          label: type,
                                          isSelected:
                                              selectedSkinTypes.contains(type),
                                          onTap: () {
                                            setState(() {
                                              if (selectedSkinTypes
                                                  .contains(type)) {
                                                selectedSkinTypes.remove(type);
                                              } else {
                                                selectedSkinTypes = [type];
                                              }
                                            });
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Skin Concerns Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Skin Concerns',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              ...skinConcerns
                                  .map((concern) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _ElegantSelectionButton(
                                          label: concern,
                                          isSelected: selectedConcerns
                                              .contains(concern),
                                          onTap: () {
                                            setState(() {
                                              if (selectedConcerns
                                                  .contains(concern)) {
                                                selectedConcerns
                                                    .remove(concern);
                                              } else {
                                                selectedConcerns.add(concern);
                                              }
                                            });
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Enhanced Next Button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SurveyScreen2(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    )),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class _ElegantSelectionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ElegantSelectionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              spreadRadius: isSelected ? 2 : 1,
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 3 : 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: isSelected ? 16 : 15,
                ),
          ),
        ),
      ),
    );
  }
}
