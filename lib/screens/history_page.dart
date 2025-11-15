import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:tracking_cost/l10n/app_localizations.dart';
import 'package:tracking_cost/models/trip_model.dart';
import 'package:tracking_cost/widgets/currency_symbol.dart';
import 'package:tracking_cost/theme/app_theme.dart';

enum StatsPeriod { weekly, monthly, yearly }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  bool _showStats = false;
  StatsPeriod _selectedPeriod = StatsPeriod.weekly;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // صياغة تاريخ/وقت الرحلة: اليوم/أمس/تاريخ كامل
  String _getFormattedDate(Trip trip, AppLocalizations l) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tripDate = DateTime(trip.startTime.year, trip.startTime.month, trip.startTime.day);
    final timeFormat = DateFormat.jm(l.localeName);

    if (tripDate == today) {
      return "${l.dateToday}، ${timeFormat.format(trip.startTime)}";
    } else if (tripDate == yesterday) {
      return "${l.dateYesterday}، ${timeFormat.format(trip.startTime)}";
    } else {
      return DateFormat('yyyy/MM/dd، hh:mm a', l.localeName).format(trip.startTime);
    }
  }

  Future<void> _showEditIncomeDialog(Trip trip) async {
    final controller = TextEditingController(text: trip.income > 0 ? trip.income.toString() : '');
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    final double? newIncome = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l.editTripIncomeTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: l.zeroAmountPlaceholder,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CurrencySymbol(
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(l.cancelButton),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.glowShadow(Theme.of(context).colorScheme.primary),
            ),
            child: ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                Navigator.of(context).pop(value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l.saveChangesButton),
            ),
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
    final l = AppLocalizations.of(context)!;
    final box = Hive.box<Trip>('trips');
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.bgGradient(brightness),
        ),
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Trip> box, _) {
            if (box.values.isEmpty) {
              return CustomScrollView(
                slivers: [
                  _buildAppBar(context, l, box.values.length),
                  SliverFillRemaining(child: _buildEmptyState(context, l)),
                ],
              );
            }

            final allTrips = box.values.toList();
            final reversed = allTrips.reversed.toList();

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, l, allTrips.length),
                if (_showStats)
                  SliverToBoxAdapter(
                    child: FadeTransition(opacity: _fadeAnimation, child: _buildStatsWidget(context, allTrips)),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final trip = reversed[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAnimatedTripCard(trip, index),
                        );
                      },
                      childCount: reversed.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedTripCard(Trip trip, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: Key(trip.key.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(gradient: AppTheme.redGradient, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        confirmDismiss: (_) => _showDeleteConfirmation(context),
        onDismissed: (_) {
          trip.delete();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.tripDeletedSuccess),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        child: _buildTripCard(context, trip),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l.deleteConfirmationTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l.deleteConfirmationContent,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
            child: Text(l.cancelButton),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l.deleteButton),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppLocalizations l, int tripCount) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
            ),
            child: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.cardShadowThemed(context),
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.historyScreenTitle,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$tripCount ${l.historyTripsCountSuffix}', // أضف المفتاح في arb مثل: "historyTripsCountSuffix": "رحلة مسجلة"
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadowThemed(context),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _showStats = !_showStats;
                    if (_showStats) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  });
                  HapticFeedback.lightImpact();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bar_chart, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        _showStats ? l.hideStats : l.statsTitle, // أضف "hideStats" في arb إن لم تكن موجودة
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(color: AppTheme.surface(context), shape: BoxShape.circle),
                    child: Icon(Icons.map_outlined, size: 50, color: Theme.of(context).colorScheme.primary),
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.auto_awesome, color: AppTheme.yellow400, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l.emptyHistoryTitle, // أضف المفتاح إن لم يكن موجودًا
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l.emptyHistorySubtitle,
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildFeatureChip(l.featureTrackDistances, Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.12)),
                _buildFeatureChip(l.featureCalcProfit, AppTheme.purple500, AppTheme.purple500.withOpacity(0.12)),
                _buildFeatureChip(l.featureRichStats, AppTheme.pink500, AppTheme.pink500.withOpacity(0.12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildStatsWidget(BuildContext context, List<Trip> allTrips) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    late final List<Trip> filtered;

    switch (_selectedPeriod) {
      case StatsPeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
        final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        filtered = allTrips.where((t) => !t.startTime.isBefore(startDate)).toList();
        break;
      case StatsPeriod.monthly:
        filtered = allTrips.where((t) => t.startTime.month == now.month && t.startTime.year == now.year).toList();
        break;
      case StatsPeriod.yearly:
        filtered = allTrips.where((t) => t.startTime.year == now.year).toList();
        break;
    }

    final totalIncome = filtered.fold<double>(0, (s, t) => s + t.income);
    final totalCost = filtered.fold<double>(0, (s, t) => s + t.totalCost);
    final totalNet = totalIncome - totalCost;
    final totalDistanceKm = filtered.fold<double>(0, (s, t) => s + t.distance) / 1000.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppTheme.cardShadowThemed(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                _buildPeriodButton(StatsPeriod.weekly, l.statsWeekly),
                _buildPeriodButton(StatsPeriod.monthly, l.statsMonthly),
                _buildPeriodButton(StatsPeriod.yearly, l.statsYearly),
              ]),
            ),
            const SizedBox(height: 20),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(l.totalIncome, totalIncome, Icons.attach_money, AppTheme.blueGradient, true),
                _buildStatCard(l.totalCost, totalCost, Icons.trending_down, AppTheme.orangeGradient, true),
                _buildStatCard(l.totalDistance, totalDistanceKm, Icons.map, AppTheme.purpleGradient, false, suffix: ' ${l.kmUnit}'),
                _buildStatCard(l.totalNetProfit, totalNet, totalNet >= 0 ? Icons.trending_up : Icons.trending_down, totalNet >= 0 ? AppTheme.greenGradient : AppTheme.redGradient, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(StatsPeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriod = period);
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? AppTheme.glowShadow(Theme.of(context).colorScheme.primary) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double value, IconData icon, Gradient gradient, bool isCurrency, {String suffix = ''}) {
    return Container(
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadowThemed(context)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 18)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text(value.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (isCurrency)
              const CurrencySymbol(style: TextStyle(color: Colors.white, fontSize: 14))
            else
              Text(suffix, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ]),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final l = AppLocalizations.of(context)!;
    final formattedDate = _getFormattedDate(trip, l);
    final d = trip.duration;
    final durationString = "${d.inMinutes} ${l.minuteUnit} ${d.inSeconds.remainder(60)} ${l.secondUnit}";
    final distanceKm = trip.distance / 1000.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppTheme.cardShadowThemed(context),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ),
              ]),
              _buildIconButton(
                Icons.edit_outlined,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    () => _showEditIncomeDialog(trip),
              ),
            ]),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Stats Grid + financials
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: _buildInfoCard(
                    Icons.map_outlined,
                    l.tripDistanceLabel,
                    '${distanceKm.toStringAsFixed(2)} ${l.kmUnit}',
                    AppTheme.blueGradientLight,
                    AppTheme.blue500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    Icons.schedule,
                    l.tripDurationLabel,
                    durationString,
                    AppTheme.purpleGradientLight,
                    AppTheme.purple500,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _buildFinancialCard(Icons.attach_money, l.incomeLabel, trip.income, AppTheme.greenGradientLight, AppTheme.green500),
              const SizedBox(height: 8),
              _buildFinancialCard(Icons.trending_down, l.totalTripCostLabel, trip.totalCost, AppTheme.orangeGradientLight, AppTheme.orange500),

              // Cost details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Icon(Icons.local_gas_station, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55)),
                    const SizedBox(width: 4),
                    Text(
                      '${l.fuelLabel}: ${trip.fuelCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
                    ),
                  ]),
                  Row(children: [
                    Icon(Icons.build_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55)),
                    const SizedBox(width: 4),
                    Text(
                      '${l.maintLabel}: ${trip.maintenanceCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 8),

              // Net profit pill
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: trip.netProfit >= 0 ? AppTheme.greenGradient : AppTheme.redGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.glowShadow(trip.netProfit >= 0 ? AppTheme.green500 : AppTheme.red500),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(trip.netProfit >= 0 ? Icons.trending_up : Icons.trending_down, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(l.totalNetProfit, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(trip.netProfit.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const CurrencySymbol(style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  /// نص داكن ثابت على الخلفيات الفاتحة (يتباين جيدًا في الثيمين)
  static const _cardTextPrimary = AppTheme.slate800;
  static const _cardTextSecondary = AppTheme.slate600;

  Widget _buildInfoCard(IconData icon, String label, String value, Gradient gradient, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: Colors.white)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: _cardTextSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _cardTextPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }

  Widget _buildFinancialCard(IconData icon, String label, double value, Gradient gradient, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: Colors.white)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: _cardTextPrimary, fontWeight: FontWeight.w600),
          ),
        ]),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: iconColor),
            ),
            const SizedBox(width: 4),
            CurrencySymbol(style: TextStyle(fontSize: 14, color: iconColor)),
          ],
        ),
      ]),
    );
  }
}
