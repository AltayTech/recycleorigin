import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls the app [Locale] and persists it for next launches.
///
/// This is intentionally lightweight (based on a [ValueNotifier]) so that
/// only the [MaterialApp] localization subtree rebuilds when the language
/// changes.
class AppLocaleController {
  static const String _prefsKeyLocaleCode = 'app_locale_code';

  static const Locale _defaultLocale = Locale('en');

  static final AppLocaleController instance = AppLocaleController._();

  AppLocaleController._();

  final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(_defaultLocale);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKeyLocaleCode) ?? _defaultLocale.languageCode;
    localeNotifier.value = _resolveLocale(code);
  }

  Future<void> setLocaleCode(String localeCode) async {
    final resolved = _resolveLocale(localeCode);
    if (resolved == localeNotifier.value) return;

    // Update UI first for immediate language switch.
    localeNotifier.value = resolved;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyLocaleCode, resolved.languageCode);
  }

  Locale _resolveLocale(String code) {
    // Keep the controller aligned with AppLocalizations.supportedLocales.
    return code == 'tr' ? const Locale('tr') : const Locale('en');
  }
}

