import 'package:flutter/material.dart';

/// Raw brand palette for Khatmah.
///
/// UI code should prefer the [ColorScheme]/[Theme] over these constants; they
/// live here so the scheme — and the few brand-specific accents that have no
/// Material role (e.g. [gold], [behind]) — are defined in exactly one place.
class AppColors {
  const AppColors._();

  /// Islamic green — the spine of the identity (deep manuscript/mosque green).
  static const Color emerald = Color(0xFF0F6E52);

  /// Lighter emerald for sufficient contrast on dark surfaces.
  static const Color emeraldBright = Color(0xFF2E9E78);

  /// Deep forest for depth, shadows and high-emphasis text on green.
  static const Color deepForest = Color(0xFF08382B);

  /// Background of the dark "mihrab night" theme.
  static const Color forestNight = Color(0xFF0A2A21);

  /// Antique manuscript-illumination (tazhīb) gold — the single accent.
  /// Reserved for completion, streaks and moments of celebration.
  static const Color gold = Color(0xFFC9A24B);

  /// Lighter gold for dark surfaces.
  static const Color goldBright = Color(0xFFD8B765);

  /// Warm parchment — the light theme background (mushaf paper).
  static const Color parchment = Color(0xFFF6F3EC);

  /// Soft sage tint for grouped surfaces in the light theme.
  static const Color sage = Color(0xFFE3E9E1);

  /// Near-black warm ink for primary text.
  static const Color ink = Color(0xFF1A1C1A);

  /// "Behind schedule" status — a warm clay, deliberately encouraging rather
  /// than an alarmist red.
  static const Color behind = Color(0xFFB4682E);
}
