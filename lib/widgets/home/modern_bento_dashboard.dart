import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import 'cycle_core_ring.dart';
import 'insight_bubble.dart';
import 'water_intake_card.dart';
import 'wellness_stats.dart';
import 'wellness_goals_card.dart';
import '../common/neu_card.dart';
import '../../models/appointment.dart';
import '../../widgets/cycle_widgets.dart';
import 'body_insights_cards.dart';
import '../../screens/wellness_reminders_screen.dart';

class ModernBentoDashboard extends StatefulWidget {
  final StorageService storage;
  final PredictionService pred;
  final ConfettiController confettiController;

  const ModernBentoDashboard({
    super.key,
    required this.storage,
    required this.pred,
    required this.confettiController,
  });

  @override
  State<ModernBentoDashboard> createState() => _ModernBentoDashboardState();
}

class _ModernBentoDashboardState extends State<ModernBentoDashboard> {
  bool _isWaterExpanded = false;
  bool _isSleepExpanded = false;
  bool _isStreakExpanded = false;
  bool _isHormoneExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return Column(
          children: [
            // ── 1. Cycle Core Ring (primary progress gauge) ────────────
            CycleCoreRing(pred: widget.pred)
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: AppDesignTokens.space24),
            _buildActiveGoalPill(context),
            const SizedBox(height: AppDesignTokens.space12),

            // ── 3. Body Status & Guidance Cards ──────────────────────────
            BodyInsightsCards(
              pred: widget.pred,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: AppDesignTokens.space32),

            // ── 4. Expandable Quick-access Insight Bubbles ──────────────
            _buildInsightBubbles(isWide),
            const SizedBox(height: AppDesignTokens.space24),

            // ── 5. Expanded detail panels ───────────────────────────────
            if (_isWaterExpanded)
            WaterIntakeCard(
              storage: widget.storage,
              onGoalReached: () {
                if (mounted) widget.confettiController.play();
              },
            ).animate().fadeIn().slideY(begin: -0.05),

            if (_isSleepExpanded)
              SleepCard(
                storage: widget.storage,
                pred: widget.pred,
              ).animate().fadeIn().slideY(begin: -0.05),

            if (_isStreakExpanded)
            StreakCard(
              storage: widget.storage,
              onMilestoneReached: () {
                if (mounted) widget.confettiController.play();
              },
            ).animate().fadeIn().slideY(begin: -0.05),

            if (_isHormoneExpanded)
            HormoneGraph(
              pred: widget.pred,
            ).animate().fadeIn().slideY(begin: -0.05),

            // ── 6. Wellness Goals / upcoming reminders ──────────────────
            const SizedBox(height: AppDesignTokens.space24),
            WellnessGoalsCard(
              storage: widget.storage,
              heroTag: 'wellness_goals_bento',
            ),
          ],
        );
      },
    );
  }


  Widget _buildActiveGoalPill(BuildContext context) {
    final goals = widget.storage.getAllAppointments();
    if (goals.isEmpty) return const SizedBox.shrink();

    final latestGoal = goals.first;

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WellnessRemindersScreen(heroTag: 'goal_pill'),
            ),
          ),
      child: Hero(
        tag: 'goal_pill',
        child: Material(
          color: Colors.transparent,
          child: NeumorphicCard(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  latestGoal.category.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    latestGoal.title,
                    style: AppTheme.outfit(
                      context: context,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: context.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  // ── Insight Bubbles ────────────────────────────────────────────────────────

  Widget _buildInsightBubbles(bool isWide) {
    final bubbles = [
      _bubble(
        icon: '💧',
        label: 'Water',
        color: Colors.blueAccent,
        isExpanded: _isWaterExpanded,
        onTap: () => setState(() => _isWaterExpanded = !_isWaterExpanded),
      ),
      _bubble(
        icon: '🧪',
        label: 'Hormones',
        color: const Color(0xFFD481FF),
        isExpanded: _isHormoneExpanded,
        onTap: () => setState(() => _isHormoneExpanded = !_isHormoneExpanded),
      ),
      _bubble(
        icon: '🌙',
        label: 'Sleep',
        color: const Color(0xFF66BB6A),
        isExpanded: _isSleepExpanded,
        onTap: () => setState(() => _isSleepExpanded = !_isSleepExpanded),
      ),
      _bubble(
        icon: '🔥',
        label: 'Streak',
        color: Theme.of(context).colorScheme.secondary,
        isExpanded: _isStreakExpanded,
        onTap: () => setState(() => _isStreakExpanded = !_isStreakExpanded),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 0 : 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: bubbles.map((b) => Expanded(child: b)).toList(),
      ),
    );
  }

  Widget _bubble({
    required String icon,
    required String label,
    required Color color,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InsightBubble(
      icon: icon,
      label: label,
      color: color,
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}
