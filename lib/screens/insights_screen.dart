import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../widgets/cycle_phase_wheel.dart';
import '../widgets/glass_insight_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with real values from PredictionService
    final pred = context.watch<PredictionService>();
    
    final currentCycleDay = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLength = pred.averageCycleLength > 0 ? pred.averageCycleLength : 28;
    
    String currentPhaseStr;
    switch (pred.currentPhase) {
      case CyclePhase.menstrual: currentPhaseStr = "Menstrual"; break;
      case CyclePhase.follicular: currentPhaseStr = "Follicular"; break;
      case CyclePhase.ovulation: currentPhaseStr = "Ovulation"; break;
      case CyclePhase.luteal: currentPhaseStr = "Luteal"; break;
      default: currentPhaseStr = "Unknown";
    }
    
    final daysUntilNext = pred.daysUntilNextPeriod;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              "Cycle Insights",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 12)],
              ),
            ),
            const SizedBox(height: 32),

            // Large Phase Wheel
            CyclePhaseWheel(
              currentCycleDay: currentCycleDay,
              cycleLength: cycleLength,
              currentPhase: currentPhaseStr,
              daysUntilNextPeriod: daysUntilNext,
            ).animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack),

            const SizedBox(height: 40),

            // Insights Grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                GlassInsightCard(
                  title: "Cycle Length",
                  value: cycleLength > 0 ? "$cycleLength days" : "--",
                  subtitle: "Average last 6 cycles",
                  icon: Icons.calendar_today_rounded,
                  accentColor: Colors.purpleAccent,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cycle length details coming soon")),
                    );
                  },
                ),
                GlassInsightCard(
                  title: "Fertile Window",
                  value: "6 days",
                  subtitle: pred.currentPhase == CyclePhase.ovulation ? "Peak fertility today" : "Upcoming",
                  icon: Icons.water_drop_rounded,
                  accentColor: Colors.cyanAccent,
                  onTap: () {/* details */},
                ),
                GlassInsightCard(
                  title: "Symptoms Logged",
                  value: "0",
                  subtitle: "This cycle",
                  icon: Icons.emoji_emotions_rounded,
                  accentColor: Colors.pinkAccent,
                  onTap: () {/* details */},
                ),
                GlassInsightCard(
                  title: "Regularity",
                  value: "92%",
                  subtitle: "Very consistent",
                  icon: Icons.trending_up_rounded,
                  accentColor: Colors.greenAccent,
                  onTap: () {/* details */},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Placeholder for full calendar or symptom grid
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Center(
                child: Text(
                  "Full Cycle Calendar\n(Swipeable - Coming Soon)",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 100), // Extra space so FAB doesn't cover content
          ],
        ),
      ),
    );
  }
}
