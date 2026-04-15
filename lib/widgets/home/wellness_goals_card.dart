import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../services/storage_service.dart';
import '../../screens/wellness_reminders_screen.dart';
import '../../utils/app_theme.dart';
import '../common/neu_card.dart';

class WellnessGoalsCard extends StatelessWidget {
  final StorageService storage;
  final String heroTag;
  const WellnessGoalsCard({
    super.key,
    required this.storage,
    this.heroTag = 'wellness_goals',
  });

  @override
  Widget build(BuildContext context) {
    final reminders = storage.getAllAppointments();
    final nextGoal = reminders.isNotEmpty ? reminders.first : null;

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: NeumorphicCard(
          borderRadius: AppDesignTokens.radiusLG,
          padding: const EdgeInsets.all(AppDesignTokens.space24),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WellnessRemindersScreen(heroTag: heroTag),
                ),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.spa_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'WELLNESS GOALS',
                        style: AppTheme.outfit(
                          context: context,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: AppDesignTokens.space20),
              if (nextGoal != null)
                Row(
                  children: [
                    Text(
                      nextGoal.category.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextGoal.title,
                            style: AppTheme.outfit(
                              context: context,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scheduled for ${DateFormat('MMM d').format(nextGoal.date)}',
                            style: AppTheme.outfit(
                              context: context,
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'No upcoming goals. Tap to set a reminder!',
                  style: AppTheme.outfit(
                    context: context,
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
