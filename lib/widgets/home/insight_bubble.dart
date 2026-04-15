import 'package:flutter/material.dart';
import '../common/neu_card.dart';
import '../../utils/app_theme.dart';

class InsightBubble extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;

  const InsightBubble({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeumorphicCard(
          width: 68,
          height: 68,
          borderRadius: 34,
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 28,
                shadows: [
                  if (isExpanded)
                    Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: AppTheme.outfit(
            context: context,
            fontSize: 10,
            fontWeight: isExpanded ? FontWeight.w900 : FontWeight.w700,
            color: isExpanded
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
