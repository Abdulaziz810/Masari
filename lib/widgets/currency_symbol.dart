import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ويدجت بسيطة تعرض رمز العملة.
/// - لو اللغة عربية يحاول يعرض `assets/sar.svg`
/// - لو ما لقى/ما تبي SVG أو اللغة مو عربية يعرض نص (مثلاً SAR أو $)
///
/// ملاحظة: الأفضل تخلي اسم العملة يجي من الـ localization
/// وتخلي هذا الودجت بس مسؤول عن الشكل.
class CurrencySymbol extends StatelessWidget {
  final TextStyle? style;

  /// لو حاب تفرض رمز معيّن وتتجاوز اللغة
  final String? overrideText;

  const CurrencySymbol({
    super.key,
    this.style,
    this.overrideText,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لو المستخدم مرر نص نعرضه مباشرة
    if (overrideText != null) {
      return Text(overrideText!, style: style);
    }

    // لو اللغة عربية نجرّب الـ SVG
    if (locale.languageCode == 'ar') {
      return SvgPicture.asset(
        'assets/sar.svg',
        height: style?.fontSize ?? 16,
        colorFilter: ColorFilter.mode(
          style?.color ?? (isDark ? Colors.white : Colors.black),
          BlendMode.srcIn,
        ),
        // لو صار خطأ في الـ SVG نرجع لنص
        placeholderBuilder: (_) => Text('ر.س', style: style),
      );
    }

    // باقي اللغات
    return Text(
      '\$', // تقدر تستبدله بـ 'SAR' أو تخليه يجي من الترجمة
      style: style,
    );
  }
}
