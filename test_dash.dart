import 'package:intl/intl.dart';

void main() {
  DateTime today = DateTime.now();
  int storedWeeks = 8;
  DateTime derivedConception = today.subtract(Duration(days: storedWeeks * 7));
  DateTime conceptionDate = derivedConception;

  int? currentWeek;
  int currentDay = 0;
  DateTime? estimatedDue;

  final elapsed = today.difference(conceptionDate).inDays;
  currentWeek = (elapsed / 7).floor().clamp(1, 42);
  currentDay = (elapsed % 7).clamp(0, 6);
  estimatedDue = conceptionDate.add(const Duration(days: 280));

  print('Elapsed: $elapsed');
  print('Week: $currentWeek, Day: $currentDay');
  print('Due: $estimatedDue');
}
