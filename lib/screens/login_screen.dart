import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // Dynamic Background Elements (Floating Neon Orbs)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonPink.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).rotate(duration: 20.seconds),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonPurple.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 6.seconds),
            ),
            
            // Heavy background blur layer to wash out the orbs into a glowing ambience
            Positioned.fill(
              child: AppTheme.backgroundBlur(child: const SizedBox.expand()),
            ),

            // Main Content (stays sharp)
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: AppTheme.glassDecoration(
                          borderRadius: 50,
                          glowColor: AppTheme.neonCyan,
                          glowOpacity: 0.25,
                        ),
                        child: AppTheme.glassBlur(
                          borderRadius: 50,
                          child: const Center(
                            child: Icon(Icons.water_drop_rounded, size: 56, color: AppTheme.neonCyan),
                          ),
                        ),
                      ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      
                      // Title
                      ShaderMask(
                        shaderCallback: (b) => AppTheme.titleGradient.createShader(b),
                        child: Text(
                          'Her-Flowmate',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutCubic),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Your living cycle companion.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutCubic),
                      
                      const SizedBox(height: 64),
                      
                      // Glass Login Box
                      Container(
                        width: double.infinity,
                        decoration: AppTheme.glassDecoration(
                          borderRadius: 32,
                          glowColor: AppTheme.neonPink,
                          glowOpacity: 0.15,
                        ),
                        child: AppTheme.glassBlur(
                          borderRadius: 32,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Mock login
                                      await context.read<StorageService>().completeLogin(true, 'Emma');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.neonPink.withValues(alpha: 0.8),
                                      foregroundColor: Colors.white,
                                      shadowColor: AppTheme.neonPink,
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: Text(
                                      'Login to Sync',
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Guest Button
                                TextButton(
                                  onPressed: () async {
                                    // Guest flow
                                    await context.read<StorageService>().completeLogin(false);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    foregroundColor: Colors.white70,
                                  ),
                                  child: Text(
                                    'Continue as Guest',
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, duration: 800.ms, curve: Curves.easeOutQuint),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
