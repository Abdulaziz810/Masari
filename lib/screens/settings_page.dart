import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tracking_cost/localization/app_localizations.dart';
import 'package:tracking_cost/models/trip_model.dart';
import '../providers/app_settings.dart';

enum ExportPeriod { thisMonth, lastMonth, thisYear, allTime }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _priceController;
  late bool _isMaintEnabled;
  late TextEditingController _maintCostController;
  late TextEditingController _maintIntervalController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettings>(context, listen: false);
    _priceController = TextEditingController(text: settings.fuelPrice.toString());
    _isMaintEnabled = settings.isMaintenanceEnabled;
    _maintCostController = TextEditingController(text: settings.maintenanceCost.toString());
    _maintIntervalController = TextEditingController(text: settings.maintenanceInterval.toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _maintCostController.dispose();
    _maintIntervalController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    settings.setFuelPrice(double.tryParse(_priceController.text) ?? 0.0);

    settings.setMaintenanceSettings(
      isEnabled: _isMaintEnabled,
      cost: double.tryParse(_maintCostController.text) ?? 0.0,
      interval: int.tryParse(_maintIntervalController.text) ?? 10000,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.translate('settingsSavedSuccess'))),
    );
  }

  void _showConsumptionPicker() {
    final settings = context.read<AppSettings>();
    final localizations = AppLocalizations.of(context)!;

    int tempInteger = settings.consumptionRate.toInt();
    int tempDecimal = ((settings.consumptionRate - tempInteger) * 10).round();
    ConsumptionMethod tempMethod = settings.consumptionMethod;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isArabic = Localizations.localeOf(context).languageCode == 'ar';

            final integerPicker = NumberPicker(
              minValue: 0,
              maxValue: 100,
              value: tempInteger,
              onChanged: (value) => setModalState(() => tempInteger = value),
              textStyle: const TextStyle(fontSize: 20),
              selectedTextStyle: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.primary),
              itemHeight: 50,
            );

            final decimalPicker = NumberPicker(
              minValue: 0,
              maxValue: 9,
              value: tempDecimal,
              onChanged: (value) => setModalState(() => tempDecimal = value),
              textStyle: const TextStyle(fontSize: 20),
              selectedTextStyle: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.primary),
              itemHeight: 50,
            );

            final decimalPoint = const Text(".",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold));

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations.translate('consumptionPickerTitle'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    isSelected: [
                      tempMethod == ConsumptionMethod.kmPerLiter,
                      tempMethod == ConsumptionMethod.litersPer100Km
                    ],
                    onPressed: (index) {
                      setModalState(() {
                        tempMethod = ConsumptionMethod.values[index];
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child:
                          Text(localizations.translate('kmPerLiter'))),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                              localizations.translate('litersPer100Km'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: isArabic
                        ? [decimalPicker, decimalPoint, integerPicker]
                        : [integerPicker, decimalPoint, decimalPicker],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final newRate = tempInteger + (tempDecimal / 10.0);
                      context.read<AppSettings>().setConsumption(newRate, tempMethod);
                      Navigator.of(context).pop();
                    },
                    child: Text(localizations.translate('doneButton')),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showExportDialog() async {
    ExportPeriod? selectedPeriod = ExportPeriod.thisMonth;
    final localizations = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.translate('exportDataTitle')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ExportPeriod>(title: Text(localizations.translate('exportThisMonth')), value: ExportPeriod.thisMonth, groupValue: selectedPeriod, onChanged: (value) => setDialogState(() => selectedPeriod = value)),
                  RadioListTile<ExportPeriod>(title: Text(localizations.translate('exportLastMonth')), value: ExportPeriod.lastMonth, groupValue: selectedPeriod, onChanged: (value) => setDialogState(() => selectedPeriod = value)),
                  RadioListTile<ExportPeriod>(title: Text(localizations.translate('exportThisYear')), value: ExportPeriod.thisYear, groupValue: selectedPeriod, onChanged: (value) => setDialogState(() => selectedPeriod = value)),
                  RadioListTile<ExportPeriod>(title: Text(localizations.translate('exportAllTime')), value: ExportPeriod.allTime, groupValue: selectedPeriod, onChanged: (value) => setDialogState(() => selectedPeriod = value)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations.translate('cancelButton'))),
                ElevatedButton(
                  onPressed: () {
                    if (selectedPeriod != null) {
                      Navigator.of(context).pop();
                      _exportData(selectedPeriod!);
                    }
                  },
                  child: Text(localizations.translate('exportButton')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportData(ExportPeriod period) async {
    final localizations = AppLocalizations.of(context)!;
    final box = Hive.box<Trip>('trips');
    List<Trip> allTrips = box.values.toList();
    List<Trip> filteredTrips;
    final now = DateTime.now();
    switch (period) {
      case ExportPeriod.thisMonth:
        filteredTrips = allTrips.where((trip) => trip.startTime.month == now.month && trip.startTime.year == now.year).toList();
        break;
      case ExportPeriod.lastMonth:
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final year = now.month == 1 ? now.year - 1 : now.year;
        filteredTrips = allTrips.where((trip) => trip.startTime.month == lastMonth && trip.startTime.year == year).toList();
        break;
      case ExportPeriod.thisYear:
        filteredTrips = allTrips.where((trip) => trip.startTime.year == now.year).toList();
        break;
      case ExportPeriod.allTime:
        filteredTrips = allTrips;
        break;
    }
    if (filteredTrips.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.translate('noDataToExport'))));
      }
      return;
    }
    List<List<dynamic>> rows = [];
    rows.add([
      localizations.translate('headerStartDate'), localizations.translate('headerStartTime'), localizations.translate('headerDuration'),
      localizations.translate('headerDistance'), localizations.translate('headerIncome'), localizations.translate('headerFuelCost'),
      localizations.translate('headerMaintCost'), localizations.translate('headerTotalCost'), localizations.translate('headerNetProfit')
    ]);
    for (var trip in filteredTrips) {
      rows.add([
        DateFormat('yyyy/MM/dd').format(trip.startTime), DateFormat('HH:mm').format(trip.startTime),
        (trip.duration.inSeconds / 60).toStringAsFixed(1), (trip.distance / 1000).toStringAsFixed(2),
        trip.income.toStringAsFixed(2), trip.fuelCost.toStringAsFixed(2), trip.maintenanceCost.toStringAsFixed(2),
        trip.totalCost.toStringAsFixed(2), trip.netProfit.toStringAsFixed(2),
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    try {
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File(path);
      await file.writeAsBytes([0xEF, 0xBB, 0xBF]); // BOM for UTF-8
      await file.writeAsString(csv, mode: FileMode.append);
      await Share.shareXFiles([XFile(path)], text: localizations.translate('exportShareText'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل تصدير الملف: $e")));
      }
    }
  }

  Future<void> _clearAllData() async {
    final box = Hive.box<Trip>('trips');
    await box.clear();
    if (mounted) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.translate('dataClearedSuccess'))));
    }
  }

  Future<void> _showClearDataDialog() async {
    final localizations = AppLocalizations.of(context)!;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.translate('clearDataConfirmationTitle')),
          content: Text(localizations.translate('clearDataConfirmationContent')),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations.translate('cancelButton'))),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllData();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(localizations.translate('deleteButton')),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settingsScreenTitle')),
        centerTitle: true,
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, child) {
          final textTheme = Theme.of(context).textTheme;
          final currentLocale = settings.appLocale ?? Localizations.localeOf(context);
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSettingsCard(
                context,
                title: localizations.translate('settingsCardGeneral'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(localizations.translate('languageLabel')),
                    trailing: ToggleButtons(
                      isSelected: [ currentLocale.languageCode == 'ar', currentLocale.languageCode == 'en' ],
                      onPressed: (index) {
                        context.read<AppSettings>().setLocale(index == 0 ? const Locale('ar') : const Locale('en'));
                      },
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('العربية')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('English')),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text(localizations.translate('appearanceLabel')),
                    trailing: ToggleButtons(
                      isSelected: [!settings.isDarkMode, settings.isDarkMode],
                      onPressed: (index) {
                        context.read<AppSettings>().setDarkMode(index == 1);
                      },
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.light_mode)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.dark_mode)),
                      ],
                    ),
                  ),
                ],
              ),
              _buildSettingsCard(
                context,
                title: localizations.translate('settingsCardCalculation'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('fuelPriceLabel'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_gas_station),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  ListTile(
                    title: Text(localizations.translate('consumptionRateLabel')),
                    trailing: Text(
                      '${settings.consumptionRate.toStringAsFixed(1)} ${settings.consumptionMethod == ConsumptionMethod.kmPerLiter ? localizations.translate('kmPerLiter') : localizations.translate('litersPer100Km')}',
                      style: textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    onTap: _showConsumptionPicker,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text(localizations.translate('maintSettingsTitle')),
                    value: _isMaintEnabled,
                    onChanged: (bool value) { setState(() { _isMaintEnabled = value; }); },
                  ),
                  if (_isMaintEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _maintCostController,
                            decoration: InputDecoration(labelText: localizations.translate('maintCostLabel')),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _maintIntervalController,
                            decoration: InputDecoration(labelText: localizations.translate('maintIntervalLabel')),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              _buildSettingsCard(
                context,
                title: localizations.translate('settingsCardData'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.import_export),
                    title: Text(localizations.translate('exportDataTitle')),
                    subtitle: Text(localizations.translate('exportDataSubtitle')),
                    onTap: _showExportDialog,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                    title: Text(
                      localizations.translate('clearAllDataTitle'),
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    subtitle: Text(localizations.translate('clearAllDataSubtitle')),
                    onTap: _showClearDataDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: Text(localizations.translate('saveSettingsButton')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Developed by Abdulaziz Muteb",
                style: textTheme.bodySmall,
              ),
              Text(
                "for.business.am@gmail.com",
                style: textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ...children,
        ],
      ),
    );
  }
}