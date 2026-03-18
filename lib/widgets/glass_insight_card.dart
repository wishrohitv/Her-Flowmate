import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class GlassInsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData? icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const GlassInsightCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle = '',
    this.icon,
    this.accentColor = Colors.cyan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 600)),
        ScaleEffect(
          begin: Offset(0.95, 0.95),
          end: Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 160,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: AppTheme.glassDecoration(
            glowColor: accentColor,
            glowOpacity: 0.15,
          ),
          child: AppTheme.glassBlur(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(icon, color: accentColor, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      shadows: [
                        Shadow(
                          color: accentColor.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
