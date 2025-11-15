// screens/home_page.dart
// شاشة التتبع الرئيسية (محسّنة بصريًا ومتماسكة مع تصميم الإعدادات)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as perm_handler;
import 'package:provider/provider.dart';

import 'package:tracking_cost/l10n/app_localizations.dart';
import 'package:tracking_cost/models/trip_model.dart';
import 'package:tracking_cost/widgets/currency_symbol.dart';
import '../providers/app_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  bool _isTracking = false;
  double _totalDistance = 0.0;
  double _fuelCost = 0.0;
  double _maintCost = 0.0;
  LocationData? _lastLocation;
  DateTime? _startTime;
  Timer? _durationTimer;
  Duration _currentDuration = Duration.zero;

  double _prevDistanceInKm = 0.0;
  double _prevTotalCost = 0.0;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _checkIfTracking();
  }

  // ================== منطق التخزين ==================
  Future<void> _saveTrip({double income = 0.0}) async {
    if (_startTime == null) return;
    final trip = Trip(
      distance: _totalDistance,
      fuelCost: _fuelCost,
      maintenanceCost: _maintCost,
      startTime: _startTime!,
      endTime: DateTime.now(),
      income: income,
    );
    await Hive.box<Trip>('trips').add(trip);
  }

  Future<double> _showIncomeDialog() async {
    final c = TextEditingController();
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final r = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l.enterTripIncomeTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: l.zeroAmountPlaceholder,
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, 0.0),
                      child: Text(l.skipButton),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, double.tryParse(c.text) ?? 0.0),
                      icon: const Icon(Icons.check),
                      label: Text(l.saveButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return r ?? 0.0;
  }

  // ================== تتبع وإذن ==================
  Future<void> _checkIfTracking() async {
    final enabled = await _location.isBackgroundModeEnabled();
    if (!mounted) return;
    if (enabled) {
      setState(() => _isTracking = true);
      _startListening();
      _startDurationTimer();
    }
  }

  Future<bool> _requestPermissions() async {
    final l = AppLocalizations.of(context)!;

    var status = await perm_handler.Permission.location.request();
    if (status.isDenied) {
      _showSnack(l.locationPermissionDenied);
      return false;
    }
    if (status.isPermanentlyDenied) {
      _showSnack(l.locationPermissionPermanentlyDenied);
      perm_handler.openAppSettings();
      return false;
    }

    final bg = await perm_handler.Permission.locationAlways.request();
    if (bg.isDenied || bg.isPermanentlyDenied) {
      _showSnack(l.backgroundLocationRecommended);
    }

    var serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        _showSnack(l.enableGpsServiceMessage);
        return false;
      }
    }
    return true;
  }

  Future<void> _toggleTracking() async {
    if (_toggling) return;
    setState(() => _toggling = true);
    HapticFeedback.lightImpact();
    final l = AppLocalizations.of(context)!;

    if (_isTracking) {
      await _locationSubscription?.cancel();
      _durationTimer?.cancel();
      await _location.enableBackgroundMode(enable: false);

      final income = await _showIncomeDialog();
      await _saveTrip(income: income);

      if (!mounted) return;
      setState(() {
        _isTracking = false;
        _lastLocation = null;
        _startTime = null;
        _currentDuration = Duration.zero;
        _totalDistance = 0.0;
        _fuelCost = 0.0;
        _maintCost = 0.0;
        _prevDistanceInKm = 0.0;
        _prevTotalCost = 0.0;
      });
      _showSnack(l.saveButton);
    } else {
      final ok = await _requestPermissions();
      if (!ok) {
        setState(() => _toggling = false);
        return;
      }

      await _location.enableBackgroundMode(enable: true);
      await _location.changeNotificationOptions(
        title: l.trackingNotificationTitle,
        subtitle: l.trackingNotificationSubtitle,
        iconName: 'mipmap/ic_launcher',
      );

      setState(() {
        _isTracking = true;
        _totalDistance = 0.0;
        _fuelCost = 0.0;
        _maintCost = 0.0;
        _prevDistanceInKm = 0.0;
        _prevTotalCost = 0.0;
        _currentDuration = Duration.zero;
        _startTime = DateTime.now();
      });

      _startListening();
      _startDurationTimer();
    }

    if (mounted) setState(() => _toggling = false);
  }

  void _startListening() {
    final settings = context.read<AppSettings>();

    double maintCostPerKm = 0.0;
    if (settings.isMaintenanceEnabled && settings.maintenanceInterval > 0) {
      maintCostPerKm = settings.maintenanceCost / settings.maintenanceInterval;
    }

    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 2000,
      distanceFilter: 2,
    );

    _locationSubscription =
        _location.onLocationChanged.listen((LocationData current) {
          if (!mounted) return;

          if (_lastLocation == null) {
            _lastLocation = current;
            return;
          }
          if (_lastLocation!.latitude == null ||
              _lastLocation!.longitude == null ||
              current.latitude == null ||
              current.longitude == null) {
            return;
          }

          final d = geo.Geolocator.distanceBetween(
            _lastLocation!.latitude!,
            _lastLocation!.longitude!,
            current.latitude!,
            current.longitude!,
          );

          final newMeters = _totalDistance + d;
          final km = newMeters / 1000;

          double fuel = 0.0;
          if (settings.consumptionRate > 0 && settings.fuelPrice > 0) {
            if (settings.consumptionMethod == ConsumptionMethod.kmPerLiter) {
              fuel = (km / settings.consumptionRate) * settings.fuelPrice;
            } else {
              fuel = (km / 100) * settings.consumptionRate * settings.fuelPrice;
            }
          }

          final maint = km * maintCostPerKm;

          setState(() {
            _prevDistanceInKm = _totalDistance / 1000;
            _prevTotalCost = _fuelCost + _maintCost;
            _totalDistance = newMeters;
            _fuelCost = fuel;
            _maintCost = maint;
          });

          _lastLocation = current;
        });
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null && mounted) {
        setState(() => _currentDuration = DateTime.now().difference(_startTime!));
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================== حوارات الإحصاءات ==================
  Future<void> _showDistanceDetailsDialog() async {
    final l = AppLocalizations.of(context)!;
    final trips = Hive.box<Trip>('trips').values.toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double total = 0, todayDist = 0, weekDist = 0, monthDist = 0, longest = 0;
    for (final t in trips) {
      final dKm = t.distance / 1000.0;
      total += dKm;
      if (dKm > longest) longest = dKm;

      final d = DateTime(t.startTime.year, t.startTime.month, t.startTime.day);
      if (d == today) todayDist += dKm;
      if (!t.startTime.isBefore(startOfWeek)) weekDist += dKm;
      if (!t.startTime.isBefore(startOfMonth)) monthDist += dKm;
    }
    final avg = trips.isEmpty ? 0.0 : total / trips.length;

    _showMetricDialog(
      color: const Color(0xFF1FB56C),
      icon: Icons.location_on_outlined,
      title: l.distanceDetailsTitle,
      items: [
        _MetricItem(label: l.distanceTotalLabel, value: "${total.toStringAsFixed(1)} ${l.kmUnit}"),
        _MetricItem(label: l.distanceTodayLabel, value: "${todayDist.toStringAsFixed(1)} ${l.kmUnit}"),
        _MetricItem(label: l.distanceThisWeekLabel, value: "${weekDist.toStringAsFixed(1)} ${l.kmUnit}"),
        _MetricItem(label: l.distanceThisMonthLabel, value: "${monthDist.toStringAsFixed(1)} ${l.kmUnit}"),
        _MetricItem(label: l.distanceLongestLabel, value: "${longest.toStringAsFixed(1)} ${l.kmUnit}"),
        _MetricItem(label: l.distanceAvgLabel, value: "${avg.toStringAsFixed(1)} ${l.kmUnit}"),
      ],
    );
  }

  Future<void> _showTimeDetailsDialog() async {
    final l = AppLocalizations.of(context)!;
    final trips = Hive.box<Trip>('trips').values.toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    final startOfMonth = DateTime(now.year, now.month, 1);

    Duration total = Duration.zero, todayDur = Duration.zero, weekDur = Duration.zero, monthDur = Duration.zero;
    for (final t in trips) {
      final dur = t.duration;
      total += dur;

      final d = DateTime(t.startTime.year, t.startTime.month, t.startTime.day);
      if (d == today) todayDur += dur;
      if (!t.startTime.isBefore(startOfWeek)) weekDur += dur;
      if (!t.startTime.isBefore(startOfMonth)) monthDur += dur;
    }
    String f(Duration d) {
      final h = d.inHours.toString().padLeft(2, '0');
      final m = (d.inMinutes % 60).toString().padLeft(2, '0');
      final s = (d.inSeconds % 60).toString().padLeft(2, '0');
      return "$h:$m:$s";
    }

    final avg = trips.isEmpty ? Duration.zero : Duration(seconds: total.inSeconds ~/ trips.length);

    _showMetricDialog(
      color: const Color(0xFF0C7CCB),
      icon: Icons.access_time,
      title: l.timeDetailsTitle,
      items: [
        _MetricItem(label: l.timeTotalLabel, value: f(total)),
        _MetricItem(label: l.timeTodayLabel, value: f(todayDur)),
        _MetricItem(label: l.timeThisWeekLabel, value: f(weekDur)),
        _MetricItem(label: l.timeThisMonthLabel, value: f(monthDur)),
        _MetricItem(label: l.timeAvgLabel, value: f(avg)),
      ],
    );
  }

  Future<void> _showTripsDetailsDialog() async {
    final l = AppLocalizations.of(context)!;
    final trips = Hive.box<Trip>('trips').values.toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    final startOfMonth = DateTime(now.year, now.month, 1);

    int todayTrips = 0, weekTrips = 0, monthTrips = 0;
    for (final t in trips) {
      final d = DateTime(t.startTime.year, t.startTime.month, t.startTime.day);
      if (d == today) todayTrips++;
      if (!t.startTime.isBefore(startOfWeek)) weekTrips++;
      if (!t.startTime.isBefore(startOfMonth)) monthTrips++;
    }

    _showMetricDialog(
      color: const Color(0xFFB043E0),
      icon: Icons.route_outlined,
      title: l.tripsDetailsTitle,
      items: [
        _MetricItem(label: l.tripsTotalLabel, value: trips.length.toString()),
        _MetricItem(label: l.tripsTodayLabel, value: todayTrips.toString()),
        _MetricItem(label: l.tripsThisWeekLabel, value: weekTrips.toString()),
        _MetricItem(label: l.tripsThisMonthLabel, value: monthTrips.toString()),
      ],
    );
  }

  Future<void> _showConsumptionDetailsDialog(AppSettings s) async {
    final l = AppLocalizations.of(context)!;
    _showMetricDialog(
      color: const Color(0xFFFE5C3B),
      icon: Icons.speed,
      title: l.consumptionDetailsTitle,
      items: [
        _MetricItem(
          label: l.consumptionCurrentLabel,
          value:
          '${s.consumptionRate.toStringAsFixed(1)} ${s.consumptionMethod == ConsumptionMethod.kmPerLiter ? l.kmPerLiter : l.litersPer100Km}',
        ),
      ],
    );
  }

  Future<void> _showMetricDialog({
    required Color color,
    required IconData icon,
    required String title,
    required List<_MetricItem> items,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.75,
                  children: items
                      .map((e) => Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                        const Spacer(),
                        Text(
                          e.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8637FF),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context)!.closeButtonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== واجهة المستخدم ==================
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettings>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final durationString =
        "${_currentDuration.inMinutes.toString().padLeft(2, '0')}:${(_currentDuration.inSeconds % 60).toString().padLeft(2, '0')}";
    final distanceKm = _totalDistance / 1000;
    final tripsCount = Hive.box<Trip>('trips').length;
    final consumptionRateText =
        '${settings.consumptionRate.toStringAsFixed(1)} ${settings.consumptionMethod == ConsumptionMethod.kmPerLiter ? l.kmPerLiter : l.litersPer100Km}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شعار صغير + عنوان
                  Column(
                    children: [
                      _LogoBadge(isDark: isDark),
                      const SizedBox(height: 10),
                      Text(
                        l.mainScreenTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                            color:
                            isDark ? Colors.white : const Color(0xFF59359A),
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.trackingNotificationSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // زر التتبع الكبير
                  _TrackButton(
                    isTracking: _isTracking,
                    toggling: _toggling,
                    onTap: _toggleTracking,
                  ),

                  const SizedBox(height: 20),

                  // الشبكة
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    children: [
                      _MetricCard(
                        color: const Color(0xFF1FB56C),
                        icon: Icons.location_on_outlined,
                        title: l.distanceTraveled,
                        value: "${distanceKm.toStringAsFixed(1)} ${l.kmUnit}",
                        hint: l.trackingNotificationSubtitle,
                        onTap: _showDistanceDetailsDialog,
                      ),
                      _MetricCard(
                        color: const Color(0xFF0C7CCB),
                        icon: Icons.access_time,
                        title: l.tripDurationLabel,
                        value: durationString,
                        hint: l.trackingNotificationSubtitle,
                        onTap: _showTimeDetailsDialog,
                      ),
                      _MetricCard(
                        color: const Color(0xFFB043E0),
                        icon: Icons.route_outlined,
                        title: l.historyScreenTitle,
                        value: "$tripsCount",
                        hint: l.trackingNotificationSubtitle,
                        onTap: _showTripsDetailsDialog,
                      ),
                      _MetricCard(
                        color: const Color(0xFFFE5C3B),
                        icon: Icons.speed,
                        title: l.consumptionRateLabel,
                        value: consumptionRateText,
                        hint: l.trackingNotificationSubtitle,
                        onTap: () => _showConsumptionDetailsDialog(settings),
                      ),
                    ],
                  ),

                  // تحميل خط العملة إذا ما انبنى
                  Opacity(
                    opacity: 0,
                    child: CurrencySymbol(
                      style: Theme.of(context).textTheme.bodySmall ??
                          const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    if (isDark) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFECE8FF), Color(0xFFF3F5FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}

// ================== Widgets داخلية ==================

class _TrackButton extends StatelessWidget {
  final bool isTracking;
  final bool toggling;
  final VoidCallback onTap;
  const _TrackButton({
    required this.isTracking,
    required this.toggling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 112,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8637FF), Color(0xFFE21B79)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: const Color(0xFF8637FF).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: toggling ? null : onTap,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: toggling
                  ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : Row(
                key: ValueKey(isTracking),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTracking
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTracking
                        ? AppLocalizations.of(context)!.endTrip
                        : AppLocalizations.of(context)!.startTrip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String hint;
  final VoidCallback onTap;

  const _MetricCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? color.withOpacity(0.95) : color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Stack(
          children: [
            // زخرفة ركن
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // قيمة مع انتقال رقمي سلس
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 250),
                    tween: Tween(begin: 0, end: 1),
                    builder: (_, __, child) => child!,
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final bool isDark;
  const _LogoBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF8637FF), Color(0xFFE21B79)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: const Color(0xFF8637FF).withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 30),
    );
  }
}

class _MetricItem {
  final String label;
  final String value;
  _MetricItem({required this.label, required this.value});
}
