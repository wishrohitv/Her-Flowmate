import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Color? _getPhaseColorForDay(DateTime day, PredictionService pred) {
    if (pred.currentPeriodStart == null) return null;

    final start = pred.currentPeriodStart!;
    final diff = day.difference(start).inDays;
    
    final cycleDay = (diff % pred.averageCycleLength);
    if (cycleDay < 0) return null;

    if (cycleDay >= 0 && cycleDay < 5) return AppTheme.phaseColors['Menstrual'];
    if (cycleDay >= 5 && cycleDay < 11) return AppTheme.phaseColors['Follicular'];
    if (cycleDay >= 11 && cycleDay < 16) {
      if (cycleDay == 13) return AppTheme.phaseColors['Ovulation'];
      return AppTheme.phaseColors['Fertile'];
    }
    if (cycleDay >= 16) return AppTheme.phaseColors['Luteal'];

    return null;
  }

  void _showDailyLogSheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DailyLogSheet(date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: AppTheme.neuDecoration(
                          radius: 12, color: AppTheme.frameColor),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppTheme.textDark),
                    ),
                  ),
                ),
                title: Text(
                  'Cycle Calendar',
                  style: GoogleFonts.poppins(
                      color: AppTheme.textDark, fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: AppTheme.neuDecoration(
                      radius: 28, color: AppTheme.frameColor),
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showDailyLogSheet(context, selectedDay);
                    },
                    calendarFormat: CalendarFormat.month,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark),
                      leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                          color: AppTheme.accentPink, size: 28),
                      rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.accentPink, size: 28),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.inter(
                          color: AppTheme.textDark.withOpacity(0.6),
                          fontWeight: FontWeight.w600),
                      weekendStyle: GoogleFonts.inter(
                          color: AppTheme.accentPink,
                          fontWeight: FontWeight.w600),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final color = _getPhaseColorForDay(day, pred);
                        return _buildCalendarCell(day,
                            color: color, isSelected: false);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final color = _getPhaseColorForDay(day, pred);
                        return _buildCalendarCell(day,
                            color: color, isSelected: true);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final color = _getPhaseColorForDay(day, pred);
                        return _buildCalendarCell(day,
                            color: color, isSelected: false, isToday: true);
                      },
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.neuInnerDecoration(radius: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(
                              'Period', AppTheme.phaseColors['Menstrual']!),
                          _buildLegendItem(
                              'Fertile', AppTheme.phaseColors['Fertile']!),
                          _buildLegendItem(
                              'Ovulation', AppTheme.phaseColors['Ovulation']!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(
                              'Follicular', AppTheme.phaseColors['Follicular']!),
                          _buildLegendItem(
                              'Luteal', AppTheme.phaseColors['Luteal']!),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, {Color? color, required bool isSelected, bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentPink : (color ?? Colors.transparent),
        shape: BoxShape.circle,
        border: isToday && !isSelected ? Border.all(color: AppTheme.accentPink, width: 2) : null,
        boxShadow: color != null && !isSelected ? [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
        ] : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: GoogleFonts.inter(
          color: (isSelected || color != null) ? Colors.white : AppTheme.textMain,
          fontWeight: isSelected || isToday || color != null ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DailyLogSheet extends StatefulWidget {
  final DateTime date;
  const _DailyLogSheet({required this.date});

  @override
  State<_DailyLogSheet> createState() => _DailyLogSheetState();
}

class _DailyLogSheetState extends State<_DailyLogSheet> {
  final List<String> _selectedSymptoms = [];
  String? _selectedMood;
  double _bleedingIntensity = 0;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _symptoms = ['Cramps', 'Headache', 'Bloating', 'Fatigue', 'Acne', 'Tender Breasts'];
  final List<String> _moods = ['Happy', 'Sensitive', 'Sad', 'Angry', 'Anxious', 'Calm'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.neuBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44, height: 6,
                decoration: BoxDecoration(color: AppTheme.neuShadowDark, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Daily Log',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.textMain),
            ),
            Text(
              DateFormat('MMMM d, yyyy').format(widget.date),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('How are you feeling?'),
                    Wrap(
                      spacing: 12, runSpacing: 12,
                      children: _symptoms.map((s) => _buildPill(s, _selectedSymptoms.contains(s), () {
                        setState(() { _selectedSymptoms.contains(s) ? _selectedSymptoms.remove(s) : _selectedSymptoms.add(s); });
                      })).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Current Mood'),
                    Wrap(
                      spacing: 12, runSpacing: 12,
                      children: _moods.map((m) => _buildPill(m, _selectedMood == m, () {
                        setState(() => _selectedMood = m);
                      })).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Flow Intensity'),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: AppTheme.neuInnerDecoration(radius: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.accentPink,
                          inactiveTrackColor: AppTheme.neuShadowDark.withOpacity(0.3),
                          thumbColor: AppTheme.accentPink,
                          overlayColor: AppTheme.accentPink.withOpacity(0.12),
                          valueIndicatorColor: AppTheme.accentPink,
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _bleedingIntensity,
                          min: 0, max: 3, divisions: 3,
                          onChanged: (v) => setState(() => _bleedingIntensity = v),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('None', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('Heavy', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Notes'),
                    Container(
                      decoration: AppTheme.neuInnerDecoration(radius: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        style: GoogleFonts.inter(color: AppTheme.textMain, fontSize: 15),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Share your thoughts...',
                          hintStyle: TextStyle(color: Colors.black26),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Container(
              decoration: AppTheme.neuDecoration(radius: 24, color: AppTheme.neuSurface),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_rounded, color: AppTheme.accentPink),
                label: Text('Save Log', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.accentPink)),
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
    );
  }

  Widget _buildPill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: isSelected 
            ? AppTheme.neuInnerDecoration(radius: 20).copyWith(color: AppTheme.accentPink.withOpacity(0.05))
            : AppTheme.neuDecoration(radius: 20, color: AppTheme.neuSurface),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? AppTheme.accentPink : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
