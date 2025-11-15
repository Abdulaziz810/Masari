import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مفاتيح التخزين المحلي
const String prefFuelPrice = 'fuelPrice';
const String prefConsumptionRate = 'consumptionRate';
const String prefConsumptionMethod = 'consumptionMethod';
const String prefIsDarkMode = 'isDarkMode';
const String prefLanguageCode = 'languageCode';
const String prefMaintEnabled = 'maintEnabled';
const String prefMaintCost = 'maintCost';
const String prefMaintInterval = 'maintInterval';

/// طريقة حساب استهلاك السيارة:
/// - kmPerLiter: مثال 15 كم لكل لتر
/// - litersPer100Km: مثال 8 لتر لكل 100 كم
enum ConsumptionMethod { kmPerLiter, litersPer100Km }

/// هذا المزود مسؤول عن:
/// - تحميل/حفظ الإعدادات من SharedPreferences
/// - توفير ThemeMode
/// - توفير اللغة الحالية
/// - إعدادات الوقود والصيانة
///
/// ملاحظة:
/// ما في نصوص هنا. الواجهة هي اللي تترجم.
class AppSettings extends ChangeNotifier {
  SharedPreferences? _prefs;

  // قيم افتراضية معقولة
  double _fuelPrice = 0.0;
  double _consumptionRate = 10.0;
  ConsumptionMethod _consumptionMethod = ConsumptionMethod.kmPerLiter;
  bool _isDarkMode = false;
  Locale? _appLocale;

  // الصيانة
  bool _isMaintenanceEnabled = false;
  double _maintenanceCost = 0.0;
  int _maintenanceInterval = 10000;

  // getters
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

  /// تحميل كل الإعدادات مرة وحدة من التخزين
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    _fuelPrice = prefs.getDouble(prefFuelPrice) ?? 0.0;
    _consumptionRate = prefs.getDouble(prefConsumptionRate) ?? 10.0;

    final methodIndex = prefs.getInt(prefConsumptionMethod) ?? 0;
    _consumptionMethod = ConsumptionMethod.values[methodIndex];

    _isDarkMode = prefs.getBool(prefIsDarkMode) ?? false;

    final languageCode = prefs.getString(prefLanguageCode);
    if (languageCode != null && languageCode.isNotEmpty) {
      // نخزن بس الكود. الدولة (countryCode) تتحدد من ملف الترجمة.
      _appLocale = Locale(languageCode);
    }

    _isMaintenanceEnabled = prefs.getBool(prefMaintEnabled) ?? false;
    _maintenanceCost = prefs.getDouble(prefMaintCost) ?? 0.0;
    _maintenanceInterval = prefs.getInt(prefMaintInterval) ?? 10000;

    notifyListeners();
  }

  /// عشان ما نخرب لو الواجهة نادت setLocale قبل ما يخلص _loadSettings
  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// تغيير اللغة. يقبل أي كود لغة (ar, en, fr, de, ...).
  Future<void> setLocale(Locale locale) async {
    _appLocale = locale;
    final prefs = await _ensurePrefs();
    await prefs.setString(prefLanguageCode, locale.languageCode);
    notifyListeners();
  }

  /// سعر الوقود لكل لتر
  Future<void> setFuelPrice(double price) async {
    _fuelPrice = price;
    final prefs = await _ensurePrefs();
    await prefs.setDouble(prefFuelPrice, price);
    notifyListeners();
  }

  /// صرفية السيارة + الطريقة
  Future<void> setConsumption(double rate, ConsumptionMethod method) async {
    _consumptionRate = rate;
    _consumptionMethod = method;
    final prefs = await _ensurePrefs();
    await prefs.setDouble(prefConsumptionRate, rate);
    await prefs.setInt(prefConsumptionMethod, method.index);
    notifyListeners();
  }

  /// الثيم
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await _ensurePrefs();
    await prefs.setBool(prefIsDarkMode, isDark);
    notifyListeners();
  }

  /// إعدادات الصيانة الدورية
  Future<void> setMaintenanceSettings({
    required bool isEnabled,
    required double cost,
    required int interval,
  }) async {
    _isMaintenanceEnabled = isEnabled;
    _maintenanceCost = cost;
    _maintenanceInterval = interval;

    final prefs = await _ensurePrefs();
    await prefs.setBool(prefMaintEnabled, isEnabled);
    await prefs.setDouble(prefMaintCost, cost);
    await prefs.setInt(prefMaintInterval, interval);

    notifyListeners();
  }

  /// اختيارية: لو لاحقًا تبي زر "إرجاع الإعدادات الافتراضية"
  Future<void> resetToDefaults() async {
    _fuelPrice = 0.0;
    _consumptionRate = 10.0;
    _consumptionMethod = ConsumptionMethod.kmPerLiter;
    _isDarkMode = false;
    _appLocale = null;

    _isMaintenanceEnabled = false;
    _maintenanceCost = 0.0;
    _maintenanceInterval = 10000;

    final prefs = await _ensurePrefs();
    await prefs.remove(prefFuelPrice);
    await prefs.remove(prefConsumptionRate);
    await prefs.remove(prefConsumptionMethod);
    await prefs.remove(prefIsDarkMode);
    await prefs.remove(prefLanguageCode);
    await prefs.remove(prefMaintEnabled);
    await prefs.remove(prefMaintCost);
    await prefs.remove(prefMaintInterval);

    notifyListeners();
  }
}
