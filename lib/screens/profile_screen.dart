import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final initial = storage.userName.isNotEmpty
        ? storage.userName[0].toUpperCase()
        : 'U';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // ── Avatar ───────────────────────────────────────────────────
            Container(
              width: 110, height: 110,
              decoration: AppTheme.neuDecoration(
                  radius: 55, color: AppTheme.frameColor),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: GoogleFonts.poppins(
                    fontSize: 48, fontWeight: FontWeight.bold,
                    color: AppTheme.accentPink),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 20),
            Text(
              storage.userName.isNotEmpty ? storage.userName : 'Guest',
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // ── Settings Tiles ────────────────────────────────────────────
            _tile(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: AppTheme.accentPink,
              title: 'Export My Data',
              subtitle: 'Download cycle history as PDF',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF Export coming soon.'))),
            ).animate().fadeIn(delay: 400.ms),

            _tile(
              icon: storage.isMinimalMode
                  ? Icons.motion_photos_paused_rounded
                  : Icons.auto_awesome_rounded,
              iconColor: AppTheme.accentPink,
              title: 'Minimalist Mode',
              subtitle: storage.isMinimalMode ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: storage.isMinimalMode,
                onChanged: (_) => storage.toggleMinimalMode(),
                activeColor: AppTheme.accentPink,
              ),
              onTap: () => storage.toggleMinimalMode(),
            ).animate().fadeIn(delay: 500.ms),

            _tile(
              icon: Icons.privacy_tip_rounded,
              iconColor: AppTheme.phaseColors['Ovulation']!,
              title: 'Privacy Policy',
              subtitle: 'Learn how your data is protected',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your data is local and encrypted.'))),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 40),

            // ── Logout ────────────────────────────────────────────────────
            if (storage.hasCompletedLogin)
              Container(
                decoration: AppTheme.neuDecoration(
                    radius: 20, color: AppTheme.frameColor),
                child: ElevatedButton.icon(
                  onPressed: () => storage.logout(),
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.accentPink),
                  label: Text('Log Out',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppTheme.accentPink)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: AppTheme.neuDecoration(
            radius: 24, color: AppTheme.frameColor),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textDark.withOpacity(0.6))),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textDark, size: 22),
          ],
        ),
      ),
    );
  }
}
