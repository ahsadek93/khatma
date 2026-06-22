import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale-aware date formatting (Arabic + English) for the whole app.
  await initializeDateFormatting();

  // Optional remote backend (shared khatma). With no keys the app runs fully
  // offline; personal khatma is local-first either way. A backend hiccup must
  // not block start-up, so this is best-effort.
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // The public client key — Supabase's "publishable" key (or a legacy
        // anon key); both occupy this slot.
        publishableKey: AppConfig.supabaseAnonKey,
      );
      // Anonymous identity for shared khatma (frictionless, no sign-up).
      final auth = Supabase.instance.client.auth;
      if (auth.currentSession == null) {
        await auth.signInAnonymously();
      }
    } catch (error, stack) {
      debugPrint('Supabase init/sign-in skipped: $error\n$stack');
    }
  }

  // SharedPreferences is read synchronously across the app, so we resolve it
  // once here and inject it into the provider graph.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const KhatmahApp(),
    ),
  );
}
