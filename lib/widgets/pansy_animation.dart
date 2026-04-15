import 'dart:math';
import 'package:flutter/material.dart';

class PansyAnimationOverlay extends StatefulWidget {
  const PansyAnimationOverlay({super.key});

  @override
  State<PansyAnimationOverlay> createState() => _PansyAnimationOverlayState();
}

class _PansyAnimationOverlayState extends State<PansyAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int numFlowers = 150;
  final List<PansyParticle> particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < numFlowers; i++) {
        particles.add(
          PansyParticle(
            startOffset: Offset(
              size.width / 2,
              size.height * 0.8,
            ), // Starting roughly around the button
            screenSize: size,
            random: _random,
          ),
        );
      }
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children:
            particles.map((p) => p.buildWidget(_controller.value)).toList(),
      ),
    );
  }
}

class PansyParticle {
  final Offset startOffset;
  late Offset endOffset;
  late double targetDx;
  late double targetDy;
  late double size;
  late double delay;
  late double rotation;
  late double totalSpin;

  PansyParticle({
    required this.startOffset,
    required Size screenSize,
    required Random random,
  }) {
    // Spread completely over the screen
    targetDx = random.nextDouble() * screenSize.width;
    targetDy = random.nextDouble() * screenSize.height;
    endOffset = Offset(targetDx, targetDy);
    size = random.nextDouble() * 35 + 15; // 15 to 50 size
    delay = random.nextDouble() * 0.3; // wait up to 30% of time before bursting
    rotation = random.nextDouble() * pi * 2;
    totalSpin =
        (random.nextDouble() - 0.5) * pi * 4; // spin randomly while moving
  }

  Widget buildWidget(double progress) {
    if (progress < delay) return const SizedBox();

    final p = (progress - delay) / (1.0 - delay);
    final curve = Curves.easeOutCubic.transform(p);
    final currentOffset = Offset.lerp(startOffset, endOffset, curve)!;

    // Scale starts small, grows to full
    final currentSize = size * curve;
    final currentRotation = rotation + (curve * totalSpin);

    // Fade in initially, then stay fully opaque until the screen fades out
    final opacity = (p * 5).clamp(0.0, 1.0);

    return Positioned(
      left: currentOffset.dx - currentSize / 2,
      top: currentOffset.dy - currentSize / 2,
      child: Transform.rotate(
        angle: currentRotation,
        child: Opacity(
          opacity: opacity,
          child: Text(
            '🌸',
            style: TextStyle(
              fontSize: currentSize,
              height: 1.0, // Ensures correct alignment
            ),
          ),
        ),
      ),
    );
  }
}
