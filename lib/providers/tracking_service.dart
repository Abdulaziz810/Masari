import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class TrackingService extends ChangeNotifier {
  // الحالة
  bool _isTracking = false;
  bool _isPaused = false; // إيقاف تلقائي عند الثبات
  DateTime? _startTime;
  DateTime? _lastAcceptedTs;

  // القيم المتراكمة
  double _totalDistanceMeters = 0.0;
  Duration _duration = Duration.zero;

  // معلومات آخر نقطة
  Position? _lastPosition;
  double? _lastAccuracy; // بالمتر
  DateTime? _lastUpdate;

  // بثّ الموقع
  StreamSubscription<Position>? _sub;

  // إعدادات الفلترة
  static const double kMaxAccuracy = 40;     // تجاهل القراءة إذا الدقة أسوأ من 40م
  static const double kJitterMeters = 6;     // تجاهل القفزات الصغيرة < 6م
  static const double kMaxSpeedKmh = 150;    // تجاهل القفزة إن السرعة المحسوبة غير منطقية
  static const Duration kAutoPauseAfter = Duration(minutes: 2); // توقّف تلقائي بعد 2 دقيقة بدون حركة مقبولة

  // قراءة الحالة
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  double get totalDistanceMeters => _totalDistanceMeters;
  Duration get duration => _duration;
  double? get lastAccuracy => _lastAccuracy;
  DateTime? get lastUpdate => _lastUpdate;

  // دقّة نصّية بسيطة
  String get accuracyLabel {
    final a = _lastAccuracy ?? 999;
    if (a <= 15) return 'Excellent';
    if (a <= 30) return 'Good';
    if (a <= 50) return 'Fair';
    return 'Weak';
  }

  Future<bool> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  Future<void> start() async {
    if (_isTracking) return;
    final ok = await _ensurePermissions();
    if (!ok) return;

    _reset();
    _isTracking = true;
    _startTime = DateTime.now();
    _lastAcceptedTs = _startTime;

    // إعدادات البث: دقّة عالية + فلتر مسافة مبدئي
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // متر — نبقيه صغير ونفلتر يدويًا أيضاً
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(_onPosition,
        onError: (e, st) {
          stop();
        });

    // مؤقت بسيط لتحديث المدة كل ثانية
    _ticker();
    notifyListeners();
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _isTracking = false;
    _isPaused = false;
    _lastPosition = null;
    notifyListeners();
  }

  void _reset() {
    _totalDistanceMeters = 0.0;
    _duration = Duration.zero;
    _lastPosition = null;
    _lastAccuracy = null;
    _lastUpdate = null;
    _isPaused = false;
  }

  void _onPosition(Position p) {
    _lastAccuracy = p.accuracy;
    _lastUpdate = DateTime.now();

    // 1) فلترة الدقّة
    if (p.accuracy.isNaN || p.accuracy > kMaxAccuracy) {
      _checkAutoPause();
      notifyListeners();
      return;
    }

    if (_lastPosition == null) {
      _lastPosition = p;
      _lastAcceptedTs = DateTime.now();
      _isPaused = false;
      notifyListeners();
      return;
    }

    // 2) حساب المسافة
    final d = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      p.latitude,
      p.longitude,
    );

    // 3) فلترة الاهتزازات الصغيرة
    if (d < kJitterMeters) {
      _checkAutoPause();
      notifyListeners();
      return;
    }

    // 4) فلترة القفزات غير المنطقية (سرعة عالية)
    final dtSec =
        (p.timestamp ?? DateTime.now()).difference(_lastPosition!.timestamp ?? DateTime.now()).inMilliseconds / 1000.0;
    if (dtSec > 0) {
      final speedKmh = (d / dtSec) * 3.6;
      if (speedKmh > kMaxSpeedKmh) {
        _checkAutoPause();
        notifyListeners();
        return;
      }
    }

    // 5) قبول الحركة
    _totalDistanceMeters += d;
    _lastPosition = p;
    _lastAcceptedTs = DateTime.now();
    _isPaused = false;
    notifyListeners();
  }

  void _checkAutoPause() {
    if (_lastAcceptedTs == null) return;
    final noMoveFor = DateTime.now().difference(_lastAcceptedTs!);
    _isPaused = noMoveFor >= kAutoPauseAfter;
  }

  void _ticker() async {
    // محدّث مدة بسيط
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isTracking) {
        t.cancel();
        return;
      }
      if (_startTime == null) return;
      _duration = DateTime.now().difference(_startTime!);
      _checkAutoPause();
      notifyListeners();
    });
  }
}
