import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../widgets/cycle_phase_wheel.dart';
import '../widgets/glass_insight_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();

    final cycleDay   = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen   = pred.averageCycleLength > 0 ? pred.averageCycleLength : 28;
    final phaseName  = pred.phaseDisplayName; // DRY: no local switch needed
    final daysToNext = pred.daysUntilNextPeriod;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            ShaderMask(
              shaderCallback: (b) => AppTheme.titleGradient.createShader(b),
              child: Text(
                'Cycle Insights',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Large Phase Wheel
            CyclePhaseWheel(
              currentCycleDay: cycleDay,
              cycleLength: cycleLen,
              currentPhase: phaseName,
              daysUntilNextPeriod: daysToNext,
            ).animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack),

            const SizedBox(height: 40),

            // Insights Grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                GlassInsightCard(
                  title:    'Cycle Length',
                  value:    '$cycleLen days',
                  subtitle: 'Average last 6 cycles',
                  icon:     Icons.calendar_today_rounded,
                  accentColor: AppTheme.neonPurple,
                  onTap: () => _showSnack(context, 'Cycle length details coming soon'),
                ),
                GlassInsightCard(
                  title:    'Fertile Window',
                  value:    '6 days',
                  subtitle: pred.currentPhase == CyclePhase.ovulation
                      ? 'Peak fertility today' : 'Upcoming',
                  icon:     Icons.water_drop_rounded,
                  accentColor: AppTheme.neonCyan,
                ),
                GlassInsightCard(
                  title:    'Symptoms Logged',
                  value:    '0',
                  subtitle: 'This cycle',
                  icon:     Icons.emoji_emotions_rounded,
                  accentColor: AppTheme.neonPink,
                ),
                GlassInsightCard(
                  title:    'Regularity',
                  value:    '92%',
                  subtitle: 'Very consistent',
                  icon:     Icons.trending_up_rounded,
                  accentColor: AppTheme.neonGreen,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Placeholder full calendar
            Container(
              height: 240,
              width: double.infinity,
              decoration: AppTheme.glassDecoration(borderRadius: 24),
              child: AppTheme.glassBlur(
                borderRadius: 24,
                child: const Center(
                  child: Text(
                    'Full Cycle Calendar\n(Swipeable — Coming Soon)',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}
