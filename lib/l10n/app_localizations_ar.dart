// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'حاسبة تكلفة الوقود';

  @override
  String get mainScreenTitle => 'حاسبة تكلفة الوقود';

  @override
  String get historyScreenTitle => 'سجل الرحلات';

  @override
  String get settingsScreenTitle => 'الإعدادات';

  @override
  String get mainTab => 'الرئيسية';

  @override
  String get historyTab => 'السجل';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get distanceTraveled => 'المسافة المقطوعة';

  @override
  String get currentCost => 'التكلفة الحالية';

  @override
  String get startTrip => 'بدء الرحلة';

  @override
  String get endTrip => 'إنهاء الرحلة';

  @override
  String get kmUnit => 'كم';

  @override
  String get currencyUnit => 'ريال';

  @override
  String get noTripsSaved => 'لا يوجد رحلات محفوظة بعد.';

  @override
  String get tripCostLabel => 'التكلفة';

  @override
  String get tripDistanceLabel => 'المسافة';

  @override
  String get tripDurationLabel => 'المدة';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get appearanceLabel => 'المظهر';

  @override
  String get fuelPriceLabel => 'سعر لتر الوقود (بالريال)';

  @override
  String get consumptionRateLabel => 'معدل الصرفية';

  @override
  String get kmPerLiter => 'كم/لتر';

  @override
  String get litersPer100Km => 'لتر/100 كم';

  @override
  String get saveSettingsButton => 'حفظ الإعدادات';

  @override
  String get settingsSavedSuccess => 'تم حفظ الإعدادات بنجاح';

  @override
  String get consumptionPickerTitle => 'اختر معدل الصرفية';

  @override
  String get doneButton => 'تم';

  @override
  String get enterTripIncomeTitle => 'أدخل دخل الرحلة';

  @override
  String get skipButton => 'تخطي';

  @override
  String get saveButton => 'حفظ';

  @override
  String get zeroAmountPlaceholder => '0.00';

  @override
  String get maintSettingsTitle => 'حساب تكاليف الصيانة الدورية';

  @override
  String get maintCostLabel => 'تكلفة الصيانة (ريال)';

  @override
  String get maintIntervalLabel => 'فترة الصيانة (كل كم)';

  @override
  String get exportDataTitle => 'تصدير البيانات';

  @override
  String get exportDataSubtitle => 'حفظ سجل الرحلات كملف Excel (CSV)';

  @override
  String get exportThisMonth => 'هذا الشهر';

  @override
  String get exportLastMonth => 'الشهر الماضي';

  @override
  String get exportThisYear => 'هذه السنة';

  @override
  String get exportAllTime => 'كل الأوقات';

  @override
  String get exportButton => 'تصدير';

  @override
  String get noDataToExport => 'لا توجد بيانات للتصدير في هذه الفترة.';

  @override
  String get exportShareText => 'تقرير الرحلات';

  @override
  String get exportFailedMessage => 'فشل تصدير الملف.';

  @override
  String get headerStartDate => 'تاريخ البدء';

  @override
  String get headerStartTime => 'وقت البدء';

  @override
  String get headerDuration => 'مدة الرحلة (دقائق)';

  @override
  String get headerDistance => 'المسافة (كم)';

  @override
  String get headerIncome => 'الدخل (ريال)';

  @override
  String get headerFuelCost => 'تكلفة الوقود (ريال)';

  @override
  String get headerMaintCost => 'تكلفة الصيانة (ريال)';

  @override
  String get headerTotalCost => 'التكلفة الإجمالية (ريال)';

  @override
  String get headerNetProfit => 'صافي الربح (ريال)';

  @override
  String get settingsCardGeneral => 'عام';

  @override
  String get settingsCardCalculation => 'الحسابات والمركبة';

  @override
  String get settingsCardData => 'إدارة البيانات';

  @override
  String get clearAllDataTitle => 'مسح كل البيانات';

  @override
  String get clearAllDataSubtitle => 'حذف كل الرحلات المحفوظة نهائياً';

  @override
  String get clearDataConfirmationTitle => 'تأكيد المسح';

  @override
  String get clearDataConfirmationContent =>
      'هل أنت متأكد؟ سيتم حذف جميع الرحلات والإحصائيات نهائياً ولا يمكن التراجع.';

  @override
  String get dataClearedSuccess => 'تم مسح البيانات بنجاح';

  @override
  String get locationPermissionDenied => 'تم رفض صلاحية الموقع.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'صلاحية الموقع مرفوضة دائماً. فعّلها من إعدادات التطبيق.';

  @override
  String get backgroundLocationRecommended =>
      'تشغيل الموقع في الخلفية يعطي تتبع أدق.';

  @override
  String get enableGpsServiceMessage => 'فعّل خدمة GPS في جهازك.';

  @override
  String get trackingNotificationTitle => 'تتبع الرحلة';

  @override
  String get trackingNotificationSubtitle => 'يتم حساب المسافة والتكلفة الآن';

  @override
  String get arabicLanguageName => 'العربية';

  @override
  String get englishLanguageName => 'English';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get dateToday => 'اليوم';

  @override
  String get dateYesterday => 'الأمس';

  @override
  String get editTripIncomeTitle => 'تعديل دخل الرحلة';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get saveChangesButton => 'حفظ التعديل';

  @override
  String get deleteConfirmationTitle => 'تأكيد الحذف';

  @override
  String get deleteConfirmationContent =>
      'هل أنت متأكد من حذف هذه الرحلة؟ لا يمكن التراجع.';

  @override
  String get deleteButton => 'حذف';

  @override
  String get tripDeletedSuccess => 'تم حذف الرحلة';

  @override
  String get emptyHistoryTitle => 'لا يوجد رحلات بعد';

  @override
  String get emptyHistorySubtitle => 'ابدأ رحلتك الأولى لتظهر هنا.';

  @override
  String get statsWeekly => 'أسبوعي';

  @override
  String get statsMonthly => 'شهري';

  @override
  String get statsYearly => 'سنوي';

  @override
  String get totalIncome => 'إجمالي الدخل';

  @override
  String get totalCost => 'إجمالي التكلفة';

  @override
  String get totalDistance => 'إجمالي المسافة';

  @override
  String get totalNetProfit => 'صافي الربح';

  @override
  String get daySun => 'أحد';

  @override
  String get dayMon => 'اثنين';

  @override
  String get dayTue => 'ثلاثاء';

  @override
  String get dayWed => 'أربعاء';

  @override
  String get dayThu => 'خميس';

  @override
  String get dayFri => 'جمعة';

  @override
  String get daySat => 'سبت';

  @override
  String get weekPrefix => 'أ';

  @override
  String get monthJan => 'ينا';

  @override
  String get monthFeb => 'فبر';

  @override
  String get monthMar => 'مار';

  @override
  String get monthApr => 'أبر';

  @override
  String get monthMay => 'ماي';

  @override
  String get monthJun => 'يون';

  @override
  String get monthJul => 'يول';

  @override
  String get monthAug => 'أغس';

  @override
  String get monthSep => 'سبت';

  @override
  String get monthOct => 'أكت';

  @override
  String get monthNov => 'نوف';

  @override
  String get monthDec => 'ديس';

  @override
  String get minuteUnit => 'دقيقة';

  @override
  String get secondUnit => 'ثانية';

  @override
  String get distanceDetailsTitle => 'تفاصيل المسافة';

  @override
  String get distanceTotalLabel => 'إجمالي المسافة';

  @override
  String get distanceTodayLabel => 'اليوم';

  @override
  String get distanceThisWeekLabel => 'هذا الأسبوع';

  @override
  String get distanceThisMonthLabel => 'هذا الشهر';

  @override
  String get distanceLongestLabel => 'أطول رحلة';

  @override
  String get distanceAvgLabel => 'متوسط المسافة';

  @override
  String get timeDetailsTitle => 'تفاصيل وقت الاستخدام';

  @override
  String get timeTotalLabel => 'إجمالي الوقت';

  @override
  String get timeTodayLabel => 'اليوم';

  @override
  String get timeThisWeekLabel => 'هذا الأسبوع';

  @override
  String get timeThisMonthLabel => 'هذا الشهر';

  @override
  String get timeAvgLabel => 'متوسط الرحلة';

  @override
  String get historyTripsCountSuffix => 'رحلة مسجلة';

  @override
  String get hideStats => 'إخفاء';

  @override
  String get featureTrackDistances => 'تتبع المسافات';

  @override
  String get featureCalcProfit => 'حساب الأرباح';

  @override
  String get featureRichStats => 'إحصائيات مفصلة';

  @override
  String get tripsDetailsTitle => 'تفاصيل الرحلات';

  @override
  String get tripsTotalLabel => 'إجمالي الرحلات';

  @override
  String get tripsTodayLabel => 'اليوم';

  @override
  String get tripsThisWeekLabel => 'هذا الأسبوع';

  @override
  String get tripsThisMonthLabel => 'هذا الشهر';

  @override
  String get consumptionDetailsTitle => 'تفاصيل الاستهلاك';

  @override
  String get consumptionCurrentLabel => 'الاستهلاك الحالي';

  @override
  String get closeButtonLabel => 'إغلاق';

  @override
  String get incomeLabel => 'الدخل';

  @override
  String get totalTripCostLabel => 'التكلفة الإجمالية';

  @override
  String get fuelLabel => 'وقود';

  @override
  String get maintLabel => 'صيانة';

  @override
  String get netProfitLabel => 'صافي الربح';

  @override
  String get developedByLabel => 'Developed by Abdulaziz Muteb';
}
