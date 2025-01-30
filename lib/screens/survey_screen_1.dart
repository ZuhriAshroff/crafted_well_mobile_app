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

class _SurveyScreenState extends State<SurveyScreen1> {
  List<String> selectedSkinTypes = [];
  List<String> selectedConcerns = [];

  final skinTypes = ['DRY', 'OILY', 'COMBINATION', 'SENSITIVE'];
  final skinConcerns = ['BLEMISH', 'WRINKLE', 'SPOTS', 'SOOTHE'];

  @override
  void initState() {
    super.initState();
    // Preselect a random skin type
    selectedSkinTypes = [skinTypes[Random().nextInt(skinTypes.length)]];
    // Preselect 2 random concerns
    final shuffledConcerns = List<String>.from(skinConcerns)..shuffle();
    selectedConcerns = shuffledConcerns.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.getGradientBackground(context),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Progress Indicator
                  const SizedBox(height: 20),
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title
                  const SizedBox(height: 30),
                  Text(
                    'Discover Your Unique\nSkin Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                                      child: _SelectionButton(
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
                                      child: _SelectionButton(
                                        label: concern,
                                        isSelected:
                                            selectedConcerns.contains(concern),
                                        onTap: () {
                                          setState(() {
                                            if (selectedConcerns
                                                .contains(concern)) {
                                              selectedConcerns.remove(concern);
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

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SurveyScreen2(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
                                ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).textTheme.titleMedium?.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ),
      ),
    );
  }
}
