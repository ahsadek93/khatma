import 'auth_service.dart';

/// Offline [AuthService]: no remote account, no user id. Used whenever Supabase
/// is not configured so the rest of the app behaves identically online/offline.
class NoopAuthService implements AuthService {
  const NoopAuthService();

  @override
  String? get currentUserId => null;

  @override
  Stream<String?> userIdChanges() => const Stream.empty();

  @override
  Future<void> ensureSignedIn() async {}
}
