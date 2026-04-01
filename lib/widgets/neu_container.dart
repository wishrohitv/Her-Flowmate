import 'package:flutter/material.dart';
import 'themed_container.dart';

enum NeuStyle { flat, concave, convex, embossed }

class NeuContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final NeuStyle style;
  final bool isSelected;
  final Color? color;

  const NeuContainer({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.onTap,
    this.width,
    this.height,
    this.style = NeuStyle.flat,
    this.isSelected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      type: ContainerType.neu,
      radius: radius,
      padding: padding,
      onTap: onTap,
      width: width,
      height: height,
      color: color,
      child: child,
    );
  }
}
