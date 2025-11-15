import 'package:flutter/material.dart';
import 'package:tracking_cost/l10n/app_localizations.dart';
import 'package:tracking_cost/screens/history_page.dart';
import 'package:tracking_cost/screens/home_page.dart';
import 'package:tracking_cost/screens/settings_screen/settings_page.dart';

/// الشاشة الرئيسية للتطبيق.
/// - يستخدم IndexedStack للمحافظة على حالة الصفحات.
/// - شريط تنقّل سفلي بنمط Material 3 مع مؤشر تحديد وحواف دائرية.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // غير const عمداً تحسباً لتمرير سياق مستقبلاً
  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // شريط تنقّل سفلي محسّن
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            // ظل خفيف للأعلى
            BoxShadow(
              color: (isDark ? Colors.black : Colors.black87).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.6,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: cs.surface,
                  indicatorColor: cs.primary.withOpacity(isDark ? 0.20 : 0.14),
                  indicatorShape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final sel = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                      color: sel ? cs.onSurface : cs.onSurfaceVariant,
                      fontSize: 12,
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final sel = states.contains(WidgetState.selected);
                    return IconThemeData(
                      size: 22,
                      color: sel ? cs.primary : cs.onSurfaceVariant,
                    );
                  }),
                  height: 68,
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                  // إظهار التسميات دائماً لتوافق RTL
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.route_outlined),
                      selectedIcon: const Icon(Icons.route),
                      label: l.mainTab,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.history_outlined),
                      selectedIcon: const Icon(Icons.history),
                      label: l.historyTab,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: l.settingsTab,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
