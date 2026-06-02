import 'package:flutter/material.dart';

import 'app_theme.dart';

extension ThemeContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  TextTheme get texts => Theme.of(this).textTheme;
}
