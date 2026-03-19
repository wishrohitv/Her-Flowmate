import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class NotificationBell extends StatelessWidget {
  final bool hasUnread;
  const NotificationBell({super.key, this.hasUnread = true});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showNotifications(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: AppTheme.neuDecoration(radius: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
            if (hasUnread)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }
}

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Notifications',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _notifItem(
            'Cycle Update',
            'Your fertile window begins today! 🌸',
            'Just now',
            Icons.favorite_rounded,
          ),
          _notifItem(
            'Logging Reminder',
            "Don't forget to track your symptoms today.",
            '2 hours ago',
            Icons.edit_note_rounded,
          ),
          _notifItem(
            'Phase Change',
            'Follicular phase started. Energy levels rising!',
            'Yesterday',
            Icons.bolt_rounded,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _notifItem(String title, String body, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.neuDecoration(radius: 20, color: AppTheme.frameColor),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentPink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
                Text(body, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
