import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../widgets/her_framed_button.dart';
import '../services/storage_service.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _showInfoSheet(BuildContext context, bool isGoogle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowDark,
              blurRadius: 25,
              offset: Offset(10, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isGoogle ? "Continue with Google" : "Continue as Guest",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD81B60),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isGoogle) ...[
              _buildBullet("Data is securely backed up."),
              _buildBullet("Access on any device."),
              _buildBullet("Restore if app is reinstalled."),
            ] else ...[
              _buildBullet("Data saved only on this device.", isError: true),
              _buildBullet("Cannot be recovered if app is uninstalled.",
                  isError: true),
            ],
            const SizedBox(height: 15),
            const Divider(color: Color(0xFFE5D5DD), height: 1),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF48FB1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  shadowColor: Colors.pink.withOpacity(0.4),
                ),
                child: Text(
                  "Got it",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isError ? Icons.priority_high_rounded : Icons.check_rounded,
            size: 14,
            color: isError ? Colors.redAccent : AppTheme.accentPink,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Name with hearts
                  Column(
                    children: [
                      const Text("💕", style: TextStyle(fontSize: 24)),
                      Text(
                        "HerFlowmate",
                        style: GoogleFonts.getFont(
                          'Pacifico', // Approx to "Brush Script MT"
                          fontSize: 48,
                          color: AppTheme.accentPink,
                          shadows: [
                            const Shadow(
                                color: Colors.black12,
                                offset: Offset(1, 1),
                                blurRadius: 2)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Google Button
                  HerFramedButton(
                    icon: Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Text("G", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                    ),
                    label: "Continue with Google",
                    onTap: () async {
                      final storage = context.read<StorageService>();
                      await storage.completeLogin(true);
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => storage.hasCompletedOnboarding
                                ? const MainNavigationScreen()
                                : const OnboardingScreen(),
                          ),
                        );
                      }
                    },
                    onInfoTap: () => _showInfoSheet(context, true),
                  ),

                  // Guest Button
                  HerFramedButton(
                    icon: const Text("👤", style: TextStyle(fontSize: 18)),
                    label: "Continue as Guest",
                    onTap: () async {
                      final storage = context.read<StorageService>();
                      await storage.completeLogin(false);
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => storage.hasCompletedOnboarding
                                ? const MainNavigationScreen()
                                : const OnboardingScreen(),
                          ),
                        );
                      }
                    },
                    onInfoTap: () => _showInfoSheet(context, false),
                  ),

                  const SizedBox(height: 60),

                  Text(
                    "Your privacy matters 💕",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
