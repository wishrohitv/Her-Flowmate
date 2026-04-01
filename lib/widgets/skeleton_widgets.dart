import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// A reusable skeleton loader for a card structure.
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const _SkeletonPulse(),
    );
  }
}

/// A circular skeleton loader (e.g., for avatars).
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const _SkeletonPulse(),
    );
  }
}

/// A line skeleton loader for text placeholders.
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonLine({super.key, this.width, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: const _SkeletonPulse(),
    );
  }
}

/// Internal helper for pulse animation
class _SkeletonPulse extends StatefulWidget {
  const _SkeletonPulse();

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<_SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
