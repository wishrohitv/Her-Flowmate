import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_card.dart';
import '../widgets/delight_widgets.dart';

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
    
    // Specified Colors
    const periodColor = Color(0xFFD81B60); // Deeper pink
    const fertileColor = Color(0xFFFFCCBC); // Soft peach
    const ovulationColor = Color(0xFFBA68C8); // Purple-pink
    
    if (cycleDay >= 0 && cycleDay < 5) return periodColor;
    if (cycleDay >= 11 && cycleDay < 16) {
      if (cycleDay == 13) return ovulationColor;
      return fertileColor;
    }
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
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        backgroundColor: AppTheme.frameColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: AppTheme.neuDecoration(radius: 12),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
            ),
          ),
        ),
        title: Text(
          'Cycle Calendar',
          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: AppTheme.neuDecoration(radius: 32),
                    padding: const EdgeInsets.all(16),
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
                        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                        leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppTheme.accentPink, size: 28),
                        rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppTheme.accentPink, size: 28),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w700),
                        weekendStyle: GoogleFonts.inter(color: AppTheme.accentPink, fontWeight: FontWeight.w700),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final color = _getPhaseColorForDay(day, pred);
                          return _buildCalendarCell(day, color: color, isSelected: false);
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          final color = _getPhaseColorForDay(day, pred);
                          return _buildCalendarCell(day, color: color, isSelected: true);
                        },
                        todayBuilder: (context, day, focusedDay) {
                          final color = _getPhaseColorForDay(day, pred);
                          return _buildCalendarCell(day, color: color, isSelected: false, isToday: true);
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
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.neuInnerDecoration(radius: 28),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem('Period', AppTheme.phaseColors['Menstrual']!),
                            _buildLegendItem('Fertile', AppTheme.phaseColors['Fertile']!),
                            _buildLegendItem('Ovulation', AppTheme.phaseColors['Ovulation']!),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem('Follicular', AppTheme.phaseColors['Follicular']!),
                            _buildLegendItem('Luteal', AppTheme.phaseColors['Luteal']!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, {Color? color, required bool isSelected, bool isToday = false}) {
    final isOvulation = color == const Color(0xFFBA68C8);
    final isPeriod = color == const Color(0xFFD81B60);
    final isFertile = color == const Color(0xFFFFCCBC);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
          ? AppTheme.accentPink 
          : (isPeriod || isFertile ? color!.withOpacity(0.3) : Colors.transparent),
        shape: BoxShape.circle,
        border: isToday && !isSelected ? Border.all(color: AppTheme.accentPink, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${day.day}',
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : AppTheme.textDark,
              fontWeight: isSelected || isToday || color != null ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (isOvulation && !isSelected)
            Positioned(
              bottom: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(color: Color(0xFFBA68C8), shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DailyLogSheet extends StatelessWidget {
  final DateTime date;
  const _DailyLogSheet({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppTheme.frameColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Container(width: 44, height: 6, decoration: BoxDecoration(color: AppTheme.shadowDark, borderRadius: BorderRadius.circular(3))),
           const SizedBox(height: 24),
           Text(DateFormat('MMMM d, yyyy').format(date), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
           const SizedBox(height: 12),
           Text('Cycle Day: ${context.read<PredictionService>().getConceptionChance(date) > 0 ? "Day 14 (Estimated)" : "N/A"}', // Simple placeholder for cycle day calculation
             style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
           const SizedBox(height: 32),
           
           // Conception Chance Section
           Container(
             padding: const EdgeInsets.all(24),
             decoration: AppTheme.neuDecoration(radius: 28),
             child: Column(
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('Chance of Conception', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                     Text('${context.read<PredictionService>().getConceptionChance(date)}%', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accentPink)),
                   ],
                 ),
                 const SizedBox(height: 12),
                 Container(
                   height: 8, width: double.infinity,
                   decoration: AppTheme.neuInnerDecoration(radius: 4),
                   child: FractionallySizedBox(
                     alignment: Alignment.centerLeft,
                     widthFactor: context.read<PredictionService>().getConceptionChance(date) / 100,
                     child: Container(decoration: BoxDecoration(color: AppTheme.accentPink, borderRadius: BorderRadius.circular(4))),
                   ),
                 ),
               ],
             ),
           ),
           
           const SizedBox(height: 24),
           Text(
             'This is an estimate based on cycle patterns and should not be considered medical advice.',
             style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5), fontStyle: FontStyle.italic),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 32),
           NeuCard(
             radius: 20,
             onTap: () {
               final pred = context.read<PredictionService>();
               showPhaseDelight(context, pred.phaseDisplayName);
               Navigator.pop(context);
             },
             child: Center(child: Text('Add Specific Day Insight', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.accentPink))),
           ),
           const SizedBox(height: 48),
        ],
      ),
    );
  }
}
