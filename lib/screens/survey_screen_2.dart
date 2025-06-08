// lib/screens/survey_screen_2.dart
import 'dart:math';

import 'package:crafted_well_mobile_app/screens/survey_screen_3.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class SurveyScreen2 extends StatefulWidget {
  const SurveyScreen2({Key? key}) : super(key: key);

  @override
  State<SurveyScreen2> createState() => _SurveyScreen2State();
}

class _SurveyScreen2State extends State<SurveyScreen2>
    with TickerProviderStateMixin {
  String? selectedEnvironment;

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final environments = [
    {
      'title': 'URBAN',
      'description': 'Polluted, high-stress environment',
      'details': 'City life with pollution, stress, and air conditioning',
      'image': 'assets/images/city.png',
      'icon': Icons.location_city,
      'color': Colors.blue.shade400,
      'gradient': [Colors.blue.shade300, Colors.blue.shade500],
    },
    {
      'title': 'TROPICAL',
      'description': 'Humid, warm climate',
      'details': 'High humidity, intense sun, and warm temperatures',
      'image': 'assets/images/tropical.png',
      'icon': Icons.wb_sunny,
      'color': Colors.orange.shade400,
      'gradient': [Colors.orange.shade300, Colors.orange.shade500],
    },
    {
      'title': 'MODERATE',
      'description': 'Moderate, changing seasons',
      'details': 'Balanced climate with seasonal variations',
      'image': 'assets/images/moderate.png',
      'icon': Icons.eco,
      'color': Colors.green.shade400,
      'gradient': [Colors.green.shade300, Colors.green.shade500],
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Preselect a random environment
    selectedEnvironment =
        environments[Random().nextInt(environments.length)]['title'] as String;

    _animationController.forward();

    // Delayed card animation
    Future.delayed(Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Header
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
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
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Step 2 of 3 • Environment',
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
                      const SizedBox(height: 30),
                      Row(
                        children: List.generate(3, (index) {
                          return Expanded(
                            child: Container(
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                gradient: index <= 1
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.7),
                                        ],
                                      )
                                    : null,
                                color: index <= 1
                                    ? null
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: index <= 1
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

                      // Enhanced Title Section
                      const SizedBox(height: 40),
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.landscape,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your Environmental Context',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Where do you spend most of your time?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Enhanced Environment Cards
                      ...environments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final env = entry.value;
                        final isSelected = selectedEnvironment == env['title'];

                        return AnimatedBuilder(
                          animation: _cardAnimationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                (1 - _cardAnimationController.value) *
                                    50 *
                                    (index + 1),
                              ),
                              child: Opacity(
                                opacity: _cardAnimationController.value,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: _EnhancedEnvironmentCard(
                                    environment: env,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        selectedEnvironment =
                                            env['title'] as String;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),

                      const SizedBox(height: 40),

                      // Enhanced Navigation Buttons
                      Row(
                        children: [
                          // Previous Button
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Back',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 16),

                          // Next Button
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: selectedEnvironment != null
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.8),
                                        ],
                                      )
                                    : null,
                                color: selectedEnvironment != null
                                    ? null
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: selectedEnvironment != null
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ElevatedButton(
                                onPressed: selectedEnvironment != null
                                    ? () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                const SurveyScreen3(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              return SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(1.0, 0.0),
                                                  end: Offset.zero,
                                                ).animate(animation),
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: selectedEnvironment != null
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: selectedEnvironment != null
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: selectedEnvironment != null
                                              ? Colors.white
                                              : Colors.grey[600],
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class _EnhancedEnvironmentCard extends StatelessWidget {
  final Map<String, dynamic> environment;
  final bool isSelected;
  final VoidCallback onTap;

  const _EnhancedEnvironmentCard({
    required this.environment,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: environment['gradient'] as List<Color>,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? environment['color'] as Color
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (environment['color'] as Color).withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 15 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22)),
                    child: Image.asset(
                      environment['image'] as String,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: environment['gradient'] as List<Color>,
                            ),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(22)),
                          ),
                          child: Icon(
                            environment['icon'] as IconData,
                            size: 48,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (environment['color'] as Color).withOpacity(0.3),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                    ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : (environment['color'] as Color).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        environment['icon'] as IconData,
                        size: 24,
                        color: isSelected
                            ? environment['color'] as Color
                            : Colors.white,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: environment['color'] as Color,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          environment['title'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    environment['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    environment['details'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
