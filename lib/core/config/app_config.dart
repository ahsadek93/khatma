/// Static app configuration, sourced from `--dart-define` at build time.
///
/// Supabase keys are intentionally optional: when absent the app runs fully
/// offline (local-first), which is the default during early development. Pass
/// them with:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// Whether Supabase sync is configured. When false the app stays local-only.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
