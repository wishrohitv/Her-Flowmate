import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/prediction_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    final predictionService = context.watch<PredictionService>();
    final logs = storageService.getLogs();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0033), Color(0xFF2A0044)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Header
            Text(
              'Cycle Calendar',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 12)],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 16),

            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendDot(const Color(0xFFFF00AA), 'Period'),
                  const SizedBox(width: 24),
                  _buildLegendDot(const Color(0xFF00FFFF), 'Fertile'),
                  const SizedBox(width: 24),
                  _buildLegendDot(Colors.white54, 'Today'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),

            // Calendar card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white70),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white70),
                          headerPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
                          weekendStyle: GoogleFonts.outfit(color: Colors.pinkAccent, fontSize: 13),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: GoogleFonts.outfit(color: Colors.white),
                          weekendTextStyle: GoogleFonts.outfit(color: Colors.pinkAccent),
                          outsideTextStyle: GoogleFonts.outfit(color: Colors.white24),
                          todayDecoration: BoxDecoration(
                            color: Colors.pinkAccent.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.pinkAccent, width: 1.5),
                          ),
                          todayTextStyle: GoogleFonts.outfit(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFFFF00AA),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Color(0xFFFF00AA),
                            shape: BoxShape.circle,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            bool isPeriodDay = logs.any((log) {
                              final end = log.startDate.add(Duration(days: log.duration - 1));
                              return !date.isBefore(DateTime(log.startDate.year, log.startDate.month, log.startDate.day)) &&
                                     !date.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59));
                            });

                            bool isFertile = predictionService.isFertileDay(date);

                            if (isPeriodDay) {
                              return Center(
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFF00AA).withOpacity(0.35),
                                    border: Border.all(color: const Color(0xFFFF00AA), width: 1.5),
                                    boxShadow: [BoxShadow(color: const Color(0xFFFF00AA).withOpacity(0.3), blurRadius: 8)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            } else if (isFertile) {
                              return Center(
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF00FFFF).withOpacity(0.15),
                                    border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.6), width: 1),
                                    boxShadow: [BoxShadow(color: const Color(0xFF00FFFF).withOpacity(0.2), blurRadius: 6)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: GoogleFonts.outfit(color: Colors.cyanAccent),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).scale(curve: Curves.easeOutBack, begin: const Offset(0.95, 0.95)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
      ],
    );
  }
}
