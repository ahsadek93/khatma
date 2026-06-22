import 'package:khatmah/core/sync/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [AuthService] using anonymous sign-in.
///
/// This is the *only* place the app talks to Supabase auth — the swap test:
/// dropping Supabase touches this file and its sibling datasources, nothing in
/// `domain/` or `presentation/`.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<String?> userIdChanges() =>
      _client.auth.onAuthStateChange.map((state) => state.session?.user.id);

  @override
  Future<void> ensureSignedIn() async {
    if (_client.auth.currentUser != null) return;
    await _client.auth.signInAnonymously();
  }
}
