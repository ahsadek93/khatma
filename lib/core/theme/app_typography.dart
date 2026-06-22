import 'package:flutter/material.dart';

/// App typography. Two deliberate roles, both covering Arabic + Latin so the
/// pairing holds in either language:
///
/// - [display] = **Amiri**, a classical Naskh face, for reverent / display
///   moments (app name, large headings, the empty-state invitation).
/// - [ui] = **Tajawal**, a modern geometric sans, for all UI text and numerals.
class AppTypography {
  const AppTypography._();

  static const String display = 'Amiri';
  static const String ui = 'Tajawal';

  /// Builds the [TextTheme] for a [brightness] by composing the two families on
  /// top of the Material 2021 baseline (which carries sensible sizes and line
  /// heights). Display/headline/title-large roles use Amiri; everything else
  /// uses Tajawal.
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    final uiTheme = base.apply(fontFamily: ui);
    final displayTheme = base.apply(fontFamily: display);

    return uiTheme.copyWith(
      displayLarge: displayTheme.displayLarge,
      displayMedium: displayTheme.displayMedium,
      displaySmall: displayTheme.displaySmall,
      headlineLarge: displayTheme.headlineLarge,
      headlineMedium: displayTheme.headlineMedium,
      headlineSmall: displayTheme.headlineSmall,
      titleLarge: displayTheme.titleLarge,
    );
  }
}
