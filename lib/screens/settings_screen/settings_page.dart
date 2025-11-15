import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'components.dart';
import 'modals.dart';
import 'sheets.dart';

import 'package:tracking_cost/l10n/app_localizations.dart';
import 'package:tracking_cost/models/trip_model.dart';
import '../../providers/app_settings.dart';
import 'package:tracking_cost/theme/app_theme.dart';

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
    final s = Provider.of<AppSettings>(context, listen: false);
    _priceController = TextEditingController(text: s.fuelPrice.toString());
    _isMaintEnabled = s.isMaintenanceEnabled;
    _maintCostController = TextEditingController(text: s.maintenanceCost.toString());
    _maintIntervalController = TextEditingController(text: s.maintenanceInterval.toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _maintCostController.dispose();
    _maintIntervalController.dispose();
    super.dispose();
  }

  // حفظ الإعدادات
  void _saveSettings() {
    final s = Provider.of<AppSettings>(context, listen: false);
    final l = AppLocalizations.of(context)!;

    s.setFuelPrice(double.tryParse(_priceController.text) ?? 0.0);
    s.setMaintenanceSettings(
      isEnabled: _isMaintEnabled,
      cost: double.tryParse(_maintCostController.text) ?? 0.0,
      interval: int.tryParse(_maintIntervalController.text) ?? 10000,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.settingsSavedSuccess),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // تصدير CSV
  Future<void> _exportData(ExportPeriod period) async {
    final l = AppLocalizations.of(context)!;
    final box = Hive.box<Trip>('trips');
    final now = DateTime.now();

    final allTrips = box.values.toList();
    late List<Trip> filtered;

    switch (period) {
      case ExportPeriod.thisMonth:
        filtered = allTrips.where((t) => t.startTime.month == now.month && t.startTime.year == now.year).toList();
        break;
      case ExportPeriod.lastMonth:
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final year = now.month == 1 ? now.year - 1 : now.year;
        filtered = allTrips.where((t) => t.startTime.month == lastMonth && t.startTime.year == year).toList();
        break;
      case ExportPeriod.thisYear:
        filtered = allTrips.where((t) => t.startTime.year == now.year).toList();
        break;
      case ExportPeriod.allTime:
        filtered = allTrips;
        break;
    }

    if (filtered.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noDataToExport), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final rows = <List<dynamic>>[
      [
        l.headerStartDate,
        l.headerStartTime,
        l.headerDuration,
        l.headerDistance,
        l.headerIncome,
        l.headerFuelCost,
        l.headerMaintCost,
        l.headerTotalCost,
        l.headerNetProfit,
      ],
      ...filtered.map((trip) => [
        DateFormat('yyyy/MM/dd').format(trip.startTime),
        DateFormat('HH:mm').format(trip.startTime),
        (trip.duration.inSeconds / 60).toStringAsFixed(1),
        (trip.distance / 1000).toStringAsFixed(2),
        trip.income.toStringAsFixed(2),
        trip.fuelCost.toStringAsFixed(2),
        trip.maintenanceCost.toStringAsFixed(2),
        trip.totalCost.toStringAsFixed(2),
        trip.netProfit.toStringAsFixed(2),
      ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);

    try {
      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File(path);
      await file.writeAsBytes([0xEF, 0xBB, 0xBF]); // UTF-8 BOM
      await file.writeAsString(csv, mode: FileMode.append);
      await Share.shareXFiles([XFile(path)], text: l.exportShareText);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.exportFailedMessage), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _clearAllData() async {
    final box = Hive.box<Trip>('trips');
    await box.clear();
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.dataClearedSuccess), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
            colors: [AppTheme.gradientStartDark, AppTheme.gradientMiddleDark, AppTheme.gradientEndDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [AppTheme.gradientStart, AppTheme.gradientMiddle, AppTheme.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<AppSettings>(
          builder: (context, settings, child) {
            final on = cs.onSurface;
            final on50 = on.withOpacity(0.55);
            final border = (isDark ? Colors.white : Colors.black).withOpacity(0.08);

            return CustomScrollView(
              slivers: [
                // AppBar بنفس ستايل History
                SliverAppBar(
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
                          color: (isDark ? Colors.black : Colors.white).withOpacity(0.18),
                          border: Border(bottom: BorderSide(color: border, width: 1)),
                        ),
                        child: FlexibleSpaceBar(
                          centerTitle: true,
                          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: const Icon(Icons.settings, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l.settingsScreenTitle,
                                style: TextStyle(color: on, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // -------- عام --------
                      _sectionCard(
                        context,
                        title: l.settingsCardGeneral,
                        child: Column(
                          children: [
                            _tile(
                              context,
                              icon: Icons.language,
                              iconTint: cs.primary,
                              title: l.languageLabel,
                              subtitle: () {
                                final loc = settings.appLocale ?? Localizations.localeOf(context);
                                return loc.languageCode == 'ar'
                                    ? l.arabicLanguageName
                                    : loc.languageCode == 'en'
                                    ? l.englishLanguageName
                                    : loc.languageCode;
                              }(),
                              onTap: () async {
                                final picked = await showLanguageSheet(context, settings);
                                if (picked != null) settings.setLocale(picked);
                              },
                            ),
                            const SizedBox(height: 12),
                            _card(
                              context,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(l.appearanceLabel, style: TextStyle(color: on, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _modeButton(
                                          context,
                                          active: settings.isDarkMode,
                                          icon: Icons.dark_mode,
                                          onTap: () => settings.setDarkMode(true),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _modeButton(
                                          context,
                                          active: !settings.isDarkMode,
                                          icon: Icons.light_mode,
                                          onTap: () => settings.setDarkMode(false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // -------- الحساب --------
                      _sectionCard(
                        context,
                        title: l.settingsCardCalculation,
                        child: Column(
                          children: [
                            _card(
                              context,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.local_gas_station, color: cs.primary, size: 18),
                                      Text(l.fuelPriceLabel, style: TextStyle(color: on, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _input(
                                    context,
                                    controller: _priceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // معدل الاستهلاك
                            GestureDetector(
                              onTap: () async {
                                final res = await showConsumptionPickerSheet(
                                  context,
                                  initialRate: settings.consumptionRate,
                                  initialMethod: settings.consumptionMethod,
                                );
                                if (res != null) settings.setConsumption(res.rate, res.method);
                              },
                              child: _card(
                                context,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: cs.secondary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Icon(Icons.speed, color: cs.secondary, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(l.consumptionRateLabel, style: TextStyle(color: on, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Consumer<AppSettings>(
                                            builder: (context, s, _) => Text(
                                              '${s.consumptionRate.toStringAsFixed(1)} ${s.consumptionMethod == ConsumptionMethod.kmPerLiter ? l.kmPerLiter : l.litersPer100Km}',
                                              style: TextStyle(color: on.withOpacity(0.6), fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_left, color: on.withOpacity(0.6)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // الصيانة
                            _card(
                              context,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Switch(
                                        value: _isMaintEnabled,
                                        onChanged: (v) => setState(() => _isMaintEnabled = v),
                                        activeColor: cs.primary,
                                      ),
                                      const Spacer(),
                                      Text(l.maintSettingsTitle, style: TextStyle(color: on, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      Icon(Icons.build, color: cs.secondary, size: 18),
                                    ],
                                  ),
                                  if (_isMaintEnabled) ...[
                                    const SizedBox(height: 8),
                                    _labeledInput(
                                      context,
                                      label: l.maintCostLabel,
                                      controller: _maintCostController,
                                      keyboard: const TextInputType.numberWithOptions(decimal: true),
                                    ),
                                    const SizedBox(height: 8),
                                    _labeledInput(
                                      context,
                                      label: l.maintIntervalLabel,
                                      controller: _maintIntervalController,
                                      keyboard: TextInputType.number,
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // -------- البيانات --------
                      _sectionCard(
                        context,
                        title: l.settingsCardData,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final isRTL =
                                    (context.read<AppSettings>().appLocale ?? Localizations.localeOf(context)).languageCode == 'ar';
                                final period = await showExportDialog(context, isRTL: isRTL);
                                if (period != null) _exportData(period);
                              },
                              child: _tile(
                                context,
                                icon: Icons.file_present,
                                iconTint: cs.primary,
                                title: l.exportDataTitle,
                                subtitle: l.exportDataSubtitle,
                                trailingChevron: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () async {
                                final ok = await showClearDataDialog(context);
                                if (ok) _clearAllData();
                              },
                              child: _dangerTile(
                                context,
                                title: l.clearAllDataTitle,
                                subtitle: l.clearAllDataSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // زر الحفظ
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save),
                          label: Text(l.saveSettingsButton),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      Center(child: Text(l.developedByLabel, style: TextStyle(color: on.withOpacity(0.55), fontSize: 11))),
                      Center(child: Text("for.business.am@gmail.com", style: TextStyle(color: on.withOpacity(0.55), fontSize: 11))),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- UI Helpers (موحّدة مع النمط الداكن) ----------------

  Widget _sectionCard(BuildContext context, {required String title, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: AppTheme.cardShadowHover,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child, EdgeInsetsGeometry? padding}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: padding ?? const EdgeInsets.all(14),
      child: child,
    );
  }

  Widget _tile(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        required Color iconTint,
        VoidCallback? onTap,
        bool trailingChevron = false,
      }) {
    final cs = Theme.of(context).colorScheme;
    final on = cs.onSurface;

    return _card(
      context,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: iconTint.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconTint, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: TextStyle(color: on, fontWeight: FontWeight.w600)),
                  if (subtitle != null) Text(subtitle, style: TextStyle(color: on.withOpacity(0.6), fontSize: 11)),
                ],
              ),
            ),
            if (trailingChevron) Icon(Icons.chevron_left, color: on.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Widget _dangerTile(BuildContext context, {required String title, required String subtitle}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: cs.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.delete_forever, color: cs.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: cs.error, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: cs.onErrorContainer.withOpacity(0.85), fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: cs.onErrorContainer.withOpacity(0.55)),
        ],
      ),
    );
  }

  Widget _modeButton(BuildContext context, {required bool active, required IconData icon, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? Colors.transparent : border),
          boxShadow: active ? AppTheme.glowShadow(AppTheme.indigo500) : null,
        ),
        child: Icon(icon, color: active ? Colors.white : cs.onSurface),
      ),
    );
  }

  Widget _input(BuildContext context, {required TextEditingController controller, TextInputType? keyboardType}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? cs.surfaceContainerLow : cs.surface;

    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      style: TextStyle(color: cs.onSurface),
    );
  }

  Widget _labeledInput(BuildContext context,
      {required String label, required TextEditingController controller, required TextInputType keyboard}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? cs.surfaceContainerLow : cs.surface;

    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.75)),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      style: TextStyle(color: cs.onSurface),
    );
  }
}
