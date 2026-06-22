import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Light/dark themes for Khatmah.
///
/// Identity: deep Islamic *emerald* primary, antique manuscript-illumination
/// *gold* as the single accent, on warm *parchment* (light) or *forest-night*
/// (dark). Type pairs Amiri (display) with Tajawal (UI). See [AppColors] and
/// [AppTypography].
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark ? _darkScheme : _lightScheme;
    final textTheme = AppTypography.textTheme(brightness);
    final cardColor = isDark ? scheme.surfaceContainerHighest : Colors.white;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // --- Hand-tuned schemes (not seed-generated) so the parchment/gold identity
  // survives instead of being averaged away by the tonal-palette algorithm. ---

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.emerald,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFCDEBDC),
    onPrimaryContainer: AppColors.deepForest,
    secondary: AppColors.gold,
    onSecondary: Color(0xFF2C2410),
    secondaryContainer: Color(0xFFF3E7C6),
    onSecondaryContainer: Color(0xFF4A3B12),
    tertiary: AppColors.gold,
    onTertiary: Colors.white,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: AppColors.parchment,
    onSurface: AppColors.ink,
    onSurfaceVariant: Color(0xFF49544C),
    surfaceContainerHighest: AppColors.sage,
    surfaceContainerHigh: Color(0xFFEDEDE3),
    surfaceContainer: Color(0xFFF1EFE6),
    surfaceContainerLow: Color(0xFFF4F1E9),
    outline: Color(0xFF8A968B),
    outlineVariant: Color(0xFFD3D8CE),
    surfaceTint: AppColors.emerald,
    inverseSurface: AppColors.deepForest,
    onInverseSurface: AppColors.parchment,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.emeraldBright,
    onPrimary: Color(0xFF00261B),
    primaryContainer: Color(0xFF0E4A38),
    onPrimaryContainer: Color(0xFFB7E6CF),
    secondary: AppColors.goldBright,
    onSecondary: Color(0xFF2C2410),
    secondaryContainer: Color(0xFF514420),
    onSecondaryContainer: Color(0xFFF3E7C6),
    tertiary: AppColors.goldBright,
    onTertiary: Color(0xFF2C2410),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: AppColors.forestNight,
    onSurface: Color(0xFFE7ECE6),
    onSurfaceVariant: Color(0xFFB9C4BB),
    surfaceContainerHighest: Color(0xFF143A2E),
    surfaceContainerHigh: Color(0xFF103428),
    surfaceContainer: Color(0xFF0D2D23),
    surfaceContainerLow: Color(0xFF0B281F),
    outline: Color(0xFF566B5F),
    outlineVariant: Color(0xFF2E3F36),
    surfaceTint: AppColors.emeraldBright,
    inverseSurface: AppColors.parchment,
    onInverseSurface: AppColors.deepForest,
  );
}
