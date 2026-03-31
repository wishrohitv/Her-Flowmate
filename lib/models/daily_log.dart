import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 1)
class DailyLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<String>? moods;

  @HiveField(2)
  final List<String>? symptoms;

  @HiveField(3)
  final int? waterIntake; // in glasses

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String? flowIntensity;

  @HiveField(6)
  final List<String>? physicalActivity;

  /// Hours of sleep (e.g. 7.5). Stored from daily check-in.
  @HiveField(7)
  final double? sleepHours;

  /// Subjective energy level: 1 (exhausted) to 5 (very energetic).
  @HiveField(8)
  final int? energyLevel;

  /// Subjective stress level: 1 (very calm) to 5 (very stressed).
  @HiveField(9)
  final int? stressLevel;

  /// Basal body temperature in Celsius (useful for fertility tracking).
  @HiveField(10)
  final double? basalBodyTemperature;

  /// Number of steps walked today.
  @HiveField(11)
  final int? stepsCount;

  DailyLog({
    required this.date,
    this.moods,
    this.symptoms,
    this.waterIntake,
    this.notes,
    this.flowIntensity,
    this.physicalActivity,
    this.sleepHours,
    this.energyLevel,
    this.stressLevel,
    this.basalBodyTemperature,
    this.stepsCount,
  });
}

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 1;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      date: fields[0] as DateTime,
      moods: (fields[1] as List?)?.cast<String>(),
      symptoms: (fields[2] as List?)?.cast<String>(),
      waterIntake: fields[3] as int?,
      notes: fields[4] as String?,
      flowIntensity: fields[5] as String?,
      physicalActivity: (fields[6] as List?)?.cast<String>(),
      sleepHours: fields[7] as double?,
      energyLevel: fields[8] as int?,
      stressLevel: fields[9] as int?,
      basalBodyTemperature: fields[10] as double?,
      stepsCount: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.moods)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.waterIntake)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.flowIntensity)
      ..writeByte(6)
      ..write(obj.physicalActivity)
      ..writeByte(7)
      ..write(obj.sleepHours)
      ..writeByte(8)
      ..write(obj.energyLevel)
      ..writeByte(9)
      ..write(obj.stressLevel)
      ..writeByte(10)
      ..write(obj.basalBodyTemperature)
      ..writeByte(11)
      ..write(obj.stepsCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
