import 'package:flutter/material.dart';

/// بطاقة قسم موحّدة — شكل Material 3 أنظف + ظل خفيف + Divider رفيع داخل الهيدر
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final on = cs.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          // ظل خفيف جدًا يبان بس في الوضع الفاتح
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // تدرّج خفيف يعطي عمق للهيدر
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surfaceContainerHighest,
                    cs.surfaceContainerHigh,
                  ],
                ),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: on,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                child: Directionality(
                  textDirection: Directionality.of(context),
                  child: Text(title, textAlign: TextAlign.right),
                ),
              ),
            ),
            // Hairline divider داخل الهيدر (أخف من Border)
            Container(
              height: 0.6,
              color: Theme.of(context).dividerColor.withOpacity(0.6),
            ),
            Padding(
              padding: padding ?? const EdgeInsets.all(14),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// تايل عام — Material+InkWell لتموج اللمس، أحجام أيقونات موحّدة، وSpacing أهدى
class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final on = cs.onSurface;
    final on50 = on.withOpacity(0.5);
    final radius = BorderRadius.circular(14);

    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: cs.primary.withOpacity(0.08),
        highlightColor: cs.primary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Leading icon chip
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: on, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: on50, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Trailing: يسمح تستبدل السهم بأي عنصر
              trailing ??
                  Icon(
                    Icons.chevron_left,
                    color: on50,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر خيار داخل حوار التصدير — حالة مفعّل أو غير مفعّل مع Dot + تموج لمس
class ExportOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isRTL;
  final bool selected;
  final VoidCallback onTap;

  const ExportOptionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isRTL,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final on = cs.onSurface;
    final base = cs.surfaceContainerHigh;
    final selectedBg = cs.primary
        .withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.16 : 0.12);
    final radius = BorderRadius.circular(14);

    return Material(
      color: selected ? selectedBg : base,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: cs.primary.withOpacity(0.10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected ? cs.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Icon chip
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected ? cs.primary.withOpacity(0.20) : cs.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? cs.primary : on.withOpacity(0.70),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Align(
                  alignment:
                  isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? cs.primary : on,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Selected dot
              AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: selected ? 1 : 0,
                child: Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsetsDirectional.only(
                    start: isRTL ? 0 : 8,
                    end: isRTL ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
