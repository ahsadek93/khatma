import 'package:flutter/material.dart';

/// Centralised light/dark themes. A deep-green seed nods to the app's
/// spiritual purpose; Material 3 derives the tonal palette from there.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF1B6B50); // deep green

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
