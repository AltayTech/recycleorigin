import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls and persists the app [ThemeMode].
class AppThemeController {
  static const String _prefsKeyThemeMode = 'app_theme_mode';

  static final AppThemeController instance = AppThemeController._();

  AppThemeController._();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeRaw = prefs.getString(_prefsKeyThemeMode) ?? 'system';
    themeModeNotifier.value = _parseThemeMode(modeRaw);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeModeNotifier.value == mode) return;
    themeModeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyThemeMode, _serializeThemeMode(mode));
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
