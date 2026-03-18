import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pred    = context.watch<PredictionService>();
    final storage = context.watch<StorageService>();

    final phaseName = pred.phaseDisplayName;
    final cycleDay    = pred.currentCycleDay.clamp(1, 999);
    final daysToNext  = pred.daysUntilNextPeriod;

    final bg = storage.isMinimalMode
        ? AppTheme.backgroundGradientMinimal
        : AppTheme.backgroundGradient;

    return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bg),
        child: Stack(
          children: [
            // Ambient Orbs in the background (similar to Login, but subtler)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.neonPurple.withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 8.seconds),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.neonPink.withValues(alpha: 0.1), Colors.transparent],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 10.seconds),
            ),

            // Heavy background blur layer to diffuse the orbs completely
            Positioned.fill(
              child: AppTheme.backgroundBlur(child: const SizedBox.expand()),
            ),

            // Crisp Foregound User Interface
            SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [


                // ── Character Guidance / Greeting ────────────────────
                _CharacterGuidanceWidget(
                  storage: storage,
                  pred: pred,
                  phaseName: phaseName,
                  cycleDay: cycleDay,
                  daysToNext: daysToNext,
                ),



                const SizedBox(height: 120), // clear FAB + nav bar
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}


class _CharacterGuidanceWidget extends StatelessWidget {
  final StorageService storage;
  final PredictionService pred;
  final String phaseName;
  final int cycleDay;
  final int daysToNext;

  const _CharacterGuidanceWidget({
    required this.storage,
    required this.pred,
    required this.phaseName,
    required this.cycleDay,
    required this.daysToNext,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogs = storage.getLogs().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(
        borderRadius: 24,
        glowColor: AppTheme.neonPink,
        glowOpacity: 0.1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The Character
          Column(
            children: [
              const Text(
                '👧',
                style: TextStyle(fontSize: 56),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -4, end: 4, duration: 2.seconds),
              if (!hasLogs)
               const Text('👋', style: TextStyle(fontSize: 24))
                 .animate(onPlay: (c) => c.repeat(reverse: true))
                 .rotate(begin: -0.1, end: 0.2, duration: 1.seconds),
            ],
          ),
          const SizedBox(width: 20),
          
          // The Message / Bullet List
          Expanded(
            child: hasLogs ? _buildReturningUserContent() : _buildNewUserContent(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildNewUserContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Flowmate, ${storage.userName}!',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.neonPink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Click the + button below to log your last period. We\'ll track your cycle phases & predict your next dates!',
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildReturningUserContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi ${storage.userName}! Here\'s your cycle status:',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.neonCyan,
          ),
        ),
        const SizedBox(height: 12),
        _bulletPoint('Current Phase', phaseName),
        _bulletPoint('Cycle Day', 'Day $cycleDay'),
        _bulletPoint('Next Period', daysToNext >= 0 ? 'In $daysToNext days' : '${daysToNext.abs()} days late'),
      ],
    );
  }

  Widget _bulletPoint(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.neonPink, fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(fontSize: 15, color: Colors.white70),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  TextSpan(text: value, style: const TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

