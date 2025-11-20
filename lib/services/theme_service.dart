import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme';
  static const ThemeMode _defaultThemeMode = ThemeMode.system;

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);
    if (themeString == null) {
      return _defaultThemeMode;
    }
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => _defaultThemeMode,
    );
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }
}
