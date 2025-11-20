import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_repo/theme/app_theme.dart';
import 'package:demo_repo/screens/auth_gate.dart';
import 'package:demo_repo/services/locale_service.dart';
import 'package:demo_repo/services/theme_service.dart';
import 'package:demo_repo/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oghobpkjdrvicxsrinik.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9naG9icGtqZHJ2aWN4c3JpbmlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NDA2MDUsImV4cCI6MjA3OTIxNjYwNX0.Hh1UUmYTOPuMYxXb68mksgIjsOZwU9NMC9UO1B2Av_8',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = LocaleService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final locale = await LocaleService.getLocale();
    final themeMode = await ThemeService.getThemeMode();
    setState(() {
      _locale = locale;
      _themeMode = themeMode;
    });
  }

  void changeTheme(ThemeMode mode) async {
    await ThemeService.setThemeMode(mode);
    setState(() {
      _themeMode = mode;
    });
  }

  void changeLocale(Locale locale) async {
    await LocaleService.setLocale(locale);
    setState(() {
      _locale = locale;
    });
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ur')],
      home: const AuthGate(),
    );
  }
}
