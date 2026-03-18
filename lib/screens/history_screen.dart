import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../widgets/glass_insight_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storageInfo = context.watch<StorageService>();
    final logs = storageInfo.getLogs();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text(
              "Cycle History",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.purpleAccent.withOpacity(0.4), blurRadius: 12)],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          if (logs.length > 1)
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: logs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.duration.toDouble())).toList(),
                      isCurved: true,
                      color: Colors.pinkAccent,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.pinkAccent.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (logs.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No cycles logged yet.', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[logs.length - 1 - index]; // latest first
                  return GlassInsightCard(
                    title: DateFormat('MMM d, yyyy').format(log.startDate),
                    value: "${log.duration} days",
                    icon: Icons.water_drop,
                    accentColor: Colors.pinkAccent,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
