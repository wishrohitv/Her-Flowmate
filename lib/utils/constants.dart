// ── Her-Flowmate Centralized Constants ──────────────────────────────────────
// All magic numbers are extracted here for maintainability and type safety.
// Import this file wherever these values are needed.

// ── App Constants ───────────────────────────────────────────────────────────
abstract final class AppConstants {
  // ── Clinical & Cycle Constants ────────────────────────────────────────────
  /// Standard pregnancy duration from LMP to estimated due date
  static const int pregnancyDaysFromLMP = 280;

  /// Full term pregnancy in weeks
  static const int fullTermWeeks = 40;

  /// Days before next period when ovulation typically occurs (assuming 14-day luteal phase)
  static const int ovulationOffsetFromPeriod = 14;

  /// Minimum cycle length to consider valid (days)
  static const int minCycleLength = 15;

  /// Maximum cycle length to consider valid (days)
  static const int maxCycleLength = 90;

  /// Default average cycle length when user hasn't logged enough data
  static const int defaultCycleLength = 28;

  /// Default period duration (days)
  static const int defaultPeriodDays = 5;

  /// Luteal phase length (days) – used when ovulation date is unknown
  static const int defaultLutealPhaseDays = 14;

  /// Number of cycles needed before predictions become "confident"
  static const int minCyclesForPrediction = 3;

  // ── Hydration Constants ──────────────────────────────────────────────────
  /// Default daily hydration goal (glasses of water)
  static const int defaultHydrationGoal = 8;

  /// Maximum hydration goal (glasses of water)
  static const int maxHydrationGoal = 20;

  /// Unit for hydration tracking
  static const String hydrationUnit = 'glasses';

  // ── Streak Constants ─────────────────────────────────────────────────────
  /// Streak milestones that trigger celebration
  static const Set<int> streakMilestones = {7, 14, 30};

  // ── Appointment Constants ────────────────────────────────────────────────
  /// Days to look ahead for upcoming appointments
  static const int upcomingAppointmentDays = 30;

  // ── Sleep Constants ──────────────────────────────────────────────────────
  /// Min sleep hours considered "great"
  static const double greatSleepHours = 8;

  /// Min sleep hours considered "ok"
  static const double okSleepHours = 6;

  // ── Animation & UI Timing ────────────────────────────────────────────────
  /// Default animation duration (milliseconds)
  static const int animationDurationMs = 300;

  /// Staggered animation delay between items (milliseconds)
  static const int animationStaggerDelayMs = 50;

  /// Confetti celebration duration (seconds)
  static const int confettiDurationSeconds = 3;

  /// Loading skeleton delay before showing actual content (ms)
  static const int loadingSkeletonDelayMs = 800;

  // ── Data Retention & Sync ────────────────────────────────────────────────
  /// Maximum number of past cycles to keep in memory for performance
  static const int maxPastCyclesInMemory = 12;

  /// Auto‑sync interval (hours) – if using cloud backup
  static const int autoSyncIntervalHours = 6;

  // ── Onboarding & Nudges ──────────────────────────────────────────────────
  /// Number of days after which to nudge user to complete profile
  static const int profileNudgeDays = 3;

  /// Maximum number of times to show a particular nudge
  static const int maxNudgeCount = 3;

  // ── Pregnancy Mode ──────────────────────────────────────────────────────
  /// Trimester split points (weeks)
  static const int firstTrimesterEndWeek = 13;
  static const int secondTrimesterEndWeek = 27;

  /// Kick count recommended per day (third trimester)
  static const int recommendedDailyKicks = 10;
}
