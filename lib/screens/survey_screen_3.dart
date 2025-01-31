import 'dart:math';

import 'package:crafted_well_mobile_app/main.dart';
import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/screens/product_list_screen.dart';
import 'package:crafted_well_mobile_app/screens/thank_you_screen.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/utils/navigation_state.dart';
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:crafted_well_mobile_app/widgets/bottom_nav.dart';
import 'package:crafted_well_mobile_app/widgets/popup_widget.dart';
import 'package:flutter/material.dart';

class SurveyScreen3 extends StatefulWidget {
  const SurveyScreen3({Key? key}) : super(key: key);

  @override
  State<SurveyScreen3> createState() => _SurveyScreen3State();
}

class _SurveyScreen3State extends State<SurveyScreen3> {
  final List<String> selectedAllergies = [];

  final Map<String, Map<String, dynamic>> allergyCategories = {
    'Preservatives': {
      'description': 'Common preservatives (Parabens, Phenoxyethanol)',
      'avoid': ['Parabens', 'Phenoxyethanol', 'Methylisothiazolinone'],
      'alternatives': ['Sodium benzoate', 'Potassium sorbate']
    },
    'Fragrances': {
      'description': 'Natural or synthetic fragrances',
      'avoid': ['Fragrance', 'Parfum', 'Essential oils'],
      'alternatives': ['Fragrance-free compounds']
    },
    'Sulfates': {
      'description': 'Cleansing agents (SLS, SLES)',
      'avoid': ['Sodium lauryl sulfate', 'Sodium laureth sulfate'],
      'alternatives': ['Gentle surfactants']
    },
    'Alcohol': {
      'description': 'Drying alcohols (Ethanol, SD Alcohol)',
      'avoid': ['Denatured alcohol', 'Ethanol'],
      'alternatives': ['Cetyl alcohol', 'Stearyl alcohol']
    },
    'Silicones': {
      'description': 'Dimethicone and similar compounds',
      'avoid': ['Dimethicone', 'Cyclopentasiloxane'],
      'alternatives': ['Natural oils', 'Squalane']
    },
    'Retinoids': {
      'description': 'Vitamin A derivatives',
      'avoid': ['Retinol', 'Retinyl palmitate'],
      'alternatives': ['Bakuchiol', 'Peptides']
    },
    'Vitamin C': {
      'description': 'Ascorbic acid and derivatives',
      'avoid': ['Ascorbic acid', 'Vitamin C'],
      'alternatives': ['Niacinamide', 'Alpha arbutin']
    },
    'Nuts': {
      'description': 'Nut-based ingredients',
      'avoid': ['Almond oil', 'Shea butter'],
      'alternatives': ['Seed oils', 'Squalane']
    },
    'Soy': {
      'description': 'Soy-derived ingredients',
      'avoid': ['Soy extract', 'Soy oil'],
      'alternatives': ['Peptides', 'Ceramides']
    },
    'Lanolin': {
      'description': 'Wool-derived ingredients',
      'avoid': ['Lanolin', 'Wool alcohol'],
      'alternatives': ['Plant-derived emollients']
    },
  };

  @override
  void initState() {
    super.initState();
    // Preselect 2-3 random allergies
    final allAllergies = allergyCategories.keys.toList();
    final shuffledAllergies = List<String>.from(allAllergies)..shuffle();
    selectedAllergies.addAll(shuffledAllergies.take(2 + Random().nextInt(2)));
  }

// In SurveyScreen3's _handleNavigation method
  void _handleNavigation() {
    // Set survey completion state when survey is actually completed
    NavigationState.hasCompletedSurvey = true;

    StatusPopup.show(
      context,
      message: 'Your survey has been completed successfully!',
      isSuccess: true,
      onClose: () {
        // Navigate based on login state
        if (UserManager.isLoggedIn) {
          // If logged in, go to products
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductListScreen(),
            ),
            (route) => false,
          );
        } else {
          // If not logged in, go to thank you screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ThankYouScreen(),
            ),
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.getGradientBackground(context),
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
                            color: index == 2
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
                    'Discover Your Unique Skin Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Allergies And Other Concerns',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 30),

                  // Allergies List
                  ...allergyCategories.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  entry.key,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.value['description'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    if (selectedAllergies
                                        .contains(entry.key)) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Avoid: ${entry.value['avoid'].join(', ')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.red[300],
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Alternatives: ${entry.value['alternatives'].join(', ')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.green[600],
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                                value: selectedAllergies.contains(entry.key),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedAllergies.add(entry.key);
                                    } else {
                                      selectedAllergies.remove(entry.key);
                                    }
                                  });
                                },
                              ),
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 30),

                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Previous',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),

                      // Next Button
                      ElevatedButton(
                        onPressed: _handleNavigation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Next',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ],
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
}
