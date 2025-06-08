// lib/screens/survey_screen_3.dart
import 'dart:math';

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

class _SurveyScreen3State extends State<SurveyScreen3>
    with SingleTickerProviderStateMixin {
  final List<String> selectedAllergies = [];
  bool _isOnline = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    // Preselect 2-3 random allergies
    final allAllergies = allergyCategories.keys.toList();
    final shuffledAllergies = List<String>.from(allAllergies)..shuffle();
    selectedAllergies.addAll(shuffledAllergies.take(2 + Random().nextInt(2)));

    _checkConnectivity();
    _animationController.forward();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await NavigationState.isOnline();
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Connectivity check before survey submission
  void _handleNavigation() async {
    // Safety check: ensure widget is still mounted
    if (!mounted) return;

    print('🔍 Survey submission: Checking connectivity...');

    // Check connectivity before submitting using NavigationState
    final canSubmit = await NavigationState.checkConnectivityForSurvey(context);

    if (!mounted || !canSubmit) {
      print(
          '❌ Survey submission blocked: No internet connection or widget disposed');
      return; // Don't proceed if offline or widget disposed
    }

    print('✅ Connectivity confirmed: Proceeding with survey submission');

    // Validate submission with loading dialog using NavigationState
    final submitted = await NavigationState.validateSurveySubmission(context);

    if (!mounted || !submitted) {
      print('❌ Survey submission failed or widget disposed');
      return;
    }

    // Set survey completion state when survey is actually completed
    NavigationState.markSurveyComplete();
    print('✅ Survey marked complete in SurveyScreen3');

    // Refresh UserManager state to ensure it's current
    await UserManager.initialize();
    print('🔄 UserManager refreshed after survey completion');

    // Safety check before showing popup
    if (!mounted) return;

    StatusPopup.show(
      context,
      message: 'Your survey has been completed successfully!',
      isSuccess: true,
      onClose: () {
        // Safety check before navigation
        if (!mounted) return;

        // Navigate based on login state
        print(
            '🔍 Survey complete navigation - UserManager.isLoggedIn: ${UserManager.isLoggedIn}');

        if (UserManager.isLoggedIn) {
          // If logged in, go to products
          print('✅ User logged in - going to products');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductListScreen(),
            ),
            (route) => false,
          );
        } else {
          // If not logged in, go to thank you screen
          print('⚠️ User not logged in - going to thank you');
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
                              'Step 3 of 3 • Allergies & Concerns',
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

                    // Progress Indicator
                    const SizedBox(height: 20),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
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
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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

                    // Connectivity warning
                    const SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isOnline
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isOnline ? Icons.cloud_done : Icons.cloud_off,
                            size: 16,
                            color: _isOnline
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isOnline
                                  ? 'Internet connection ready for submission'
                                  : 'Internet connection required to submit survey',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isOnline
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
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
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedAllergies.contains(entry.key)
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.withOpacity(0.3),
                                    width: selectedAllergies.contains(entry.key)
                                        ? 2
                                        : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          selectedAllergies.contains(entry.key)
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1)
                                              : Colors.black.withOpacity(0.05),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                color: Colors.red[600],
                                                fontSize: 11,
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
                                                fontSize: 11,
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
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            side: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Previous',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _handleNavigation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Submit',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
