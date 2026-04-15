import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/brand_widgets.dart';
import '../utils/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isNavigating = false;

  void _onBeginJourney() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    
    // Visual "Chime" Burst
    showNeonChime(context);
    
    // Slight delay to enjoy the burst
    await Future.delayed(800.ms);

    if (mounted) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionDuration: 1200.ms,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
                    ),
                    child: child,
                  ),
                ),
                // Neon Flash Overlay
                IgnorePointer(
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary,
                            blurRadius: 100,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
      if (mounted) setState(() => _isNavigating = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedGlowBackground(
        showSparkles: true,
        showFlowers: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 360;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 20 : 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Logo with Breathing & Floating Effect
                        Hero(
                          tag: 'brand_logo',
                          child: BrandLogo(
                            size: isSmall ? 120 : 160,
                            imagePath: 'assets/images/feature_graphic.png',
                            showName: true,
                            nameFontSize: isSmall ? 36 : 48,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: -5, end: 5, duration: 3.seconds, curve: Curves.easeInOutSine)
                        .animate() // Entry animation
                        .fadeIn(duration: 800.ms)
                        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                        const SizedBox(height: 16),

                        // Gradient Tagline
                        ShaderMask(
                          shaderCallback: (bounds) => AppTheme.brandGradient.createShader(bounds),
                          child: Text(
                            'Your intelligent cycle companion',
                            style: AppTheme.outfit(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 80),

                        // Premium Glass CTA
                        Semantics(
                          label: 'Begin journey',
                          button: true,
                          child: ShimmerButton(
                            onTap: _onBeginJourney,
                            radius: 32,
                            child: Container(
                              width: double.infinity,
                              height: isSmall ? 64 : 80,
                              decoration: AppTheme.premiumGlassDecoration(
                                radius: 32,
                                opacity: isDark ? 0.15 : 0.6,
                              ),
                              child: _isNavigating
                                  ? const Center(child: CircularProgressIndicator())
                                  : Center(
                                      child: Text(
                                        'BEGIN JOURNEY',
                                        style: AppTheme.playfair(
                                          fontSize: isSmall ? 18 : 22,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.0,
                                          color: isDark ? colorScheme.primary : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),

                        const SizedBox(height: 40),


                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

