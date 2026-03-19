import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_card.dart';
import '../widgets/info_widgets.dart';

import 'log_period_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeInfo();
    });
  }

  void _checkFirstTimeInfo() {
    final storage = context.read<StorageService>();
    if (!storage.hasSeenInfoPopup && storage.getLogs().isNotEmpty) {
      showNeuInfoPopup(
        context,
        title: 'Welcome to Your Dashboard 🌸',
        explanation: 'The home dashboard is designed to be minimal. You can tap the ⓘ icons on any card to learn more about your current cycle metrics.',
        tip: 'Tapping a card directly will take you to its detailed breakdown.',
      );
      storage.markInfoPopupAsSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    
    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _GreetingSection(storage: storage),
              const SizedBox(height: 32),
              
              if (storage.userGoal == 'pregnant')
                _buildPregnancyDashboard(context, storage)
              else if (storage.userGoal == 'conceive')
                _buildTTCDashboard(context, storage)
              else
                _buildCycleDashboard(context, storage),
                
              const SizedBox(height: 32),
              _buildMedicalDisclaimer(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleDashboard(BuildContext context, StorageService storage) {
    final pred = context.watch<PredictionService>();
    final phaseName = pred.phaseDisplayName;
    final cycleDay = pred.currentCycleDay.clamp(1, 999);
    final daysToNext = pred.daysUntilNextPeriod;
    final hasLogs = storage.getLogs().isNotEmpty;

    if (!hasLogs) return _buildNewUserContent(context, storage);

    return Column(
      children: [
        _buildPhaseCard(context, phaseName),
        const SizedBox(height: 24),
        _buildCycleStatusRow(cycleDay, daysToNext),
        const SizedBox(height: 24),
        if (phaseName == 'Ovulation' || phaseName == 'Follicular')
          _buildFertilityCard(pred),
      ],
    );
  }

  Widget _buildTTCDashboard(BuildContext context, StorageService storage) {
    final pred = context.watch<PredictionService>();
    final nextOvulation = pred.nextPeriodDate?.subtract(const Duration(days: 14)) ?? DateTime.now();

    return Column(
      children: [
        _buildFertilityCard(pred, title: 'TTC Focus: Fertility Window'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.neuDecoration(radius: 32),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Ovulation', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(DateFormat('MMM d').format(nextOvulation), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  ],
                ),
              ),
              const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 28),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildPregnancyDashboard(BuildContext context, StorageService storage) {
    final weeks = storage.pregnancyWeeks ?? 8; // Fallback to 8
    final dueDate = storage.dueDate ?? DateTime.now().add(const Duration(days: 220));
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;
    
    String babySize = 'Raspberry';
    if (weeks >= 12) babySize = 'Lime';
    if (weeks >= 20) babySize = 'Banana';
    if (weeks >= 40) babySize = 'Watermelon';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.neuDecoration(radius: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pregnancy Progress', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Week $weeks', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const Icon(Icons.pregnant_woman_rounded, color: AppTheme.accentPink, size: 40),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.neuDecoration(radius: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Baby Size', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('About the size of a $babySize', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        _buildCycleStatusRow(weeks, daysRemaining, label1: 'Weeks', label2: 'Days Left'),
      ],
    );
  }

  Widget _buildPhaseCard(BuildContext context, String phaseName) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.neuDecoration(radius: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Current Phase', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              NeuInfoButton(
                onTap: () => showNeuInfoPopup(
                  context,
                  title: 'Current Phase',
                  explanation: 'Your cycle consists of four main phases.',
                  tip: 'Each phase brings unique hormonal shifts.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(phaseName, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(AppTheme.phaseTip(phaseName).headline, style: GoogleFonts.inter(fontSize: 16, color: AppTheme.phaseColor(phaseName), fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildCycleStatusRow(dynamic val1, dynamic val2, {String label1 = 'Cycle Day', String label2 = 'Next Period'}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.neuDecoration(radius: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label1, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('$val1', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              ],
            ),
          ),
          Container(width: 1.5, height: 40, color: AppTheme.shadowDark.withOpacity(0.2)),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label2, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(val2 is int && val2 < 0 ? '${val2.abs()}d late' : (label2 == 'Days Left' ? '$val2' : 'In $val2 days'), 
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildFertilityCard(PredictionService pred, {String title = 'Fertility Window'}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.neuDecoration(radius: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('High probability today', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.neuDecoration(radius: 16, color: AppTheme.frameColor),
                child: const Icon(Icons.favorite_rounded, color: AppTheme.accentPink, size: 24)
                  .animate(onPlay: (c) => c.repeat())
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 800.ms, curve: Curves.easeInOut),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chance of Conception', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              Text('${pred.currentConceptionChance}%', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accentPink)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 12, width: double.infinity,
            decoration: AppTheme.neuInnerDecoration(radius: 6),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pred.currentConceptionChance / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentPink,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: AppTheme.accentPink.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildMedicalDisclaimer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'This is an estimate based on cycle patterns and should not be considered medical advice.',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6), fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNewUserContent(BuildContext context, StorageService storage) {
    return NeuCard(
      onTap: () => _showLogSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${storage.userName}! 🌸',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Text('Add your last period date to start tracking your cycle correctly.',
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: AppTheme.neuInnerDecoration(radius: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: AppTheme.accentPink),
                const SizedBox(width: 12),
                Text('Add Period Date',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentPink)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogPeriodScreen(),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final StorageService storage;
  const _GreetingSection({required this.storage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${storage.userName} 👋', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            Text('Hope you\'re feeling well today.', style: GoogleFonts.inter(fontSize: 17, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.neuDecoration(radius: 16, color: AppTheme.frameColor),
          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 24),
        ).animate().fadeIn(delay: 400.ms).scale(),
      ],
    );
  }
}
