/// Authentication seam. The app depends only on this interface; the concrete
/// implementation (Supabase, or a local no-op) is chosen in one place so that
/// leaving any vendor never touches the domain or presentation layers.
abstract interface class AuthService {
  /// The current signed-in user id (Supabase `auth.uid()`), or null offline.
  String? get currentUserId;

  /// Emits the user id whenever auth state changes.
  Stream<String?> userIdChanges();

  /// Ensures a session exists (anonymous sign-in when configured). No-op offline.
  Future<void> ensureSignedIn();
}
