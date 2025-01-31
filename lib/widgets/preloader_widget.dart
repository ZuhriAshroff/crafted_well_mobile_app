// lib/widgets/survey_loader.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SurveyLoader extends StatefulWidget {
  final String? message;
  const SurveyLoader({Key? key, this.message}) : super(key: key);

  @override
  State<SurveyLoader> createState() => _SurveyLoaderState();
}

class _SurveyLoaderState extends State<SurveyLoader>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _checkmarkController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkScale;
  late Animation<double> _checkmarkOpacity;

  final List<bool> _checkmarks = List.generate(3, (_) => false);
  int _currentCheckmark = 0;

  @override
  void initState() {
    super.initState();

    // Main rotation and scale animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Checkmark appearance animation
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_currentCheckmark < _checkmarks.length) {
            setState(() {
              _checkmarks[_currentCheckmark] = true;
              _currentCheckmark++;
            });
            if (_currentCheckmark < _checkmarks.length) {
              Future.delayed(const Duration(milliseconds: 400), () {
                _checkmarkController.forward(from: 0);
              });
            } else {
              Future.delayed(const Duration(milliseconds: 800), () {
                setState(() {
                  _currentCheckmark = 0;
                  _checkmarks.fillRange(0, _checkmarks.length, false);
                });
                _checkmarkController.forward(from: 0);
              });
            }
          }
        }
      });

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_mainController);

    _checkmarkScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: Curves.elasticOut,
      ),
    );

    _checkmarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start the animations
    _mainController.forward();
    _checkmarkController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = isDarkMode
        ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
        : [const Color(0xFFFFBFE3), const Color(0xFFFFE9BE)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Rotating form background
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors[0].withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 20,
                                decoration: BoxDecoration(
                                  color: colors[0].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Animated checkmarks
                ...List.generate(
                  _checkmarks.length,
                  (index) => AnimatedBuilder(
                    animation: _checkmarkController,
                    builder: (context, child) {
                      return Opacity(
                        opacity:
                            _checkmarks[index] ? _checkmarkOpacity.value : 0,
                        child: Transform.scale(
                          scale: _checkmarks[index] ? _checkmarkScale.value : 0,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 24),
              Text(
                widget.message!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Usage remains the same:
void showLoadingScreen(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SurveyLoader(
          message: "Processing your responses...",
        );
      },
    ),
  );
}
