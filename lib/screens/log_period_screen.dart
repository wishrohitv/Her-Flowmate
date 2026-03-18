import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/period_log.dart';

class LogPeriodScreen extends StatefulWidget {
  const LogPeriodScreen({super.key});

  @override
  State<LogPeriodScreen> createState() => _LogPeriodScreenState();
}

class _LogPeriodScreenState extends State<LogPeriodScreen> {
  DateTime? _selectedDate;
  int _duration = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0033), Color(0xFF2A0044)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '🩸 Log Period',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.pinkAccent.withOpacity(0.6), blurRadius: 16)],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 32),

              // Date picker card
              Text('When did your period start?',
                style: GoogleFonts.outfit(fontSize: 15, color: Colors.white70)),
              const SizedBox(height: 10),
              _buildGlassContainer(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFFF00AA),
                            surface: Color(0xFF1A0033),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Colors.pinkAccent),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Tap to select date'
                              : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: _selectedDate == null ? Colors.white38 : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Duration slider card
              Text('How many days did it last?',
                style: GoogleFonts.outfit(fontSize: 15, color: Colors.white70)),
              const SizedBox(height: 10),
              _buildGlassContainer(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Duration', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14)),
                          Text('$_duration days',
                            style: GoogleFonts.outfit(
                              color: Colors.pinkAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.pinkAccent.withOpacity(0.5), blurRadius: 8)],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.pinkAccent,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.pinkAccent,
                        overlayColor: Colors.pinkAccent.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _duration.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_duration',
                        onChanged: (v) => setState(() => _duration = v.toInt()),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const Spacer(),

              // Save button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: _selectedDate == null
                    ? null
                    : const LinearGradient(colors: [Color(0xFFFF00AA), Color(0xFFAA00FF)]),
                  boxShadow: _selectedDate == null ? [] : [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.4),
                      blurRadius: 20, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: Text('Save Log', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: _selectedDate == null ? null : () async {
                    final log = PeriodLog(startDate: _selectedDate!, duration: _duration);
                    await context.read<StorageService>().saveLog(log);
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
