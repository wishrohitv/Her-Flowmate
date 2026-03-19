import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/period_log.dart';
import '../utils/app_theme.dart';

class LogPeriodScreen extends StatefulWidget {
  const LogPeriodScreen({super.key});

  @override
  State<LogPeriodScreen> createState() => _LogPeriodScreenState();
}

class _LogPeriodScreenState extends State<LogPeriodScreen> {
  DateTime? _selectedDate;
  bool _isAM = true;
  String? _flowIntensity = 'Medium';
  final List<String> _selectedSymptoms = [];
  String? _selectedMood;

  final List<String> _allSymptoms = [
    'Cramps', 'Headache', 'Bloating', 'Acne', 'Backache', 'Tender Breasts', 'Nausea'
  ];

  final Map<String, String> _allMoods = {
    'Happy': '😊', 'Energetic': '⚡', 'Tired': '😴', 
    'Sad': '😢', 'Anxious': '😰', 'Angry': '😠', 'Cravings': '🍪'
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.frameColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.neuShadowDark,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Log Your Period',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 10),
              Text(
                'Track symptoms and moods for better insights.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textDark.withOpacity(0.6),
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              // ── Step 1: Date ────────────────────────────────────────────
              _stepLabel('1', 'When did it start?'),
              const SizedBox(height: 12),
              Container(
                decoration: AppTheme.neuDecoration(radius: 20, color: AppTheme.frameColor),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.accentPink,
                            onPrimary: Colors.white,
                            surface: AppTheme.frameColor,
                            onSurface: AppTheme.textDark,
                          ),
                          dialogBackgroundColor: AppTheme.frameColor,
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppTheme.accentPink, size: 24),
                        const SizedBox(width: 14),
                        Text(
                          _selectedDate == null ? 'Select Date' : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            color: _selectedDate == null ? AppTheme.textDark.withOpacity(0.5) : AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDate != null) const Icon(Icons.check_circle_rounded, color: AppTheme.accentPink, size: 22),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // ── Step 2: AM / PM ─────────────────────────────────────────
              _stepLabel('2', 'Select Start Time'),
              const SizedBox(height: 12),
              Container(
                decoration: AppTheme.neuDecoration(radius: 20, color: AppTheme.frameColor),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: _amPmButton('AM', _isAM, () => setState(() => _isAM = true))),
                    const SizedBox(width: 8),
                    Expanded(child: _amPmButton('PM', !_isAM, () => setState(() => _isAM = false))),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // ── Step 3: Flow Intensity ──────────────────────────────────
              _stepLabel('3', 'Flow Intensity'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Light', 'Medium', 'Heavy'].map((flow) {
                  final isSelected = _flowIntensity == flow;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _flowIntensity = flow),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: isSelected 
                            ? AppTheme.neuInnerDecoration(radius: 12)
                            : AppTheme.neuDecoration(radius: 12, color: AppTheme.frameColor),
                          child: Center(
                            child: Text(flow, 
                              style: GoogleFonts.poppins(
                                fontSize: 13, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppTheme.accentPink : AppTheme.textDark,
                              )),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // ── Step 4: Symptoms ────────────────────────────────────────
              _stepLabel('4', 'Symptoms'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allSymptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                    selectedColor: AppTheme.accentPink.withOpacity(0.2),
                    checkmarkColor: AppTheme.accentPink,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: isSelected ? AppTheme.accentPink : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: AppTheme.frameColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),

              // ── Step 5: Mood ────────────────────────────────────────────
              _stepLabel('5', 'Current Mood'),
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: _allMoods.entries.map((entry) {
                    final isSelected = _selectedMood == entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMood = entry.key),
                        child: AnimatedContainer(
                          duration: 250.ms,
                          width: 60,
                          decoration: isSelected
                            ? AppTheme.neuInnerDecoration(radius: 16)
                            : AppTheme.neuDecoration(radius: 16, color: AppTheme.frameColor),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(entry.value, style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(entry.key, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textDark)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 40),

              // ── Save Button ─────────────────────────────────────────────
              Container(
                decoration: _selectedDate == null
                    ? AppTheme.neuInnerDecoration(radius: 20)
                    : AppTheme.neuDecoration(radius: 20, color: AppTheme.frameColor),
                child: ElevatedButton.icon(
                  onPressed: _selectedDate == null ? null : () async {
                    final dateWithTime = DateTime(
                      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                      _isAM ? 8 : 20,
                    );
                    final log = PeriodLog(
                      startDate: dateWithTime,
                      duration: 5,
                      flowIntensity: _flowIntensity,
                      symptoms: _selectedSymptoms,
                      mood: _selectedMood,
                    );
                    await context.read<StorageService>().saveLog(log);
                    if (mounted) Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Period and symptoms logged! ✨'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(Icons.cloud_done_rounded, color: _selectedDate == null ? AppTheme.textDark.withOpacity(0.3) : AppTheme.accentPink),
                  label: Text('Save Log',
                    style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: _selectedDate == null ? AppTheme.textDark.withOpacity(0.3) : AppTheme.accentPink,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepLabel(String step, String label) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: AppTheme.accentPink, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _amPmButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: isActive ? AppTheme.neuInnerDecoration(radius: 14) : const BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'AM' ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
              color: isActive ? AppTheme.accentPink : AppTheme.textDark.withOpacity(0.4),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.poppins(fontSize: 18, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? AppTheme.accentPink : AppTheme.textDark.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}
