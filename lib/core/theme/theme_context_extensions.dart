import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

extension ThemeContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  TextTheme get texts => Theme.of(this).textTheme;
}

/// Wraps the app subtree with correct [SystemUiOverlayStyle] for brightness.
class ThemedSystemUi extends StatelessWidget {
  const ThemedSystemUi({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlay(brightness),
      child: child,
    );
  }
}
