import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/prediction_service.dart';
import '../common/neu_card.dart';

class BodyInsightsCards extends StatelessWidget {
  final PredictionService pred;

  const BodyInsightsCards({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YourBodyCard(pred: pred),
        const SizedBox(height: AppDesignTokens.space16),
        TodayGuidanceCard(pred: pred),
      ],
    );
  }
}

class TodayGuidanceCard extends StatelessWidget {
  final PredictionService pred;
  const TodayGuidanceCard({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final phase = pred.phaseDisplayName;
    final healthTips = AppTheme.getPhaseHealthTips(phase);

    // Fallback data if list is empty
    final exerciseTip =
        healthTips.exercise.isNotEmpty
            ? healthTips.exercise.first
            : 'Gentle activity';

    return NeumorphicCard(
      borderRadius: AppDesignTokens.radiusLG,
      padding: const EdgeInsets.all(AppDesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: context.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Today\'s Guidance',
                  style: AppTheme.outfit(
                    context: context,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _GuidanceRow(
            icon: Icons.favorite_rounded,
            text: 'High energy day',
            iconColor: Colors.blueAccent,
          ),
          const SizedBox(height: 12),
          _GuidanceRow(
            icon: Icons.extension_rounded,
            text: 'Good for $exerciseTip',
            iconColor: const Color(0xFF6C63FF),
          ),
          const SizedBox(height: 12),
          _GuidanceRow(
            icon: Icons.people_rounded,
            text: 'Great for social tasks',
            iconColor: context.primary,
          ),
          const SizedBox(height: 16),
          // Stress Tip Bubble
          NeumorphicCard(
            borderRadius: AppDesignTokens.radiusSM,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Avoid stress overload',
                    style: AppTheme.outfit(
                      context: context,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class YourBodyCard extends StatelessWidget {
  final PredictionService pred;
  const YourBodyCard({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final bio = pred.getPhaseBiology(pred.currentCycleDay);

    return NeumorphicCard(
      borderRadius: AppDesignTokens.radiusLG,
      padding: const EdgeInsets.all(AppDesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.accessibility_new_rounded,
                size: 18,
                color: context.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Body Today',
                  style: AppTheme.outfit(
                    context: context,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _BodyStatusRow(
            icon: Icons.science_rounded,
            label: 'Hormones',
            value: 'Estrogen ↑',
            iconColor: Colors.pinkAccent,
          ),
          const SizedBox(height: 14),
          _BodyStatusRow(
            icon: Icons.flash_on_rounded,
            label: 'Energy',
            value: bio['energy'] ?? 'Increasing',
            iconColor: Colors.orangeAccent,
          ),
          const SizedBox(height: 14),
          const _BodyStatusRow(
            icon: Icons.sentiment_satisfied_alt_rounded,
            label: 'Mood',
            value: 'Motivated 😊',
            iconColor: Colors.purpleAccent,
          ),
          const SizedBox(height: 20), // Spacer for bottom alignment
        ],
      ),
    );
  }
}

class _GuidanceRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _GuidanceRow({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTheme.outfit(
              context: context,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyStatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _BodyStatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTheme.outfit(
              context: context,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTheme.outfit(
              context: context,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.onSurface.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
