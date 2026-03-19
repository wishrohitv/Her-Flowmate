import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final initial = storage.userName.isNotEmpty
        ? storage.userName[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // ── Avatar ───────────────────────────────────────────────────
              Container(
                width: 120, height: 120,
                decoration: AppTheme.neuDecoration(radius: 60),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(
                      fontSize: 48, fontWeight: FontWeight.w800,
                      color: AppTheme.accentPink),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),
              Text(
                storage.userName.isNotEmpty ? storage.userName : 'Guest',
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 48),

              // ── Settings Tiles ────────────────────────────────────────────
              _tile(
                context,
                icon: Icons.picture_as_pdf_rounded,
                iconColor: AppTheme.accentPink,
                title: 'Export My Data',
                subtitle: 'Download history as PDF',
                onTap: () async {
                  await storage.exportLogsToPdf();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF Export started...'), backgroundColor: AppTheme.accentPink));
                  }
                },
              ).animate().fadeIn(delay: 400.ms),

              _tile(
                context,
                icon: storage.isMinimalMode
                    ? Icons.motion_photos_paused_rounded
                    : Icons.auto_awesome_rounded,
                iconColor: AppTheme.accentPink,
                title: 'Minimalist Mode',
                subtitle: storage.isMinimalMode ? 'Enabled' : 'Disabled',
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: storage.isMinimalMode,
                    onChanged: (_) => storage.toggleMinimalMode(),
                    activeColor: AppTheme.accentPink,
                    inactiveThumbColor: AppTheme.textSecondary,
                  ),
                ),
                onTap: () => storage.toggleMinimalMode(),
              ).animate().fadeIn(delay: 500.ms),

              _tile(
                context,
                icon: Icons.privacy_tip_rounded,
                iconColor: AppTheme.phaseColors['Ovulation']!,
                title: 'Privacy Policy',
                subtitle: 'Local and encrypted data',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your data stays on your device.'), backgroundColor: AppTheme.accentPink)),
              ).animate().fadeIn(delay: 600.ms),

              _tile(
                context,
                icon: Icons.delete_sweep_rounded,
                iconColor: Colors.redAccent,
                title: 'Clear All Data',
                subtitle: 'Permanently erase all logs',
                onTap: () => _confirmDelete(context, storage),
              ).animate().fadeIn(delay: 650.ms),

              const SizedBox(height: 64),

              // ── Logout ────────────────────────────────────────────────────
              if (storage.hasCompletedLogin)
                NeuCard(
                  radius: 20,
                  padding: EdgeInsets.zero,
                  onTap: () => storage.logout(),
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: AppTheme.accentPink),
                        const SizedBox(width: 12),
                        Text('Log Out',
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w800,
                                color: AppTheme.accentPink)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.frameColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Delete All Data?', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        content: Text('This action cannot be undone. All logs will be cleared.', 
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
            onPressed: () {
              storage.deleteAllLogs();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data cleared.'), backgroundColor: Colors.redAccent));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: NeuCard(
        radius: 28,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}
