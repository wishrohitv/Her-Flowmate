import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'delight_widgets.dart';

class NeuCard extends StatefulWidget {
  final Widget child;
  final double radius;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final bool showSparkles;

  const NeuCard({
    super.key,
    required this.child,
    required this.onTap,
    this.radius = 28.0,
    this.padding = const EdgeInsets.all(24),
    this.showSparkles = true,
  });

  @override
  State<NeuCard> createState() => _NeuCardState();
}

class _NeuCardState extends State<NeuCard> {
  bool _isPressed = false;
  bool _sparkleTrigger = false;

  @override
  Widget build(BuildContext context) {
    return SparkleEffect(
      trigger: _sparkleTrigger,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          if (mounted) {
            setState(() {
              _isPressed = false;
              if (widget.showSparkles) {
                _sparkleTrigger = true;
              }
            });
          }
          widget.onTap();
          // Reset sparkle trigger after animation
          if (widget.showSparkles) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) setState(() => _sparkleTrigger = false);
            });
          }
        },
        onTapCancel: () {
          if (mounted) setState(() => _isPressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: AppTheme.neuDecoration(
            radius: widget.radius,
            isPressed: _isPressed,
            showGlow: _isPressed, // Glow on press
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
