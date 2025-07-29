import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrencySymbol extends StatelessWidget {
  final TextStyle? style;
  const CurrencySymbol({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    if (locale.languageCode == 'ar') {
      // إذا كانت اللغة عربية، اعرض شعار SVG
      return SvgPicture.asset(
        'assets/sar.svg',
        height: style?.fontSize ?? 16,
        colorFilter: ColorFilter.mode(
          style?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          BlendMode.srcIn,
        ),
      );
    } else {
      // لأي لغة أخرى، اعرض علامة الدولار
      return Text(
        '\$',
        style: style,
      );
    }
  }
}