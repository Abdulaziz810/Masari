import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fuel Cost Tracker'**
  String get appName;

  /// No description provided for @mainScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Fuel Cost Calculator'**
  String get mainScreenTitle;

  /// No description provided for @historyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get historyScreenTitle;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @mainTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mainTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @distanceTraveled.
  ///
  /// In en, this message translates to:
  /// **'Distance Traveled'**
  String get distanceTraveled;

  /// No description provided for @currentCost.
  ///
  /// In en, this message translates to:
  /// **'Current Cost'**
  String get currentCost;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTrip;

  /// No description provided for @endTrip.
  ///
  /// In en, this message translates to:
  /// **'End Trip'**
  String get endTrip;

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kmUnit;

  /// No description provided for @currencyUnit.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currencyUnit;

  /// No description provided for @noTripsSaved.
  ///
  /// In en, this message translates to:
  /// **'No saved trips yet.'**
  String get noTripsSaved;

  /// No description provided for @tripCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get tripCostLabel;

  /// No description provided for @tripDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get tripDistanceLabel;

  /// No description provided for @tripDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get tripDurationLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// No description provided for @fuelPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuel price per liter (SAR)'**
  String get fuelPriceLabel;

  /// No description provided for @consumptionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Consumption rate'**
  String get consumptionRateLabel;

  /// No description provided for @kmPerLiter.
  ///
  /// In en, this message translates to:
  /// **'km/L'**
  String get kmPerLiter;

  /// No description provided for @litersPer100Km.
  ///
  /// In en, this message translates to:
  /// **'L/100 km'**
  String get litersPer100Km;

  /// No description provided for @saveSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettingsButton;

  /// No description provided for @settingsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccess;

  /// No description provided for @consumptionPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select consumption rate'**
  String get consumptionPickerTitle;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @enterTripIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter trip income'**
  String get enterTripIncomeTitle;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @zeroAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get zeroAmountPlaceholder;

  /// No description provided for @maintSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Periodic maintenance costs'**
  String get maintSettingsTitle;

  /// No description provided for @maintCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance cost (SAR)'**
  String get maintCostLabel;

  /// No description provided for @maintIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance interval (km)'**
  String get maintIntervalLabel;

  /// No description provided for @exportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportDataTitle;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save trip history as an Excel (CSV) file'**
  String get exportDataSubtitle;

  /// No description provided for @exportThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get exportThisMonth;

  /// No description provided for @exportLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get exportLastMonth;

  /// No description provided for @exportThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get exportThisYear;

  /// No description provided for @exportAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get exportAllTime;

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// No description provided for @noDataToExport.
  ///
  /// In en, this message translates to:
  /// **'No data to export for this period.'**
  String get noDataToExport;

  /// No description provided for @exportShareText.
  ///
  /// In en, this message translates to:
  /// **'Trips report'**
  String get exportShareText;

  /// No description provided for @exportFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to export the file.'**
  String get exportFailedMessage;

  /// No description provided for @headerStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get headerStartDate;

  /// No description provided for @headerStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get headerStartTime;

  /// No description provided for @headerDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get headerDuration;

  /// No description provided for @headerDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get headerDistance;

  /// No description provided for @headerIncome.
  ///
  /// In en, this message translates to:
  /// **'Income (SAR)'**
  String get headerIncome;

  /// No description provided for @headerFuelCost.
  ///
  /// In en, this message translates to:
  /// **'Fuel cost (SAR)'**
  String get headerFuelCost;

  /// No description provided for @headerMaintCost.
  ///
  /// In en, this message translates to:
  /// **'Maintenance cost (SAR)'**
  String get headerMaintCost;

  /// No description provided for @headerTotalCost.
  ///
  /// In en, this message translates to:
  /// **'Total cost (SAR)'**
  String get headerTotalCost;

  /// No description provided for @headerNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit (SAR)'**
  String get headerNetProfit;

  /// No description provided for @settingsCardGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsCardGeneral;

  /// No description provided for @settingsCardCalculation.
  ///
  /// In en, this message translates to:
  /// **'Calculations & vehicle'**
  String get settingsCardCalculation;

  /// No description provided for @settingsCardData.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get settingsCardData;

  /// No description provided for @clearAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all saved trips'**
  String get clearAllDataSubtitle;

  /// No description provided for @clearDataConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get clearDataConfirmationTitle;

  /// No description provided for @clearDataConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? All trips and statistics will be permanently deleted and this action cannot be undone.'**
  String get clearDataConfirmationContent;

  /// No description provided for @dataClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully'**
  String get dataClearedSuccess;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it from app settings.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @backgroundLocationRecommended.
  ///
  /// In en, this message translates to:
  /// **'Background location is recommended for accurate tracking.'**
  String get backgroundLocationRecommended;

  /// No description provided for @enableGpsServiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable GPS service on your device.'**
  String get enableGpsServiceMessage;

  /// No description provided for @trackingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip tracking'**
  String get trackingNotificationTitle;

  /// No description provided for @trackingNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Distance and cost are being calculated'**
  String get trackingNotificationSubtitle;

  /// No description provided for @arabicLanguageName.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLanguageName;

  /// No description provided for @englishLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguageName;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @editTripIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit trip income'**
  String get editTripIncomeTitle;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesButton;

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get deleteConfirmationTitle;

  /// No description provided for @deleteConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trip? This action cannot be undone.'**
  String get deleteConfirmationContent;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @tripDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted'**
  String get tripDeletedSuccess;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first trip to see its record here!'**
  String get emptyHistorySubtitle;

  /// No description provided for @statsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get statsWeekly;

  /// No description provided for @statsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get statsMonthly;

  /// No description provided for @statsYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get statsYearly;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get totalIncome;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get totalCost;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total distance'**
  String get totalDistance;

  /// No description provided for @totalNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get totalNetProfit;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @weekPrefix.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekPrefix;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @minuteUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minuteUnit;

  /// No description provided for @secondUnit.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secondUnit;

  /// No description provided for @distanceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Distance details'**
  String get distanceDetailsTitle;

  /// No description provided for @distanceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total distance'**
  String get distanceTotalLabel;

  /// No description provided for @distanceTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get distanceTodayLabel;

  /// No description provided for @distanceThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get distanceThisWeekLabel;

  /// No description provided for @distanceThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get distanceThisMonthLabel;

  /// No description provided for @distanceLongestLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest trip'**
  String get distanceLongestLabel;

  /// No description provided for @distanceAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'Average distance'**
  String get distanceAvgLabel;

  /// No description provided for @timeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage time details'**
  String get timeDetailsTitle;

  /// No description provided for @timeTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get timeTotalLabel;

  /// No description provided for @timeTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timeTodayLabel;

  /// No description provided for @timeThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get timeThisWeekLabel;

  /// No description provided for @timeThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get timeThisMonthLabel;

  /// No description provided for @timeAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'Average trip'**
  String get timeAvgLabel;

  /// No description provided for @historyTripsCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'trips logged'**
  String get historyTripsCountSuffix;

  /// No description provided for @hideStats.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideStats;

  /// No description provided for @featureTrackDistances.
  ///
  /// In en, this message translates to:
  /// **'Track distances'**
  String get featureTrackDistances;

  /// No description provided for @featureCalcProfit.
  ///
  /// In en, this message translates to:
  /// **'Calculate profit'**
  String get featureCalcProfit;

  /// No description provided for @featureRichStats.
  ///
  /// In en, this message translates to:
  /// **'Rich statistics'**
  String get featureRichStats;

  /// No description provided for @tripsDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips details'**
  String get tripsDetailsTitle;

  /// No description provided for @tripsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total trips'**
  String get tripsTotalLabel;

  /// No description provided for @tripsTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tripsTodayLabel;

  /// No description provided for @tripsThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get tripsThisWeekLabel;

  /// No description provided for @tripsThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get tripsThisMonthLabel;

  /// No description provided for @consumptionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Consumption details'**
  String get consumptionDetailsTitle;

  /// No description provided for @consumptionCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current consumption'**
  String get consumptionCurrentLabel;

  /// No description provided for @closeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonLabel;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @totalTripCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get totalTripCostLabel;

  /// No description provided for @fuelLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelLabel;

  /// No description provided for @maintLabel.
  ///
  /// In en, this message translates to:
  /// **'Maint.'**
  String get maintLabel;

  /// No description provided for @netProfitLabel.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get netProfitLabel;

  /// No description provided for @developedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Developed by Abdulaziz Muteb'**
  String get developedByLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
