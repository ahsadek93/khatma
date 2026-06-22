import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatmah/core/config/app_config.dart';
import 'package:khatmah/core/sync/auth_service.dart';
import 'package:khatmah/core/sync/noop_auth_service.dart';
import 'package:khatmah/core/sync/noop_sync_service.dart';
import 'package:khatmah/core/sync/sync_service.dart';
import 'package:khatmah/data/datasources/remote/supabase/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves the auth backend once: Supabase when configured, otherwise offline.
/// `main()` has already called `Supabase.initialize` by the time this runs.
final authServiceProvider = Provider<AuthService>((ref) {
  if (AppConfig.isSupabaseConfigured) {
    return SupabaseAuthService(Supabase.instance.client);
  }
  return const NoopAuthService();
});

/// Background sync. No-op until P4 wires real push/pull.
final syncServiceProvider = Provider<SyncService>((ref) => const NoopSyncService());
