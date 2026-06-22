import '../entities/group_khatma.dart';
import '../entities/group_member.dart';
import '../entities/juz_claim.dart';

/// Contract for shared (multi-user) khatma persistence.
///
/// Unlike the personal khatma (local-first), a group khatma's source of truth
/// is the remote backend — membership spans devices. The implementation lives
/// in the data layer behind Supabase; domain/presentation never see it.
abstract interface class GroupKhatmaRepository {
  /// Groups the current user belongs to.
  Stream<List<GroupKhatma>> watchMyGroups();

  /// A single group (with member count + completed-unit count), live.
  Stream<GroupKhatma?> watchGroup(String groupId);

  /// The group's roster, live.
  Stream<List<GroupMember>> watchMembers(String groupId);

  /// The 30 juz and their claim/completion state, live.
  Stream<List<JuzClaim>> watchJuzClaims(String groupId);

  Future<GroupKhatma> createGroup({
    required String title,
    required String displayName,
    DateTime? targetDate,
  });

  /// Joins by invite code; returns the joined group.
  Future<GroupKhatma> joinByCode({
    required String code,
    required String displayName,
  });

  Future<void> claimJuz(String groupId, int juzNumber);
  Future<void> releaseJuz(String groupId, int juzNumber);
  Future<void> setJuzCompleted(String groupId, int juzNumber, bool completed);

  Future<void> leaveGroup(String groupId);
}
