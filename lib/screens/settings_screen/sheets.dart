import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracking_cost/l10n/app_localizations.dart';
import '../../providers/app_settings.dart';

/// نتيجة شيت الاستهلاك
class ConsumptionResult {
  final double rate;
  final ConsumptionMethod method;
  ConsumptionResult(this.rate, this.method);
}

/// BottomSheet اختيار اللغة — يرجع Locale
Future<Locale?> showLanguageSheet(BuildContext context, AppSettings settings) async {
  final l = AppLocalizations.of(context)!;
  final currentLocale = settings.appLocale ?? Localizations.localeOf(context);
  final supported = AppLocalizations.supportedLocales;

  return showModalBottomSheet<Locale?>(
    context: context,
    useSafeArea: true,
    showDragHandle: true, // Handle جاهز من Flutter
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        shrinkWrap: true,
        itemCount: supported.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(l.languageLabel, style: Theme.of(context).textTheme.titleMedium),
              ),
            );
          }
          final locale = supported[index - 1];
          final isSelected = locale.languageCode == currentLocale.languageCode &&
              (locale.countryCode == null || locale.countryCode == currentLocale.countryCode);

          String title;
          if (locale.languageCode == 'ar') {
            title = l.arabicLanguageName;
          } else if (locale.languageCode == 'en') {
            title = l.englishLanguageName;
          } else {
            title = locale.languageCode;
          }

          return ListTile(
            title: Text(title),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(locale),
          );
        },
      );
    },
  );
}

/// BottomSheet اختيار معدل الاستهلاك — يرجع ConsumptionResult
Future<ConsumptionResult?> showConsumptionPickerSheet(
    BuildContext context, {
      required double initialRate,
      required ConsumptionMethod initialMethod,
    }) async {
  final l = AppLocalizations.of(context)!;

  int intPart = initialRate.toInt();
  int decPart = ((initialRate - intPart) * 10).round();
  var method = initialMethod;

  return showModalBottomSheet<ConsumptionResult?>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final on = cs.onSurface;
      final on70 = on.withOpacity(0.7);
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';

      final pickerText = TextStyle(fontSize: 18, color: on70);
      final pickerSelected = TextStyle(fontSize: 30, color: cs.primary);

      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(l.consumptionPickerTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                // طريقة القياس
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(l.kmPerLiter),
                          selected: method == ConsumptionMethod.kmPerLiter,
                          onSelected: (_) => setState(() => method = ConsumptionMethod.kmPerLiter),
                          selectedColor: cs.primary.withOpacity(0.12),
                          labelStyle: TextStyle(
                            color: method == ConsumptionMethod.kmPerLiter ? cs.primary : on70,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(l.litersPer100Km),
                          selected: method == ConsumptionMethod.litersPer100Km,
                          onSelected: (_) =>
                              setState(() => method = ConsumptionMethod.litersPer100Km),
                          selectedColor: cs.primary.withOpacity(0.12),
                          labelStyle: TextStyle(
                            color: method == ConsumptionMethod.litersPer100Km ? cs.primary : on70,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // المنتقيات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isArabic) ...[
                      NumberPicker(
                        minValue: 0,
                        maxValue: 100,
                        value: intPart,
                        onChanged: (v) => setState(() => intPart = v),
                        textStyle: pickerText,
                        selectedTextStyle: pickerSelected,
                        itemHeight: 45,
                      ),
                      Text(".", style: TextStyle(fontSize: 36, color: cs.primary)),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 9,
                        value: decPart,
                        onChanged: (v) => setState(() => decPart = v),
                        textStyle: pickerText,
                        selectedTextStyle: pickerSelected,
                        itemHeight: 45,
                      ),
                    ] else ...[
                      NumberPicker(
                        minValue: 0,
                        maxValue: 9,
                        value: decPart,
                        onChanged: (v) => setState(() => decPart = v),
                        textStyle: pickerText,
                        selectedTextStyle: pickerSelected,
                        itemHeight: 45,
                      ),
                      Text(".", style: TextStyle(fontSize: 36, color: cs.primary)),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 100,
                        value: intPart,
                        onChanged: (v) => setState(() => intPart = v),
                        textStyle: pickerText,
                        selectedTextStyle: pickerSelected,
                        itemHeight: 45,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final rate = intPart + (decPart / 10.0);
                      Navigator.of(context).pop(ConsumptionResult(rate, method));
                    },
                    child: Text(l.doneButton),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
