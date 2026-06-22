import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The shared Supabase client. Only valid when Supabase is configured (see
/// `AppConfig.isSupabaseConfigured`) and initialised in `main()`; reading it
/// otherwise throws, so callers gate on configuration first.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
