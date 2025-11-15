import 'package:flutter/material.dart';
import 'dart:ui';

class AppTheme {
  // ------------ Gradient Colors (background, light) ------------
  static const gradientStart = Color(0xFFF8FAFC); // slate-50
  static const gradientMiddle = Color(0xFFDEEBFF); // blue-50
  static const gradientEnd   = Color(0xFFE0E7FF);  // indigo-50

  // ------------ Gradient Colors (background, dark) ------------
  // Primary names
  static const gradientDarkStart  = Color(0xFF0B1220);
  static const gradientDarkMiddle = Color(0xFF111827); // ~ slate-900
  static const gradientDarkEnd    = Color(0xFF0F172A); // ~ slate-950
  // Aliases to avoid name mismatches in other files
  static const gradientStartDark  = gradientDarkStart;
  static const gradientMiddleDark = gradientDarkMiddle;
  static const gradientEndDark    = gradientDarkEnd;

  // ------------ Brand / Primary ------------
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);

  // ------------ Status ------------
  static const green500   = Color(0xFF10B981);
  static const green600   = Color(0xFF059669);
  static const emerald600 = Color(0xFF059669);
  static const red500     = Color(0xFFEF4444);
  static const red600     = Color(0xFFDC2626);
  static const rose600    = Color(0xFFE11D48);
  static const blue500    = Color(0xFF3B82F6);
  static const blue600    = Color(0xFF2563EB);
  static const orange500  = Color(0xFFF97316);
  static const orange600  = Color(0xFFEA580C);
  static const yellow400  = Color(0xFFFACC15);
  static const pink500    = Color(0xFFEC4899);

  // ------------ Neutral ------------
  static const slate50  = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  // ------------ Solid gradients ------------
  static const primaryGradient = LinearGradient(
    colors: [indigo500, purple600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const blueGradient = LinearGradient(
    colors: [blue500, blue600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const greenGradient = LinearGradient(
    colors: [green500, emerald600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const redGradient = LinearGradient(
    colors: [red500, rose600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const orangeGradient = LinearGradient(
    colors: [orange500, orange600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const purpleGradient = LinearGradient(
    colors: [purple500, purple600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ------------ Light gradients (cards) ------------
  static const blueGradientLight = LinearGradient(
    colors: [Color(0xFFDEEBFF), Color(0xFFBAD7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const purpleGradientLight = LinearGradient(
    colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const greenGradientLight = LinearGradient(
    colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const orangeGradientLight = LinearGradient(
    colors: [Color(0xFFFFEDD5), Color(0xFFFED7AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ------------ Shadows ------------
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> glowShadow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ================== Themed helpers (light/dark aware) ==================

  // Screen background gradient based on brightness
  static LinearGradient bgGradient(Brightness b) {
    return b == Brightness.dark
        ? const LinearGradient(
      colors: [gradientDarkStart, gradientDarkMiddle, gradientDarkEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [gradientStart, gradientMiddle, gradientEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Surface & text colors via ColorScheme
  static Color surface(BuildContext ctx) => Theme.of(ctx).colorScheme.surface;
  static Color onSurface(BuildContext ctx) => Theme.of(ctx).colorScheme.onSurface;

  // Outline/border color (respects theme)
  static Color outline(BuildContext ctx) => Theme.of(ctx).dividerColor;

  // Shadow tuned for dark/light
  static List<BoxShadow> cardShadowThemed(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.40 : 0.08),
        blurRadius: isDark ? 16 : 10,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // Soft panel background for charts/sections
  static LinearGradient softPanelGradient(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.03)]
          : [slate50, slate100],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
