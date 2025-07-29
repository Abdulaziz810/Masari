import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracking_cost/localization/app_localizations.dart';
import 'models/trip_model.dart';
import 'providers/app_settings.dart';
import 'screens/main_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  Hive.registerAdapter(TripAdapter());
  await Hive.openBox<Trip>('trips');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return ChangeNotifierProvider(
      create: (context) => AppSettings(),
      child: Consumer<AppSettings>(
        builder: (context, settings, child) {

          final colorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF00897B),
            brightness: Brightness.light,
          );

          final darkColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF00897B),
            brightness: Brightness.dark,
            surface: const Color(0xFF121212),
          );

          final cardTheme = CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          );

          final elevatedButtonTheme = ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          );

          return MaterialApp(
            title: 'Fuel Cost Tracker',

            theme: ThemeData(
              colorScheme: colorScheme,
              useMaterial3: true,
              cardTheme: cardTheme,
              elevatedButtonTheme: elevatedButtonTheme,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                foregroundColor: colorScheme.onSurface,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme,
              useMaterial3: true,
              cardTheme: cardTheme.copyWith(
                color: darkColorScheme.surfaceVariant,
              ),
              elevatedButtonTheme: elevatedButtonTheme,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                foregroundColor: darkColorScheme.onSurface,
              ),
            ),

            themeMode: settings.themeMode,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,

            locale: settings.appLocale,
            supportedLocales: const [
              Locale('ar', ''),
              Locale('en', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}