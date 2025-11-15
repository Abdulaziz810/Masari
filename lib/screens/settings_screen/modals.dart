import 'package:flutter/material.dart';
import 'components.dart';
import 'package:tracking_cost/l10n/app_localizations.dart';

/// نفس القيم القديمة
enum ExportPeriod { thisMonth, lastMonth, thisYear, allTime }

/// حوار اختيار فترة التصدير — يعيد ExportPeriod أو null
Future<ExportPeriod?> showExportDialog(
    BuildContext context, {
      ExportPeriod initial = ExportPeriod.thisMonth,
      required bool isRTL,
    }) async {
  final l = AppLocalizations.of(context)!;
  ExportPeriod selected = initial;

  return showDialog<ExportPeriod?>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final on = cs.onSurface;
      final on70 = on.withOpacity(0.70);

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.file_download_outlined, size: 20, color: cs.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l.exportDataTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: on, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close, size: 20, color: on70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isRTL ? 'اختر الفترة المراد تصديرها' : 'Choose the period to export',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: on70),
                      ),
                      const SizedBox(height: 14),
                      ExportOptionTile(
                        title: l.exportThisMonth,
                        icon: Icons.calendar_today_outlined,
                        isRTL: isRTL,
                        selected: selected == ExportPeriod.thisMonth,
                        onTap: () => setState(() => selected = ExportPeriod.thisMonth),
                      ),
                      const SizedBox(height: 10),
                      ExportOptionTile(
                        title: l.exportLastMonth,
                        icon: Icons.calendar_month_outlined,
                        isRTL: isRTL,
                        selected: selected == ExportPeriod.lastMonth,
                        onTap: () => setState(() => selected = ExportPeriod.lastMonth),
                      ),
                      const SizedBox(height: 10),
                      ExportOptionTile(
                        title: l.exportThisYear,
                        icon: Icons.trending_up,
                        isRTL: isRTL,
                        selected: selected == ExportPeriod.thisYear,
                        onTap: () => setState(() => selected = ExportPeriod.thisYear),
                      ),
                      const SizedBox(height: 10),
                      ExportOptionTile(
                        title: l.exportAllTime,
                        icon: Icons.download_for_offline_outlined,
                        isRTL: isRTL,
                        selected: selected == ExportPeriod.allTime,
                        onTap: () => setState(() => selected = ExportPeriod.allTime),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Theme.of(context).dividerColor),
                                foregroundColor: on,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                              ),
                              child: Text(l.cancelButton),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).pop(selected),
                                icon: const Icon(Icons.file_download_outlined),
                                label: Text(l.exportButton),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// حوار تأكيد مسح البيانات — يعيد true عند التأكيد
Future<bool> showClearDataDialog(BuildContext context) async {
  final l = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l.clearDataConfirmationTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l.clearDataConfirmationContent,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurface.withOpacity(0.85), height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      foregroundColor: cs.onSurface,
                    ),
                    child: Text(l.cancelButton),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                    ),
                    child: Text(l.deleteButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  return ok ?? false;
}
