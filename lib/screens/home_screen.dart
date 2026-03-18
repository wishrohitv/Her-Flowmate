import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../widgets/cycle_phase_wheel.dart';
import '../widgets/glass_insight_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getPhaseName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return 'Menstruation';
      case CyclePhase.follicular: return 'Follicular';
      case CyclePhase.ovulation: return 'Ovulation';
      case CyclePhase.luteal: return 'Luteal';
      case CyclePhase.unknown: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionService = context.watch<PredictionService>();
    final storageService = context.watch<StorageService>();
    final currentPhase = predictionService.currentPhase;
    final isMinimalMode = storageService.isMinimalMode;
    
    // Gradient config
    final backgroundGradient = isMinimalMode 
      ? const LinearGradient(colors: [Color(0xFF121212), Color(0xFF121212)])
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0033), Color(0xFF2A0044)],
        );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text gradient trick:
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.pinkAccent, Colors.purpleAccent],
                      ).createShader(bounds),
                      child: Text(
                        'Her-Flowmate',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.track_changes, color: Colors.white70),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            isMinimalMode ? Icons.motion_photos_paused : Icons.animation, 
                            color: Colors.white70
                          ),
                          onPressed: () => storageService.toggleMinimalMode(),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(
                            storageService.userName.isNotEmpty ? storageService.userName[0] : 'U',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Big Wheel
                CyclePhaseWheel(
                  currentCycleDay: predictionService.currentCycleDay == 0 ? 1 : predictionService.currentCycleDay,
                  cycleLength: predictionService.averageCycleLength > 0 ? predictionService.averageCycleLength : 28,
                  currentPhase: _getPhaseName(currentPhase),
                  daysUntilNextPeriod: predictionService.daysUntilNextPeriod,
                ),
                
                const SizedBox(height: 48),
                
                // Floating Cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlassInsightCard(
                        title: "Cycle Length",
                        value: predictionService.averageCycleLength > 0 ? "${predictionService.averageCycleLength} d" : "--",
                        subtitle: "Current Avg",
                        icon: Icons.auto_graph_rounded,
                        accentColor: Colors.purpleAccent,
                      ),
                      GlassInsightCard(
                        title: "Fertile Window",
                        value: "6 Days",
                        subtitle: currentPhase == CyclePhase.ovulation ? "Peak nearing" : "Upcoming",
                        icon: Icons.water_drop,
                        accentColor: Colors.cyanAccent,
                      ),
                      GlassInsightCard(
                        title: "Next Period",
                        value: "${predictionService.daysUntilNextPeriod} d",
                        subtitle: "Prediction",
                        icon: Icons.calendar_month,
                        accentColor: Colors.pinkAccent,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 120), // Bottom padding for Nav Bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
