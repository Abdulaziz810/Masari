import 'package:hive/hive.dart';

part 'trip_model.g.dart';

/// نموذج الرحلة المخزّن في Hive.
/// يخزن:
/// - المسافة بالمتر
/// - تكلفة الوقود
/// - تكلفة الصيانة
/// - وقت البداية والنهاية
/// - الدخل (اختياري)
///
/// فيه خصائص محسوبة: المدة، التكلفة الكلية، صافي الربح.
@HiveType(typeId: 0)
class Trip extends HiveObject {
  /// المسافة المقطوعة بالمتر
  @HiveField(0)
  final double distance;

  /// تكلفة الوقود
  @HiveField(1)
  final double fuelCost;

  /// وقت بداية الرحلة
  @HiveField(2)
  final DateTime startTime;

  /// وقت نهاية الرحلة
  @HiveField(3)
  final DateTime endTime;

  /// الدخل اللي دخله المستخدم بعد الرحلة
  @HiveField(4)
  final double income;

  /// تكلفة الصيانة المحتسبة للرحلة
  @HiveField(5)
  final double maintenanceCost;

  Trip({
    required this.distance,
    required this.fuelCost,
    required this.startTime,
    required this.endTime,
    this.income = 0.0,
    this.maintenanceCost = 0.0,
  });

  /// مدة الرحلة
  Duration get duration => endTime.difference(startTime);

  /// التكلفة الكلية = وقود + صيانة
  double get totalCost => fuelCost + maintenanceCost;

  /// صافي الربح = الدخل - التكلفة
  double get netProfit => income - totalCost;

  /// نسخة معدلة من نفس الرحلة
  /// تفيد لما نبي نغيّر الدخل أو نصلح قيمة بدون ما نكتب كل الحقول
  Trip copyWith({
    double? distance,
    double? fuelCost,
    DateTime? startTime,
    DateTime? endTime,
    double? income,
    double? maintenanceCost,
  }) {
    return Trip(
      distance: distance ?? this.distance,
      fuelCost: fuelCost ?? this.fuelCost,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      income: income ?? this.income,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
    );
  }

  /// تحويل لكائن قابل للتصدير/الطباعة
  Map<String, dynamic> toMap() {
    return {
      'distance': distance,
      'fuelCost': fuelCost,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'income': income,
      'maintenanceCost': maintenanceCost,
      'durationSeconds': duration.inSeconds,
      'totalCost': totalCost,
      'netProfit': netProfit,
    };
  }
}
