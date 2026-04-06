import 'package:flutter/material.dart';

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
  static const Color accent = Color(0xFFB2C243);
  static const Color secondary = Color(0xFFE5E5E5);

  // ── Neutrals ───────────────────────────────────────────────────
  static const Color bg = Color(0xFFF6F6F6);
  static const Color h1 = Color(0xFF272727);
  static const Color surfaceWhite = Colors.white;

  // ── Legacy aliases (kept for backward compatibility) ─────────
  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color grey = Colors.grey;
  static Color colorOne = Colors.red;
  static Color? colorTwo = Colors.red[300];
  static Color? colorThree = Colors.red[100];
  static BoxDecoration listItemBox = BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    border: Border.all(color: Colors.white),
    color: Colors.white,
  );

  // ── Semantic ───────────────────────────────────────────────────
  static Color appBarColor = primary;
  static const Color appBarIconColor = bg;

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
      surface: bg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        color: Colors.white,
      ),
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
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension(
          heroGradientStart: primary,
          heroGradientEnd: Color(0xFF1F8B61),
          cardBackground: Colors.white,
          subtitleColor: Color(0xFF6B7280),
        ),
      ],
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
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
        color: const Color.fromRGBO(20, 51, 51, 1),
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Roboto',
        color: const Color.fromRGBO(20, 51, 51, 1),
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
  });

  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color cardBackground;
  final Color subtitleColor;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? cardBackground,
    Color? subtitleColor,
  }) {
    return AppColorsExtension(
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      cardBackground: cardBackground ?? this.cardBackground,
      subtitleColor: subtitleColor ?? this.subtitleColor,
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
    );
  }
}
