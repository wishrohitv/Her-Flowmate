import 'dart:ui';
import 'package:flutter/material.dart';

enum ContainerType { glass, neu, elevated, simple }

class ThemedContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final ContainerType type;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const ThemedContainer({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.type = ContainerType.simple,
    this.color,
    this.border,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius ?? 24);

    Widget container;

    switch (type) {
      case ContainerType.glass:
        container = ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (color ?? theme.colorScheme.surface).withOpacity(isDark ? 0.2 : 0.4),
                borderRadius: borderRadius,
                border: border ?? Border.all(
                  color: (isDark ? Colors.white : theme.colorScheme.primary).withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        );
        break;

      case ContainerType.neu:
        container = Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: color ?? theme.colorScheme.surface,
            border: border,
            boxShadow: shadows ?? [
              BoxShadow(
                color: theme.shadowColor.withOpacity(isDark ? 0.3 : 0.1),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: isDark ? Colors.black12 : Colors.white,
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: child,
        );
        break;

      case ContainerType.elevated:
        container = Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: color ?? theme.colorScheme.surface,
            border: border,
            boxShadow: shadows ?? [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
        break;

      case ContainerType.simple:
        container = Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: color ?? theme.colorScheme.surface,
            border: border,
          ),
          child: child,
        );
        break;
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return container;
  }
}
