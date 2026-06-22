import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatmah/core/utils/streams.dart';
import 'package:khatmah/features/group_khatma/domain/entities/group_khatma.dart';
import 'package:khatmah/features/group_khatma/domain/entities/group_member.dart';
import 'package:khatmah/features/group_khatma/domain/entities/juz_claim.dart';
import 'package:khatmah/features/group_khatma/domain/repositories/group_khatma_repository.dart';
import 'package:khatmah/features/group_khatma/group_khatma_providers.dart';

/// Shared khatmas the current user belongs to (live).
final groupListProvider = StreamProvider<List<GroupKhatma>>(
  (ref) => ref.watch(groupKhatmaRepositoryProvider).watchMyGroups(),
);

/// Combined live read-model for a group detail screen.
class GroupDetailState {
  const GroupDetailState({
    required this.group,
    required this.members,
    required this.claims,
  });

  final GroupKhatma? group;
  final List<GroupMember> members;
  final List<JuzClaim> claims;

  bool get exists => group != null;
  int get completedUnits => claims.where((c) => c.completed).length;
  int get memberCount => members.length;

  double get progress {
    final total = group?.totalUnits ?? 0;
    if (total <= 0) return 0;
    final p = completedUnits / total;
    return p > 1 ? 1 : p;
  }

  bool get isComplete {
    final total = group?.totalUnits ?? 0;
    return total > 0 && completedUnits >= total;
  }
}

/// Fuses the group, its roster, and its juz claims into one live stream.
final groupDetailProvider =
    StreamProvider.autoDispose.family<GroupDetailState, String>((ref, id) {
  final repo = ref.watch(groupKhatmaRepositoryProvider);
  return combine3(
    repo.watchGroup(id),
    repo.watchMembers(id),
    repo.watchJuzClaims(id),
    (GroupKhatma? group, List<GroupMember> members, List<JuzClaim> claims) =>
        GroupDetailState(group: group, members: members, claims: claims),
  );
});

/// User intents for shared khatmas.
class GroupKhatmaCommands {
  GroupKhatmaCommands(this._repo);

  final GroupKhatmaRepository _repo;

  Future<GroupKhatma> create({
    required String title,
    required String displayName,
    DateTime? targetDate,
  }) =>
      _repo.createGroup(
        title: title,
        displayName: displayName,
        targetDate: targetDate,
      );

  Future<GroupKhatma> join({
    required String code,
    required String displayName,
  }) =>
      _repo.joinByCode(code: code, displayName: displayName);

  Future<void> claim(String groupId, int juz) => _repo.claimJuz(groupId, juz);
  Future<void> release(String groupId, int juz) =>
      _repo.releaseJuz(groupId, juz);
  Future<void> setCompleted(String groupId, int juz, {required bool completed}) =>
      _repo.setJuzCompleted(groupId, juz, completed);
  Future<void> leave(String groupId) => _repo.leaveGroup(groupId);
}

final groupKhatmaCommandsProvider = Provider<GroupKhatmaCommands>(
  (ref) => GroupKhatmaCommands(ref.watch(groupKhatmaRepositoryProvider)),
);
