import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/config/app_theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemeController', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await AppThemeController.instance.load();
    });

    test('defaults to system theme', () {
      expect(
        AppThemeController.instance.themeModeNotifier.value,
        ThemeMode.system,
      );
    });

    test('persists dark mode selection', () async {
      await AppThemeController.instance.setThemeMode(ThemeMode.dark);
      expect(
        AppThemeController.instance.themeModeNotifier.value,
        ThemeMode.dark,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });

    test('loads saved light mode on startup', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_theme_mode': 'light',
      });
      await AppThemeController.instance.load();
      expect(
        AppThemeController.instance.themeModeNotifier.value,
        ThemeMode.light,
      );
    });
  });
}
