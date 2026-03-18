import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class CyclePhaseWheel extends StatelessWidget {
  final int currentCycleDay;
  final int cycleLength; // e.g. 28 or your predicted average
  final String currentPhase; // "Menstruation", "Follicular", etc.
  final int daysUntilNextPeriod;

  const CyclePhaseWheel({
    super.key,
    required this.currentCycleDay,
    required this.cycleLength,
    required this.currentPhase,
    required this.daysUntilNextPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = cycleLength > 0 ? currentCycleDay / cycleLength.clamp(1, 999) : 0.0;

    // Phase colors (match your neon palette)
    final phaseColors = {
      "Menstrual": const Color(0xFFFF00AA),
      "Menstruation": const Color(0xFFFF00AA),
      "Follicular": const Color(0xFFAA00FF),
      "Ovulation": const Color(0xFF00FFFF),
      "Luteal": const Color(0xFF00FFAA),
      "Unknown": Colors.grey,
    };

    final accentColor = phaseColors[currentPhase] ?? Colors.purpleAccent;

    return Animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      effects: [
        // Breathing neon glow
        const ShimmerEffect(
          duration: Duration(seconds: 4),
          color: Colors.white24,
          blendMode: BlendMode.softLight,
        ),
        const ScaleEffect(
          begin: Offset(0.98, 0.98),
          end: Offset(1.02, 1.02),
          curve: Curves.easeInOut,
          duration: Duration(seconds: 5),
        ),
      ],
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background gradient ring
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    accentColor.withOpacity(0.6),
                    accentColor.withOpacity(0.9),
                    accentColor,
                    accentColor.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.15, 0.35, 0.65, 0.85, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),

            // Inner dark circle
            Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F001A),
              ),
            ),

            // Progress arc (semi-circle top half)
            CustomPaint(
              size: const Size(260, 260),
              painter: _ArcPainter(
                progress: progress,
                color: accentColor,
              ),
            ),

            // Sweeping pointer (needle)
            Transform.rotate(
              angle: (progress * pi) - (pi / 2), // starts at top, sweeps clockwise
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 4,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, Colors.white.withOpacity(0.9)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: accentColor, blurRadius: 12, spreadRadius: 2),
                    ],
                  ),
                ),
              ),
            ),

            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentPhase,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: accentColor, blurRadius: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Cycle Day $currentCycleDay/$cycleLength",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysUntilNextPeriod >= 0 ? "Next in $daysUntilNextPeriod days" : "Late by ${daysUntilNextPeriod.abs()} days",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.3), color, color.withOpacity(0.8), color],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -pi / 2,           // start at top
      pi * progress,     // sweep clockwise
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
