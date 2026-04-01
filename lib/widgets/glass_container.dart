import 'package:flutter/material.dart';
import 'themed_container.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final double? opacity;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.opacity,
    this.onTap,
    this.width,
    this.height,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      type: ContainerType.glass,
      radius: radius,
      padding: padding,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }
}
