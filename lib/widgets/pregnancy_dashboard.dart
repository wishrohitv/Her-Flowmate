import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'neu_insight_card.dart';

class PregnancyDashboard extends StatelessWidget {
  const PregnancyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // For this UI spec phase, we'll mock the pregnancy data.
    // In a fully built backend, these would be derived from a conception date.
    const int currentWeek = 14;
    const int daysToDueDate = 182;
    const String babySize = "a Lemon 🍋";

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // ── Main Header Card ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.neuDecoration(
                radius: 24,
                color: AppTheme.neuSurface,
              ),
              child: Column(
                children: [
                  const Text('🤰', style: TextStyle(fontSize: 56))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: -4, end: 4, duration: 2.seconds),
                  const SizedBox(height: 16),
                  Text(
                    'Week $currentWeek',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentPink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Second Trimester',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // ── Insights Row ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: NeuInsightCard(
                    title: 'Baby Size',
                    value: babySize,
                    icon: Icons.child_care_rounded,
                    accentColor: AppTheme.accentPurple,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: NeuInsightCard(
                    title: 'Countdown',
                    value: '$daysToDueDate days',
                    subtitle: 'Until due date',
                    icon: Icons.calendar_month_rounded,
                    accentColor: AppTheme.accentPink,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // ── Weekly Tip Card ───────────────────────────────
            Text(
              'Tip of the Week',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.neuInnerDecoration(radius: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: AppTheme.accentPurple,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your baby is starting to practice breathing movements! Make sure you\'re staying hydrated and resting when you feel fatigued.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppTheme.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 120), // clear FAB
          ],
        ),
      ),
    );
  }
}
