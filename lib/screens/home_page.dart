import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as perm_handler;
import 'package:provider/provider.dart';
import 'package:tracking_cost/localization/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _checkIfTracking();
  }

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
    final box = Hive.box<Trip>('trips');
    await box.add(trip);
  }

  Future<double> _showIncomeDialog() async {
    final incomeController = TextEditingController();
    if (!mounted) return 0.0;
    final localizations = AppLocalizations.of(context)!;

    final double? income = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('enterTripIncomeTitle')),
        content: TextField(
          controller: incomeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: "0.00",
            prefixIcon: Icon(Icons.attach_money),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(0.0),
            child: Text(localizations.translate('skipButton')),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(incomeController.text) ?? 0.0;
              Navigator.of(context).pop(value);
            },
            child: Text(localizations.translate('saveButton')),
          ),
        ],
      ),
    );
    return income ?? 0.0;
  }

  Future<void> _checkIfTracking() async {
    final bool isEnabled = await _location.isBackgroundModeEnabled();
    if (mounted && isEnabled) {
      setState(() {
        _isTracking = true;
      });
      _startListening();
      _startDurationTimer();
    }
  }

  Future<bool> _requestPermissions() async {
    var status = await perm_handler.Permission.location.request();
    if (!mounted) return false;
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض صلاحية الموقع.')));
      return false;
    }
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('افتح إعدادات التطبيق وقم بتفعيل صلاحية الموقع.')));
      perm_handler.openAppSettings();
      return false;
    }
    var backgroundStatus = await perm_handler.Permission.locationAlways.request();
    if (!mounted) return false;
    if (backgroundStatus.isDenied || backgroundStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('صلاحية العمل في الخلفية مهمة للحساب الدقيق.')));
    }
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تفعيل خدمة الموقع GPS في الجهاز.')));
        return false;
      }
    }
    return true;
  }

  void _toggleTracking() async {
    HapticFeedback.lightImpact();

    if (_isTracking) {
      _locationSubscription?.cancel();
      _durationTimer?.cancel();
      await _location.enableBackgroundMode(enable: false);

      final income = await _showIncomeDialog();
      await _saveTrip(income: income);

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

    } else {
      final hasPermission = await _requestPermissions();
      if (!hasPermission) return;

      await _location.enableBackgroundMode(enable: true);
      await _location.changeNotificationOptions(
        title: 'تتبع الرحلة',
        subtitle: 'يتم حساب المسافة والتكلفة الآن',
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
  }

  void _startListening() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    double maintCostPerKm = 0.0;
    if (settings.isMaintenanceEnabled && settings.maintenanceInterval > 0) {
      maintCostPerKm = settings.maintenanceCost / settings.maintenanceInterval;
    }
    _location.changeSettings(accuracy: LocationAccuracy.high, interval: 2000, distanceFilter: 2);
    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted) {
        if (_lastLocation != null) {
          final double distanceInMeters = geo.Geolocator.distanceBetween(
            _lastLocation!.latitude!,
            _lastLocation!.longitude!,
            currentLocation.latitude!,
            currentLocation.longitude!,
          );

          double newTotalDistanceInMeters = _totalDistance + distanceInMeters;
          double distanceInKm = newTotalDistanceInMeters / 1000;
          double currentFuelCost = 0.0;

          if (settings.consumptionRate > 0) {
            if (settings.consumptionMethod == ConsumptionMethod.kmPerLiter) {
              currentFuelCost = (distanceInKm / settings.consumptionRate) * settings.fuelPrice;
            } else {
              currentFuelCost = (distanceInKm / 100) * settings.consumptionRate * settings.fuelPrice;
            }
          }
          double currentMaintCost = distanceInKm * maintCostPerKm;

          setState(() {
            _prevDistanceInKm = _totalDistance / 1000;
            _prevTotalCost = _fuelCost + _maintCost;

            _totalDistance = newTotalDistanceInMeters;
            _fuelCost = currentFuelCost;
            _maintCost = currentMaintCost;
          });
        }
        _lastLocation = currentLocation;
      }
    });
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        setState(() {
          _currentDuration = DateTime.now().difference(_startTime!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettings>();
    final totalCost = _fuelCost + _maintCost;
    final durationString = "${_currentDuration.inMinutes.toString().padLeft(2, '0')}:${(_currentDuration.inSeconds % 60).toString().padLeft(2, '0')}";
    final consumptionRateText = '${settings.consumptionRate.toStringAsFixed(1)} ${settings.consumptionMethod == ConsumptionMethod.kmPerLiter ? localizations.translate('kmPerLiter') : localizations.translate('litersPer100Km')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('mainScreenTitle')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context: context,
                    icon: Icons.route_outlined,
                    title: localizations.translate('distanceTraveled'),
                    currentValue: _totalDistance / 1000,
                    previousValue: _prevDistanceInKm,
                    isCurrency: false,
                    suffix: " ${localizations.translate('kmUnit')}",
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    context: context,
                    icon: Icons.payments_outlined,
                    title: localizations.translate('currentCost'),
                    currentValue: totalCost,
                    previousValue: _prevTotalCost,
                    isCurrency: true,
                    color: Colors.orange,
                  ),
                  _buildInfoCard(
                    context: context,
                    icon: Icons.timer_outlined,
                    title: localizations.translate('tripDurationLabel'),
                    valueText: durationString,
                    color: Colors.deepPurple,
                  ),
                  _buildInfoCard(
                    context: context,
                    icon: Icons.local_gas_station_outlined,
                    title: localizations.translate('consumptionRateLabel'),
                    valueText: consumptionRateText,
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(_isTracking ? Icons.stop_circle_outlined : Icons.play_circle_outlined),
                  onPressed: _toggleTracking,
                  label: Text(_isTracking
                      ? localizations.translate('endTrip')
                      : localizations.translate('startTrip')),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 22, fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
                    backgroundColor: _isTracking ? Colors.red.shade400 : Colors.green.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required double currentValue,
    required double previousValue,
    bool isCurrency = false,
    String suffix = "",
    Color? color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final cardColor = color ?? Theme.of(context).colorScheme.primary;
    final valueStyle = textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor.withOpacity(0.8), cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: previousValue, end: currentValue),
              duration: const Duration(milliseconds: 250),
              builder: (context, value, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value.toStringAsFixed(2), style: valueStyle),
                    const SizedBox(width: 4),
                    if (isCurrency)
                      CurrencySymbol(style: valueStyle)
                    else
                      Text(suffix, style: valueStyle?.copyWith(fontSize: textTheme.titleSmall?.fontSize)),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String valueText,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valueText,
              style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
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