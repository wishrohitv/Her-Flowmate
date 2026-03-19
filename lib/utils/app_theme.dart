import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ── Color Palette (Exact Specification) ───────────────────────────────────
  static const Color bgColor      = Color(0xFFF8E9EE);
  static const Color surfaceColor  = Color(0xFFF3DDE5);
  static const Color accentPink    = Color(0xFFE88BA3);
  static const Color textDark      = Color(0xFF4A2F3A);
  static const Color textSecondary = Color(0xFFA97C8B);
  
  // Aliases for legacy compatibility
  static const Color frameColor    = bgColor;
  static const Color neuSurface    = surfaceColor;
  static const Color textMain       = textDark;
  static const Color textMuted      = textSecondary;
  static const Color shadowLight   = Colors.white;
  static const Color shadowDark    = Color(0xFFD9B9C4);

  // Visualization Colors
  static const Color accentPurple  = Color(0xFFBA68C8);
  static const Color accentCyan    = Color(0xFF4DD0E1);
  static const Color neonGreen     = Color(0xFF81C784);

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgColor, Color(0xFFFAEBEF)],
  );

  static const Map<String, Color> phaseColors = {
    'Menstrual': Color(0xFFE88BA3),
    'Follicular': Color(0xFFF06292),
    'Ovulation': Color(0xFFBA68C8),
    'Fertile': Color(0xFFFFCCBC),
    'Luteal': Color(0xFFA97C8B),
  };

  static Color phaseColor(String phase) => phaseColors[phase] ?? accentPink;

  // ── Neumorphic Decorations ────────────────────────────────────────────────
  static BoxDecoration neuDecoration({
    double radius = 32.0,
    Color color = bgColor,
    bool isPressed = false,
    bool showGlow = false,
  }) {
    if (isPressed) return neuInnerDecoration(radius: radius, color: color);

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        if (showGlow)
          BoxShadow(
            color: accentPink.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        const BoxShadow(
          color: shadowLight,
          offset: Offset(-6, -6),
          blurRadius: 12,
        ),
        BoxShadow(
          color: shadowDark.withOpacity(0.4),
          offset: const Offset(6, 6),
          blurRadius: 12,
        ),
      ],
    );
  }

  static BoxDecoration neuInnerDecoration({
    double radius = 32.0,
    Color color = bgColor,
  }) {
    // Standard Flutter version without inset package
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: shadowDark.withOpacity(0.5),
          offset: const Offset(4, 4),
          blurRadius: 10,
        ),
        BoxShadow(
          color: shadowLight.withOpacity(0.9),
          offset: const Offset(-4, -4),
          blurRadius: 10,
        ),
      ],
    );
  }

  // ── Phase tip helper ──────────────────────────────────────────────────────
  static ({String headline, String body}) phaseTip(String phase) {
    switch (phase) {
      case 'Menstrual': return (headline: 'Focus on Rest', body: 'Energy is lower. Gentle movements only.');
      case 'Follicular': return (headline: 'Energy Rising', body: 'Perfect for starting new projects.');
      case 'Ovulation': return (headline: 'Peak Vitality', body: 'You are at your most vibrant.');
      case 'Luteal': return (headline: 'Nurture Yourself', body: 'Prioritize comfort and slow pace.');
      default: return (headline: 'Stay Mindful', body: 'Listen to your body\'s needs.');
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentPink,
        primary: accentPink,
        surface: surfaceColor,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
    );
  }
}
