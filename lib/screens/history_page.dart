import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tracking_cost/localization/app_localizations.dart';
import 'package:tracking_cost/models/trip_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tracking_cost/widgets/currency_symbol.dart';

enum StatsPeriod { weekly, monthly, yearly }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _showStats = false;
  StatsPeriod _selectedPeriod = StatsPeriod.weekly;

  String _getFormattedDate(Trip trip, AppLocalizations localizations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tripDate = DateTime(trip.startTime.year, trip.startTime.month, trip.startTime.day);

    final timeFormat = DateFormat.jm(Localizations.localeOf(context).languageCode);

    if (tripDate.isAtSameMomentAs(today)) {
      return "${localizations.translate('dateToday')}, ${timeFormat.format(trip.startTime)}";
    } else if (tripDate.isAtSameMomentAs(yesterday)) {
      return "${localizations.translate('dateYesterday')}, ${timeFormat.format(trip.startTime)}";
    } else {
      return DateFormat('yyyy/MM/dd, hh:mm a', Localizations.localeOf(context).languageCode).format(trip.startTime);
    }
  }

  Future<void> _showEditIncomeDialog(Trip trip) async {
    final incomeController = TextEditingController(text: trip.income > 0 ? trip.income.toString() : '');
    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;

    final double? newIncome = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('editTripIncomeTitle')),
        content: TextField(
          controller: incomeController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: "0.00",
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CurrencySymbol(
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.translate('cancelButton')),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(incomeController.text);
              Navigator.of(context).pop(value);
            },
            child: Text(localizations.translate('saveChangesButton')),
          ),
        ],
      ),
    );

    if (newIncome != null) {
      final updatedTrip = Trip(
        distance: trip.distance,
        fuelCost: trip.fuelCost,
        maintenanceCost: trip.maintenanceCost,
        startTime: trip.startTime,
        endTime: trip.endTime,
        income: newIncome,
      );

      final box = Hive.box<Trip>('trips');
      await box.put(trip.key, updatedTrip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final box = Hive.box<Trip>('trips');

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('historyScreenTitle')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showStats ? Icons.close : Icons.bar_chart),
            tooltip: 'الإحصائيات',
            onPressed: () {
              setState(() {
                _showStats = !_showStats;
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Trip> box, _) {
          if (box.values.isEmpty) {
            return _buildEmptyState(context);
          }

          final allTrips = box.values.toList();
          final reversedTrips = allTrips.reversed.toList();

          return Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: child,
                  );
                },
                child: _showStats
                    ? _buildStatsWidget(context, allTrips)
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: reversedTrips.length,
                  itemBuilder: (context, index) {
                    final trip = reversedTrips[index];
                    return Dismissible(
                      key: Key(trip.key.toString()),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(localizations.translate('deleteConfirmationTitle')),
                              content: Text(localizations.translate('deleteConfirmationContent')),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(localizations.translate('cancelButton')),
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text(localizations.translate('deleteButton')),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        trip.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(localizations.translate('tripDeletedSuccess'))),
                        );
                      },
                      child: _buildTripCard(context, trip),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 100,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.translate('emptyHistoryTitle'),
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('emptyHistorySubtitle'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsWidget(BuildContext context, List<Trip> allTrips) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    List<Trip> filteredTrips;

    switch (_selectedPeriod) {
      case StatsPeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
        final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        filteredTrips = allTrips.where((trip) => trip.startTime.isAfter(startOfWeekDate)).toList();
        break;
      case StatsPeriod.monthly:
        filteredTrips = allTrips.where((trip) => trip.startTime.month == now.month && trip.startTime.year == now.year).toList();
        break;
      case StatsPeriod.yearly:
        filteredTrips = allTrips.where((trip) => trip.startTime.year == now.year).toList();
        break;
    }

    final double totalIncome = filteredTrips.fold(0, (sum, item) => sum + item.income);
    final double totalCost = filteredTrips.fold(0, (sum, item) => sum + item.totalCost);
    final double totalNetProfit = totalIncome - totalCost;
    final double totalDistance = filteredTrips.fold(0, (sum, item) => sum + item.distance);
    final profitColor = totalNetProfit >= 0 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ToggleButtons(
                isSelected: [
                  _selectedPeriod == StatsPeriod.weekly,
                  _selectedPeriod == StatsPeriod.monthly,
                  _selectedPeriod == StatsPeriod.yearly,
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedPeriod = StatsPeriod.values[index];
                  });
                },
                borderRadius: BorderRadius.circular(8),
                children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(localizations.translate('statsWeekly'))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(localizations.translate('statsMonthly'))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(localizations.translate('statsYearly'))),
                ],
              ),
            ),
            const Divider(height: 24),
            _buildStatRow(localizations.translate('totalIncome'), totalIncome, Colors.blue, context),
            _buildStatRow(localizations.translate('totalCost'), totalCost, Colors.orange, context),
            _buildStatRow(localizations.translate('totalDistance'), totalDistance / 1000, Colors.grey, context, isCurrency: false, suffix: " ${localizations.translate('kmUnit')}"),
            const Divider(height: 20),
            _buildStatRow(localizations.translate('totalNetProfit'), totalNetProfit, profitColor, context, isBold: true),

            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(_buildChartData(context, filteredTrips)),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(BuildContext context, List<Trip> trips) {
    final localizations = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;

    List<BarChartGroupData> barGroups = [];
    String Function(double) getTitles;
    double maxY = 0;
    double minY = 0;

    switch (_selectedPeriod) {
      case StatsPeriod.weekly:
        final daysOfWeek = [
          localizations.translate('daySun'),
          localizations.translate('dayMon'),
          localizations.translate('dayTue'),
          localizations.translate('dayWed'),
          localizations.translate('dayThu'),
          localizations.translate('dayFri'),
          localizations.translate('daySat'),
        ];
        final Map<int, double> dailyProfits = {};
        for (var trip in trips) {
          dailyProfits.update(trip.startTime.weekday % 7, (value) => value + trip.netProfit, ifAbsent: () => trip.netProfit);
        }
        barGroups = List.generate(7, (index) {
          final profit = dailyProfits[index] ?? 0;
          if (profit > maxY) maxY = profit;
          if (profit < minY) minY = profit;
          return BarChartGroupData(
            x: index,
            barRods: [BarChartRodData(toY: profit, color: profit >= 0 ? Colors.green : Colors.red, width: 14, borderRadius: BorderRadius.circular(4))],
          );
        });
        getTitles = (value) => daysOfWeek[value.toInt()];
        break;
      case StatsPeriod.monthly:
        final Map<int, double> weeklyProfits = {};
        for (var trip in trips) {
          final weekOfMonth = (trip.startTime.day - 1) ~/ 7;
          weeklyProfits.update(weekOfMonth, (value) => value + trip.netProfit, ifAbsent: () => trip.netProfit);
        }
        barGroups = List.generate(4, (index) {
          final profit = weeklyProfits[index] ?? 0;
          if (profit > maxY) maxY = profit;
          if (profit < minY) minY = profit;
          return BarChartGroupData(
            x: index,
            barRods: [BarChartRodData(toY: profit, color: profit >= 0 ? Colors.green : Colors.red, width: 22, borderRadius: BorderRadius.circular(4))],
          );
        });
        getTitles = (value) => '${localizations.translate('weekPrefix')}${value.toInt() + 1}';
        break;
      case StatsPeriod.yearly:
        final monthsOfYear = [
          localizations.translate('monthJan'), localizations.translate('monthFeb'), localizations.translate('monthMar'),
          localizations.translate('monthApr'), localizations.translate('monthMay'), localizations.translate('monthJun'),
          localizations.translate('monthJul'), localizations.translate('monthAug'), localizations.translate('monthSep'),
          localizations.translate('monthOct'), localizations.translate('monthNov'), localizations.translate('monthDec'),
        ];
        final Map<int, double> monthlyProfits = {};
        for (var trip in trips) {
          monthlyProfits.update(trip.startTime.month, (value) => value + trip.netProfit, ifAbsent: () => trip.netProfit);
        }
        barGroups = List.generate(12, (index) {
          final monthNum = index + 1;
          final profit = monthlyProfits[monthNum] ?? 0;
          if (profit > maxY) maxY = profit;
          if (profit < minY) minY = profit;
          return BarChartGroupData(
            x: monthNum,
            barRods: [BarChartRodData(toY: profit, color: profit >= 0 ? Colors.green : Colors.red, width: 12, borderRadius: BorderRadius.circular(4))],
          );
        });
        getTitles = (value) => monthsOfYear[value.toInt() - 1];
        break;
    }

    return BarChartData(
      maxY: maxY <= 0 ? 10 : maxY * 1.2,
      minY: minY >= 0 ? 0 : minY * 1.2,
      barGroups: barGroups,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(getTitles(value), style: TextStyle(color: textColor, fontSize: 10)),
            reservedSize: 22,
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.blueGrey,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final profit = rod.toY;
            return BarTooltipItem(
              '${profit.toStringAsFixed(2)} ${localizations.translate('currencyUnit')}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double value, Color valueColor, BuildContext context, {bool isBold = false, bool isCurrency = true, String suffix = ''}) {
    final textStyle = TextStyle(fontSize: 16, color: valueColor, fontWeight: isBold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value.toStringAsFixed(2), style: textStyle),
              const SizedBox(width: 4),
              if (isCurrency)
                CurrencySymbol(style: textStyle)
              else
                Text(suffix, style: textStyle.copyWith(fontSize: 12))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final localizations = AppLocalizations.of(context)!;
    final formattedDate = _getFormattedDate(trip, localizations);
    final duration = trip.duration;

    final durationString = "${duration.inMinutes} ${localizations.translate('minuteUnit')} ${duration.inSeconds.remainder(60)} ${localizations.translate('secondUnit')}";
    final profitColor = trip.netProfit >= 0 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formattedDate, style: Theme.of(context).textTheme.bodySmall),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${localizations.translate('tripDistanceLabel')}: ${(trip.distance / 1000).toStringAsFixed(2)} ${localizations.translate('kmUnit')}"),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text("${localizations.translate('tripDurationLabel')}: $durationString"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFinancialRow(context, localizations.translate('incomeLabel'), trip.income, Theme.of(context).textTheme.bodyMedium!),
                  _buildFinancialRow(context, localizations.translate('totalTripCostLabel'), trip.totalCost, Theme.of(context).textTheme.bodyMedium!),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      "(${localizations.translate('fuelLabel')}: ${trip.fuelCost.toStringAsFixed(2)}, ${localizations.translate('maintLabel')}: ${trip.maintenanceCost.toStringAsFixed(2)})",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildFinancialRow(context, localizations.translate('netProfitLabel'), trip.netProfit, TextStyle(color: profitColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () {
                _showEditIncomeDialog(trip);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(BuildContext context, String label, double value, TextStyle textStyle) {
    return Row(
      children: [
        Text('$label: ', style: textStyle),
        Text(value.toStringAsFixed(2), style: textStyle),
        const SizedBox(width: 4),
        CurrencySymbol(style: textStyle),
      ],
    );
  }
}