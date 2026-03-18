import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white12,
              child: Text(
                storageService.userName.isNotEmpty ? storageService.userName[0].toUpperCase() : 'U',
                style: GoogleFonts.outfit(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              storageService.userName.isNotEmpty ? storageService.userName : 'Guest User',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 32),
            
            _buildSettingTile(
              icon: Icons.picture_as_pdf_rounded,
              title: "Export Cycle Data (PDF)",
              color: Colors.cyanAccent,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export feature coming soon.')));
              },
            ),
            
            _buildSettingTile(
              icon: storageService.isMinimalMode ? Icons.motion_photos_paused : Icons.animation,
              title: "Minimalist Mode",
              color: Colors.purpleAccent,
              trailing: Switch(
                value: storageService.isMinimalMode,
                onChanged: (val) => storageService.toggleMinimalMode(),
                activeColor: Colors.purpleAccent,
              ),
              onTap: () => storageService.toggleMinimalMode(),
            ),

            _buildSettingTile(
              icon: Icons.privacy_tip_rounded,
              title: "Privacy Settings",
              color: Colors.greenAccent,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data is saved locally for your privacy.')));
              },
            ),
            
            const SizedBox(height: 32),
            if (storageService.isLoggedIn || storageService.hasCompletedLogin)
              ElevatedButton.icon(
                onPressed: () => storageService.logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.pinkAccent,
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required Color color, Widget? trailing, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
