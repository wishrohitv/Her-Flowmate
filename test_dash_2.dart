import 'package:intl/intl.dart';

void main() {
  DateTime today = DateTime.now();
  DateTime pickedConceptionDate =
      today.subtract(Duration(days: 14)); // 2 weeks ago
  DateTime lmp =
      pickedConceptionDate.subtract(Duration(days: 14)); // 4 weeks ago

  DateTime conceptionDate = lmp; // What store reads

  int? currentWeek;
  int currentDay = 0;
  DateTime? estimatedDue;
  DateTime? displayConceptionDate;

  final elapsed = today.difference(conceptionDate).inDays;
  currentWeek = (elapsed / 7).floor().clamp(1, 42);
  currentDay = (elapsed % 7).clamp(0, 6);
  estimatedDue = conceptionDate.add(const Duration(days: 280));
  displayConceptionDate = conceptionDate.add(const Duration(days: 14));

  print('Picked Conception: $pickedConceptionDate');
  print('LMP (Stored): $conceptionDate');
  print('Elapsed Days (from LMP): $elapsed');
  print('Current Week: $currentWeek, Day: $currentDay');
  print('Estimated Due: $estimatedDue');
  print('Display Conception: $displayConceptionDate');
}
