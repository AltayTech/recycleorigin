import 'package:flutter/material.dart';

import '../config/app_theme_controller.dart';

/// Central design-token palette used across the app.
///
/// Colour values are intentionally exposed as constants so they can
/// feed both the [ThemeData] and be referenced directly in
/// one-off decorations.  Prefer accessing via
/// `Theme.of(context).colorScheme` or `Theme.of(context).extension`
/// wherever possible.
class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────
  static const Color primary = Color(0xFF77C243);
  static const Color primaryDark = Color(0xFF1F8B61);
  static const Color accent = Color(0xFFB2C243);
  static const Color secondary = Color(0xFFE5E5E5);

  // ── Neutrals ───────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF6F6F6);
  static const Color bgDark = Color(0xFF121212);
  static const Color h1 = Color(0xFF272727);
  static const Color surfaceWhite = Colors.white;

  // ── Legacy aliases (kept for backward compatibility) ─────────
  static Color get white => _isDark ? const Color(0xFF1E1E1E) : Colors.white;
  static Color get black => _isDark ? Colors.white : Colors.black;
  static Color get grey =>
      _isDark ? const Color(0xFFB0B6BF) : const Color(0xFF6B7280);
  static Color get bg => _isDark ? bgDark : bgLight;
  static Color colorOne = Colors.red;
  static Color? colorTwo = Colors.red[300];
  static Color? colorThree = Colors.red[100];
  static BoxDecoration listItemBoxFor(BuildContext context) => BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Theme.of(context).extension<AppColorsExtension>()!.divider,
        ),
        color: Theme.of(context).extension<AppColorsExtension>()!.cardBackground,
      );

  @Deprecated('Use listItemBoxFor(context)')
  static BoxDecoration listItemBox = BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    border: Border.all(color: Colors.white),
    color: Colors.white,
  );

  // ── Semantic ───────────────────────────────────────────────────
  static Color get appBarColor => primary;
  static const Color appBarIconColor = Colors.white;
  static bool get _isDark =>
      AppThemeController.instance.themeModeNotifier.value == ThemeMode.dark;


  // ── Spacing scale (4-pt grid) ──────────────────────────────────
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // ── Radius scale ───────────────────────────────────────────────
  static const double radiusSm = 12;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double radiusFull = 999;

  // ── Elevation / shadow presets ─────────────────────────────────
  static List<BoxShadow> cardShadow(Color tint) => [
        BoxShadow(
          color: tint.withValues(alpha: 0.12),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> heroShadow(Color tint) => [
        BoxShadow(
          color: tint.withValues(alpha: 0.24),
          blurRadius: 34,
          offset: const Offset(0, 18),
        ),
      ];

  // ── Theme builders ─────────────────────────────────────────────

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xFFE8E8E8),
      outlineVariant: const Color(0xFFD4D4D8),
      onSurfaceVariant: const Color(0xFF6B7280),
    );
    return _buildTheme(colorScheme: colorScheme, brightness: Brightness.light);
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
      surfaceContainerHighest: const Color(0xFF2A2A2A),
      outlineVariant: const Color(0xFF3A3A3A),
      onSurfaceVariant: const Color(0xFFB0B6BF),
    );
    return _buildTheme(colorScheme: colorScheme, brightness: Brightness.dark);
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final ext = isDark ? AppColorsExtension.dark : AppColorsExtension.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ext.scaffoldBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(brightness, colorScheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        color: ext.cardBackground,
      ),
      dividerTheme: DividerThemeData(
        color: ext.divider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: ext.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: ext.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ext.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.4,
        ),
        side: BorderSide(color: ext.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[ext],
    );
  }

  static TextTheme _buildTextTheme(
    Brightness brightness,
    ColorScheme colorScheme,
  ) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'Roboto',
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Roboto',
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Roboto',
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Custom design tokens that live alongside [ColorScheme].
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.cardBackground,
    required this.subtitleColor,
    required this.scaffoldBackground,
    required this.divider,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
  });

  static const AppColorsExtension light = AppColorsExtension(
    heroGradientStart: AppTheme.primary,
    heroGradientEnd: AppTheme.primaryDark,
    cardBackground: Colors.white,
    subtitleColor: Color(0xFF6B7280),
    scaffoldBackground: AppTheme.bgLight,
    divider: Color(0xFFD4D4D8),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF57C00),
    info: Color(0xFF1976D2),
    danger: Color(0xFFD32F2F),
  );

  static const AppColorsExtension dark = AppColorsExtension(
    heroGradientStart: Color(0xFF2F8F57),
    heroGradientEnd: Color(0xFF1D6A4B),
    cardBackground: Color(0xFF1E1E1E),
    subtitleColor: Color(0xFFB0B6BF),
    scaffoldBackground: AppTheme.bgDark,
    divider: Color(0xFF3A3A3A),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    info: Color(0xFF64B5F6),
    danger: Color(0xFFEF9A9A),
  );

  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color cardBackground;
  final Color subtitleColor;
  final Color scaffoldBackground;
  final Color divider;
  final Color success;
  final Color warning;
  final Color info;
  final Color danger;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? cardBackground,
    Color? subtitleColor,
    Color? scaffoldBackground,
    Color? divider,
    Color? success,
    Color? warning,
    Color? info,
    Color? danger,
  }) {
    return AppColorsExtension(
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      cardBackground: cardBackground ?? this.cardBackground,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      heroGradientStart:
          Color.lerp(heroGradientStart, other.heroGradientStart, t)!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
