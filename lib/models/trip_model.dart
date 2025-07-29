import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  final double distance;

  @HiveField(1)
  final double fuelCost;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final double income;

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

  Duration get duration => endTime.difference(startTime);

  double get totalCost => fuelCost + maintenanceCost;

  double get netProfit => income - totalCost;
}