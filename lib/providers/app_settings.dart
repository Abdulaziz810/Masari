import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys
const String prefFuelPrice = 'fuelPrice';
const String prefConsumptionRate = 'consumptionRate';
const String prefConsumptionMethod = 'consumptionMethod';
const String prefIsDarkMode = 'isDarkMode';
const String prefLanguageCode = 'languageCode';
const String prefMaintEnabled = 'maintEnabled';
const String prefMaintCost = 'maintCost';
const String prefMaintInterval = 'maintInterval';

enum ConsumptionMethod { kmPerLiter, litersPer100Km }

class AppSettings extends ChangeNotifier {
  late SharedPreferences _prefs;

  double _fuelPrice = 0.0;
  double _consumptionRate = 10.0;
  ConsumptionMethod _consumptionMethod = ConsumptionMethod.kmPerLiter;
  bool _isDarkMode = false;
  Locale? _appLocale;

  // Maintenance Settings
  bool _isMaintenanceEnabled = false;
  double _maintenanceCost = 0.0;
  int _maintenanceInterval = 10000;

  double get fuelPrice => _fuelPrice;
  double get consumptionRate => _consumptionRate;
  ConsumptionMethod get consumptionMethod => _consumptionMethod;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  Locale? get appLocale => _appLocale;

  bool get isMaintenanceEnabled => _isMaintenanceEnabled;
  double get maintenanceCost => _maintenanceCost;
  int get maintenanceInterval => _maintenanceInterval;

  AppSettings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _fuelPrice = _prefs.getDouble(prefFuelPrice) ?? 0.0;
    _consumptionRate = _prefs.getDouble(prefConsumptionRate) ?? 10.0;
    int methodIndex = _prefs.getInt(prefConsumptionMethod) ?? 0;
    _consumptionMethod = ConsumptionMethod.values[methodIndex];
    _isDarkMode = _prefs.getBool(prefIsDarkMode) ?? false;
    String? languageCode = _prefs.getString(prefLanguageCode);
    if (languageCode != null) {
      _appLocale = Locale(languageCode);
    }

    _isMaintenanceEnabled = _prefs.getBool(prefMaintEnabled) ?? false;
    _maintenanceCost = _prefs.getDouble(prefMaintCost) ?? 0.0;
    _maintenanceInterval = _prefs.getInt(prefMaintInterval) ?? 10000;

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _appLocale = locale;
    await _prefs.setString(prefLanguageCode, locale.languageCode);
    notifyListeners();
  }

  Future<void> setFuelPrice(double price) async {
    _fuelPrice = price;
    await _prefs.setDouble(prefFuelPrice, price);
    notifyListeners();
  }

  Future<void> setConsumption(double rate, ConsumptionMethod method) async {
    _consumptionRate = rate;
    _consumptionMethod = method;
    await _prefs.setDouble(prefConsumptionRate, rate);
    await _prefs.setInt(prefConsumptionMethod, method.index);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool(prefIsDarkMode, isDark);
    notifyListeners();
  }

  Future<void> setMaintenanceSettings({
    required bool isEnabled,
    required double cost,
    required int interval,
  }) async {
    _isMaintenanceEnabled = isEnabled;
    _maintenanceCost = cost;
    _maintenanceInterval = interval;
    await _prefs.setBool(prefMaintEnabled, isEnabled);
    await _prefs.setDouble(prefMaintCost, cost);
    await _prefs.setInt(prefMaintInterval, interval);
    notifyListeners();
  }
}