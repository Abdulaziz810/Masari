// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fuel Cost Tracker';

  @override
  String get mainScreenTitle => 'Fuel Cost Calculator';

  @override
  String get historyScreenTitle => 'Trip History';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get mainTab => 'Home';

  @override
  String get historyTab => 'History';

  @override
  String get settingsTab => 'Settings';

  @override
  String get distanceTraveled => 'Distance Traveled';

  @override
  String get currentCost => 'Current Cost';

  @override
  String get startTrip => 'Start Trip';

  @override
  String get endTrip => 'End Trip';

  @override
  String get kmUnit => 'km';

  @override
  String get currencyUnit => 'SAR';

  @override
  String get noTripsSaved => 'No saved trips yet.';

  @override
  String get tripCostLabel => 'Cost';

  @override
  String get tripDistanceLabel => 'Distance';

  @override
  String get tripDurationLabel => 'Duration';

  @override
  String get languageLabel => 'Language';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get fuelPriceLabel => 'Fuel price per liter (SAR)';

  @override
  String get consumptionRateLabel => 'Consumption rate';

  @override
  String get kmPerLiter => 'km/L';

  @override
  String get litersPer100Km => 'L/100 km';

  @override
  String get saveSettingsButton => 'Save settings';

  @override
  String get settingsSavedSuccess => 'Settings saved successfully';

  @override
  String get consumptionPickerTitle => 'Select consumption rate';

  @override
  String get doneButton => 'Done';

  @override
  String get enterTripIncomeTitle => 'Enter trip income';

  @override
  String get skipButton => 'Skip';

  @override
  String get saveButton => 'Save';

  @override
  String get zeroAmountPlaceholder => '0.00';

  @override
  String get maintSettingsTitle => 'Periodic maintenance costs';

  @override
  String get maintCostLabel => 'Maintenance cost (SAR)';

  @override
  String get maintIntervalLabel => 'Maintenance interval (km)';

  @override
  String get exportDataTitle => 'Export data';

  @override
  String get exportDataSubtitle => 'Save trip history as an Excel (CSV) file';

  @override
  String get exportThisMonth => 'This month';

  @override
  String get exportLastMonth => 'Last month';

  @override
  String get exportThisYear => 'This year';

  @override
  String get exportAllTime => 'All time';

  @override
  String get exportButton => 'Export';

  @override
  String get noDataToExport => 'No data to export for this period.';

  @override
  String get exportShareText => 'Trips report';

  @override
  String get exportFailedMessage => 'Failed to export the file.';

  @override
  String get headerStartDate => 'Start date';

  @override
  String get headerStartTime => 'Start time';

  @override
  String get headerDuration => 'Duration (minutes)';

  @override
  String get headerDistance => 'Distance (km)';

  @override
  String get headerIncome => 'Income (SAR)';

  @override
  String get headerFuelCost => 'Fuel cost (SAR)';

  @override
  String get headerMaintCost => 'Maintenance cost (SAR)';

  @override
  String get headerTotalCost => 'Total cost (SAR)';

  @override
  String get headerNetProfit => 'Net profit (SAR)';

  @override
  String get settingsCardGeneral => 'General';

  @override
  String get settingsCardCalculation => 'Calculations & vehicle';

  @override
  String get settingsCardData => 'Data management';

  @override
  String get clearAllDataTitle => 'Clear all data';

  @override
  String get clearAllDataSubtitle => 'Permanently delete all saved trips';

  @override
  String get clearDataConfirmationTitle => 'Confirm deletion';

  @override
  String get clearDataConfirmationContent =>
      'Are you sure? All trips and statistics will be permanently deleted and this action cannot be undone.';

  @override
  String get dataClearedSuccess => 'All data cleared successfully';

  @override
  String get locationPermissionDenied => 'Location permission was denied.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission is permanently denied. Please enable it from app settings.';

  @override
  String get backgroundLocationRecommended =>
      'Background location is recommended for accurate tracking.';

  @override
  String get enableGpsServiceMessage =>
      'Please enable GPS service on your device.';

  @override
  String get trackingNotificationTitle => 'Trip tracking';

  @override
  String get trackingNotificationSubtitle =>
      'Distance and cost are being calculated';

  @override
  String get arabicLanguageName => 'Arabic';

  @override
  String get englishLanguageName => 'English';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get editTripIncomeTitle => 'Edit trip income';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get deleteConfirmationTitle => 'Delete trip';

  @override
  String get deleteConfirmationContent =>
      'Are you sure you want to delete this trip? This action cannot be undone.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get tripDeletedSuccess => 'Trip deleted';

  @override
  String get emptyHistoryTitle => 'No trips yet';

  @override
  String get emptyHistorySubtitle =>
      'Start your first trip to see its record here!';

  @override
  String get statsWeekly => 'Weekly';

  @override
  String get statsMonthly => 'Monthly';

  @override
  String get statsYearly => 'Yearly';

  @override
  String get totalIncome => 'Total income';

  @override
  String get totalCost => 'Total cost';

  @override
  String get totalDistance => 'Total distance';

  @override
  String get totalNetProfit => 'Net profit';

  @override
  String get daySun => 'Sun';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get weekPrefix => 'W';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get minuteUnit => 'min';

  @override
  String get secondUnit => 'sec';

  @override
  String get distanceDetailsTitle => 'Distance details';

  @override
  String get distanceTotalLabel => 'Total distance';

  @override
  String get distanceTodayLabel => 'Today';

  @override
  String get distanceThisWeekLabel => 'This week';

  @override
  String get distanceThisMonthLabel => 'This month';

  @override
  String get distanceLongestLabel => 'Longest trip';

  @override
  String get distanceAvgLabel => 'Average distance';

  @override
  String get timeDetailsTitle => 'Usage time details';

  @override
  String get timeTotalLabel => 'Total time';

  @override
  String get timeTodayLabel => 'Today';

  @override
  String get timeThisWeekLabel => 'This week';

  @override
  String get timeThisMonthLabel => 'This month';

  @override
  String get timeAvgLabel => 'Average trip';

  @override
  String get historyTripsCountSuffix => 'trips logged';

  @override
  String get hideStats => 'Hide';

  @override
  String get featureTrackDistances => 'Track distances';

  @override
  String get featureCalcProfit => 'Calculate profit';

  @override
  String get featureRichStats => 'Rich statistics';

  @override
  String get tripsDetailsTitle => 'Trips details';

  @override
  String get tripsTotalLabel => 'Total trips';

  @override
  String get tripsTodayLabel => 'Today';

  @override
  String get tripsThisWeekLabel => 'This week';

  @override
  String get tripsThisMonthLabel => 'This month';

  @override
  String get consumptionDetailsTitle => 'Consumption details';

  @override
  String get consumptionCurrentLabel => 'Current consumption';

  @override
  String get closeButtonLabel => 'Close';

  @override
  String get incomeLabel => 'Income';

  @override
  String get totalTripCostLabel => 'Total cost';

  @override
  String get fuelLabel => 'Fuel';

  @override
  String get maintLabel => 'Maint.';

  @override
  String get netProfitLabel => 'Net profit';

  @override
  String get developedByLabel => 'Developed by Abdulaziz Muteb';
}
