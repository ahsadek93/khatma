import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatmah/core/providers/app_providers.dart';
import 'package:khatmah/core/sync/sync_providers.dart';
import 'package:khatmah/data/datasources/remote/supabase/supabase_providers.dart';
import 'package:khatmah/features/group_khatma/data/repositories/supabase_group_khatma_repository.dart';
import 'package:khatmah/features/group_khatma/domain/repositories/group_khatma_repository.dart';

/// Remote-first repository for shared khatmas (Supabase + realtime).
final groupKhatmaRepositoryProvider = Provider<GroupKhatmaRepository>((ref) {
  return SupabaseGroupKhatmaRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(authServiceProvider),
  );
});

/// The current (anonymous) user id — used to tell "my" claims from others'.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authServiceProvider).currentUserId,
);

/// The display name shown to other members, persisted in SharedPreferences and
/// reused across groups.
class DisplayNameController extends Notifier<String> {
  static const _key = 'display_name';

  @override
  String build() => ref.watch(sharedPreferencesProvider).getString(_key) ?? '';

  Future<void> set(String name) async {
    final trimmed = name.trim();
    await ref.read(sharedPreferencesProvider).setString(_key, trimmed);
    state = trimmed;
  }
}

final displayNameControllerProvider =
    NotifierProvider<DisplayNameController, String>(DisplayNameController.new);
