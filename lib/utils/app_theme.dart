import 'dart:ui';
import 'package:flutter/material.dart';

/// Centralised design tokens for Her-Flowmate.
/// Keep all colours, gradients & decoration helpers here to stay DRY.
abstract final class AppTheme {
  // ── Background ───────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A0033), Color(0xFF0D001A), Color(0xFF2A0044)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient backgroundGradientMinimal = LinearGradient(
    colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
  );

  // ── Neon brand colours ───────────────────────────────────────────
  static const Color neonPink   = Color(0xFFFF00AA);
  static const Color neonPurple = Color(0xFFAA00FF);
  static const Color neonCyan   = Color(0xFF00FFFF);
  static const Color neonGreen  = Color(0xFF00FFAA);

  static const LinearGradient titleGradient = LinearGradient(
    colors: [neonPink, neonPurple],
  );

  // ── Phase palette ────────────────────────────────────────────────
  static const Map<String, Color> phaseColors = {
    'Menstrual'    : neonPink,
    'Menstruation' : neonPink,
    'Follicular'   : neonPurple,
    'Ovulation'    : neonCyan,
    'Luteal'       : neonGreen,
    'Unknown'      : Color(0xFF888888),
  };

  static Color phaseColor(String phaseName) =>
      phaseColors[phaseName] ?? Colors.purpleAccent;

  // ── Phase tips ───────────────────────────────────────────────────
  static const Map<String, PhaseTip> phaseTips = {
    'Menstrual': PhaseTip(
      emoji: '🌙',
      headline: 'Rest & Restore',
      body: 'Your body is shedding – honour it with warmth, gentle movement & iron-rich foods.',
    ),
    'Menstruation': PhaseTip(
      emoji: '🌙',
      headline: 'Rest & Restore',
      body: 'Your body is shedding – honour it with warmth, gentle movement & iron-rich foods.',
    ),
    'Follicular': PhaseTip(
      emoji: '🌱',
      headline: 'Energy Rising',
      body: 'Oestrogen surges – great time to start new projects, socialise & try new workouts.',
    ),
    'Ovulation': PhaseTip(
      emoji: '✨',
      headline: 'Peak Power',
      body: "Fertility window open. You're at your most magnetic – communicate & collaborate!",
    ),
    'Luteal': PhaseTip(
      emoji: '🍂',
      headline: 'Slow Down & Reflect',
      body: 'Progesterone peaks. Cravings are real – opt for dark chocolate & complex carbs.',
    ),
    'Unknown': PhaseTip(
      emoji: '💫',
      headline: 'Track to Unlock Insights',
      body: 'Log your first period to reveal your personalised cycle predictions.',
    ),
  };

  static PhaseTip phaseTip(String phaseName) =>
      phaseTips[phaseName] ?? phaseTips['Unknown']!;

  // ── Glass decoration factory ─────────────────────────────────────
  /// Returns a [BoxDecoration] for the standard glassmorphic card/panel.
  static BoxDecoration glassDecoration({
    double borderRadius = 24,
    Color? glowColor,
    double glowOpacity = 0.15,
    double bgOpacity = 0.05, // Lowered for more contrast/glassiness
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: bgOpacity),
          Colors.white.withValues(alpha: bgOpacity * 0.3),
        ],
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15), // slightly stronger border to highlight shape
        width: 1.5,
      ),
      boxShadow: glowColor != null
          ? [
              BoxShadow(
                color: glowColor.withValues(alpha: glowOpacity),
                blurRadius: 32, // More blurred glow
                spreadRadius: 4,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
    );
  }

  /// Wraps [child] in a [ClipRRect] + [BackdropFilter] for a blur effect.
  static Widget glassBlur({
    required Widget child,
    double borderRadius = 24,
    double sigmaX = 20, // Increased blur for "blurry" request
    double sigmaY = 20,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }

  /// Use this over the entire background to heavily blur animated background shapes.
  static Widget backgroundBlur({required Widget child}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        color: Colors.black.withValues(alpha: 0.1), // slight darkening to highlight foreground
        child: child,
      ),
    );
  }
}

/// Data class for per-phase wellness tips.
class PhaseTip {
  final String emoji;
  final String headline;
  final String body;
  const PhaseTip({
    required this.emoji,
    required this.headline,
    required this.body,
  });
}
