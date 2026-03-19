import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class CyclePhaseWheel extends StatelessWidget {
  final int currentCycleDay;
  final int cycleLength;
  final String currentPhase;
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
    final accentColor = AppTheme.phaseColor(currentPhase);

    return SizedBox(
      width: 280,
      height: 280,
      child: Container(
        decoration: AppTheme.neuDecoration(radius: 140),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer track (debossed groove)
            Container(
              width: 250,
              height: 250,
              decoration: AppTheme.neuInnerDecoration(radius: 125),
            ),

            // Inner surface (extruded again to create the ring effect)
            Container(
              width: 210,
              height: 210,
              decoration: AppTheme.neuDecoration(radius: 105),
            ),

            // Progress arc inside the debossed groove
            CustomPaint(
              size: const Size(250, 250),
              painter: _ArcPainter(
                progress: progress,
                color: accentColor,
              ),
            ),

            // Sweeping pointer (needle dot)
            Transform.rotate(
              angle: (progress * pi) - (pi / 2),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                      boxShadow: [
                        BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentPhase,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      _showSnack(context, 'Your average cycle is $cycleLength days.'),
                  child: Text(
                    "Day $currentCycleDay / $cycleLength",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysUntilNextPeriod >= 0
                      ? "Next in $daysUntilNextPeriod d"
                      : "Late by ${daysUntilNextPeriod.abs()} d",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textDark.withOpacity(0.6),
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

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTheme.accentPink,
    ));
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 17.5; // Centers arc in the 250-210 gap

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      rect,
      -pi / 2,           // start at top
      2 * pi * progress, // sweep full circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.color != color;
}
