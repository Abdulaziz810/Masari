import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:tracking_cost/l10n/app_localizations.dart';
import 'package:tracking_cost/models/trip_model.dart';
import 'package:tracking_cost/providers/app_settings.dart';
import 'package:tracking_cost/screens/main_screen.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  Hive.registerAdapter(TripAdapter());
  await Hive.openBox<Trip>('trips');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: Consumer<AppSettings>(
        builder: (context, settings, _) {
          // ColorSchemes متوافقة مع أي قناة Flutter
          final lightColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF00897B),
            brightness: Brightness.light,
          );
          final darkColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF00897B),
            brightness: Brightness.dark,
            surface: const Color(0xFF121212),
          );

          // استخدم Data* لتوافق القنوات الأقدم
          final cardTheme = CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          );

          final elevatedButtonTheme = ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          );

          final inputTheme = InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          );

          final dialogTheme = DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );

          final snackBarTheme = SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );

          final bottomNavTheme = const BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fuel Cost Tracker',

            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
              cardTheme: cardTheme,
              elevatedButtonTheme: elevatedButtonTheme,
              inputDecorationTheme: inputTheme.copyWith(fillColor: lightColorScheme.surface),
              dialogTheme: dialogTheme,
              snackBarTheme: snackBarTheme,
              bottomNavigationBarTheme: bottomNavTheme.copyWith(
                selectedItemColor: lightColorScheme.primary,
                unselectedItemColor: lightColorScheme.onSurfaceVariant,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                foregroundColor: lightColorScheme.onSurface,
              ),
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
              cardTheme: cardTheme.copyWith(color: darkColorScheme.surfaceVariant),
              elevatedButtonTheme: elevatedButtonTheme,
              inputDecorationTheme: inputTheme.copyWith(fillColor: darkColorScheme.surface),
              dialogTheme: dialogTheme,
              snackBarTheme: snackBarTheme,
              bottomNavigationBarTheme: bottomNavTheme.copyWith(
                selectedItemColor: darkColorScheme.primary,
                unselectedItemColor: darkColorScheme.onSurfaceVariant,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                foregroundColor: darkColorScheme.onSurface,
              ),
            ),

            themeMode: settings.themeMode,

            // اللغات
            locale: settings.appLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // استخدام الـ list-resolution (قائمة) وليس عنصر واحد
            localeListResolutionCallback: (deviceLocales, supported) {
              if (deviceLocales != null && deviceLocales.isNotEmpty) {
                for (final loc in deviceLocales) {
                  if (supported.any((s) => s.languageCode == loc.languageCode)) {
                    return loc;
                  }
                }
              }
              return supported.first;
            },

            // تحسينات عامة
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final clampedTextScale = media.textScaleFactor.clamp(0.85, 1.15);
              return MediaQuery(
                data: media.copyWith(textScaleFactor: clampedTextScale),
                child: ScrollConfiguration(
                  behavior: const _NoGlowScrollBehavior(),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },

            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
