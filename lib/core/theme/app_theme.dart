import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const Color bgDark = Color(0xFF0F0F0F);
  static const Color h1 = Color(0xFF272727);
  static const Color surfaceWhite = Colors.white;

  // ── Service tile accent palette (theme-independent brand accents)
  static const Color serviceImpact = Color(0xFF0D9488);
  static const Color serviceWallet = Color(0xFF22C55E);
  static const Color serviceStore = Color(0xFF8B5CF6);
  static const Color serviceArticles = Color(0xFFF59E0B);
  static const Color serviceProfile = Color(0xFF6366F1);

  // ── Semantic icon accents for detail rows
  static const Color iconAccentGold = Color(0xFFE5A100);
  static const Color iconAccentPurple = Color(0xFF8B5CF6);
  static const Color iconAccentBlue = Color(0xFF3B82F6);
  static const Color iconAccentRed = Color(0xFFEF4444);
  static const Color iconAccentGreen = Color(0xFF10B981);

  static BoxDecoration listItemBoxFor(BuildContext context) => BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Theme.of(context).extension<AppColorsExtension>()!.divider,
        ),
        color:
            Theme.of(context).extension<AppColorsExtension>()!.cardBackground,
      );

  // ── Semantic ───────────────────────────────────────────────────
  static Color get appBarColor => primary;
  static const Color appBarIconColor = Colors.white;

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

  /// Status bar / navigation bar overlay for the given brightness.
  static SystemUiOverlayStyle systemUiOverlay(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? bgDark : bgLight,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );
  }

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
      surface: const Color(0xFF1A1A1A),
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
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ext.scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: ext.heroGradientEnd,
        foregroundColor: ext.onHeroForeground,
        iconTheme: IconThemeData(color: ext.onHeroForeground),
        actionsIconTheme: IconThemeData(color: ext.onHeroForeground),
        titleTextStyle: TextStyle(
          color: ext.onHeroForeground,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: systemUiOverlay(brightness),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: ext.cardBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.28 : 0.14,
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            );
          },
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            );
          },
        ),
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
        fillColor: ext.inputBackground,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: ext.danger),
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
        backgroundColor: ext.tagBackground,
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: ext.drawerSurface,
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
    required this.inputBackground,
    required this.tagBackground,
    required this.onTagBackground,
    required this.drawerSurface,
    required this.onHeroForeground,
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
    inputBackground: Color(0xFFF5F5F5),
    tagBackground: Color(0xFFEFF6EF),
    onTagBackground: AppTheme.primaryDark,
    drawerSurface: AppTheme.primary,
    onHeroForeground: Colors.white,
  );

  static const AppColorsExtension dark = AppColorsExtension(
    heroGradientStart: Color(0xFF2F8F57),
    heroGradientEnd: Color(0xFF1D6A4B),
    cardBackground: Color(0xFF1A1A1A),
    subtitleColor: Color(0xFFB0B6BF),
    scaffoldBackground: AppTheme.bgDark,
    divider: Color(0xFF3A3A3A),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    info: Color(0xFF64B5F6),
    danger: Color(0xFFEF9A9A),
    inputBackground: Color(0xFF2A2A2A),
    tagBackground: Color(0xFF1A2E1A),
    onTagBackground: Color(0xFF4ADE80),
    drawerSurface: Color(0xFF1B2B1B),
    onHeroForeground: Colors.white,
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
  final Color inputBackground;
  final Color tagBackground;
  final Color onTagBackground;
  final Color drawerSurface;
  final Color onHeroForeground;

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
    Color? inputBackground,
    Color? tagBackground,
    Color? onTagBackground,
    Color? drawerSurface,
    Color? onHeroForeground,
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
      inputBackground: inputBackground ?? this.inputBackground,
      tagBackground: tagBackground ?? this.tagBackground,
      onTagBackground: onTagBackground ?? this.onTagBackground,
      drawerSurface: drawerSurface ?? this.drawerSurface,
      onHeroForeground: onHeroForeground ?? this.onHeroForeground,
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
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      tagBackground: Color.lerp(tagBackground, other.tagBackground, t)!,
      onTagBackground: Color.lerp(onTagBackground, other.onTagBackground, t)!,
      drawerSurface: Color.lerp(drawerSurface, other.drawerSurface, t)!,
      onHeroForeground:
          Color.lerp(onHeroForeground, other.onHeroForeground, t)!,
    );
  }
}
