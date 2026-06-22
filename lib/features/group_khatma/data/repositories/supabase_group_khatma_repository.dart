import 'package:khatmah/core/sync/auth_service.dart';
import 'package:khatmah/features/group_khatma/domain/entities/group_khatma.dart';
import 'package:khatmah/features/group_khatma/domain/entities/group_member.dart';
import 'package:khatmah/features/group_khatma/domain/entities/juz_claim.dart';
import 'package:khatmah/features/group_khatma/domain/repositories/group_khatma_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed shared khatma repository.
///
/// Realtime: per-group rows (members, juz_claims, the group itself) are streamed
/// via `.stream()` so every member sees claims/completions live. Mutations go
/// through RLS-guarded updates and the `create_group_khatma` / `join_group_khatma`
/// RPCs. This is the only file that talks to Supabase for this feature.
class SupabaseGroupKhatmaRepository implements GroupKhatmaRepository {
  SupabaseGroupKhatmaRepository(this._client, this._auth);

  final SupabaseClient _client;
  final AuthService _auth;

  static const _groups = 'group_khatmas';
  static const _members = 'group_members';
  static const _claims = 'juz_claims';

  @override
  Stream<List<GroupKhatma>> watchMyGroups() {
    final uid = _auth.currentUserId;
    if (uid == null) return Stream.value(const []);

    // React to my memberships changing; re-fetch the groups (+ counts) each time.
    return _client
        .from(_members)
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .asyncMap((memberRows) async {
          final ids =
              memberRows.map((r) => r['group_id'] as String).toSet().toList();
          if (ids.isEmpty) return <GroupKhatma>[];

          final groupRows =
              await _client.from(_groups).select().inFilter('id', ids);
          final claimRows = await _client
              .from(_claims)
              .select('group_id, completed')
              .inFilter('group_id', ids);
          final memberRowsAll = await _client
              .from(_members)
              .select('group_id')
              .inFilter('group_id', ids);

          final completedByGroup = <String, int>{};
          for (final row in claimRows) {
            if (row['completed'] == true) {
              final g = row['group_id'] as String;
              completedByGroup[g] = (completedByGroup[g] ?? 0) + 1;
            }
          }
          final membersByGroup = <String, int>{};
          for (final row in memberRowsAll) {
            final g = row['group_id'] as String;
            membersByGroup[g] = (membersByGroup[g] ?? 0) + 1;
          }

          final groups = groupRows
              .map((row) => _groupFromRow(
                    row,
                    completedUnits: completedByGroup[row['id']] ?? 0,
                    memberCount: membersByGroup[row['id']] ?? 0,
                  ))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return groups;
        });
  }

  @override
  Stream<GroupKhatma?> watchGroup(String groupId) {
    return _client
        .from(_groups)
        .stream(primaryKey: ['id'])
        .eq('id', groupId)
        .map((rows) => rows.isEmpty ? null : _groupFromRow(rows.first));
  }

  @override
  Stream<List<GroupMember>> watchMembers(String groupId) {
    return _client
        .from(_members)
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .map((rows) => rows.map(_memberFromRow).toList()
          ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt)));
  }

  @override
  Stream<List<JuzClaim>> watchJuzClaims(String groupId) {
    return _client
        .from(_claims)
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .map((rows) => rows.map(_claimFromRow).toList()
          ..sort((a, b) => a.juzNumber.compareTo(b.juzNumber)));
  }

  @override
  Future<GroupKhatma> createGroup({
    required String title,
    required String displayName,
    DateTime? targetDate,
  }) async {
    await _auth.ensureSignedIn();
    final result = await _client.rpc('create_group_khatma', params: {
      'p_title': title,
      'p_display_name': displayName,
      if (targetDate != null) 'p_target_date': _dateOnly(targetDate),
    });
    final row = (result is List ? result.first : result) as Map<String, dynamic>;
    return _groupFromRow(row, memberCount: 1);
  }

  @override
  Future<GroupKhatma> joinByCode({
    required String code,
    required String displayName,
  }) async {
    await _auth.ensureSignedIn();
    final groupId = await _client.rpc('join_group_khatma', params: {
      'p_code': code.trim().toUpperCase(),
      'p_display_name': displayName,
    }) as String;
    final row =
        await _client.from(_groups).select().eq('id', groupId).single();
    return _groupFromRow(row);
  }

  @override
  Future<void> claimJuz(String groupId, int juzNumber) async {
    await _client.from(_claims).update({
      'claimed_by': _auth.currentUserId,
      'claimed_name': await _myNameIn(groupId),
      'updated_at': _nowIso(),
    }).eq('group_id', groupId).eq('juz_number', juzNumber);
  }

  @override
  Future<void> releaseJuz(String groupId, int juzNumber) async {
    await _client.from(_claims).update({
      'claimed_by': null,
      'claimed_name': null,
      'completed': false,
      'completed_at': null,
      'updated_at': _nowIso(),
    }).eq('group_id', groupId).eq('juz_number', juzNumber);
  }

  @override
  Future<void> setJuzCompleted(
    String groupId,
    int juzNumber,
    bool completed,
  ) async {
    final data = <String, dynamic>{
      'completed': completed,
      'completed_at': completed ? _nowIso() : null,
      'updated_at': _nowIso(),
    };
    if (completed) {
      // Completing an open juz also claims it for me.
      data['claimed_by'] = _auth.currentUserId;
      data['claimed_name'] = await _myNameIn(groupId);
    }
    await _client
        .from(_claims)
        .update(data)
        .eq('group_id', groupId)
        .eq('juz_number', juzNumber);
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await _client
        .from(_members)
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', _auth.currentUserId ?? '');
  }

  Future<String?> _myNameIn(String groupId) async {
    final uid = _auth.currentUserId;
    if (uid == null) return null;
    final row = await _client
        .from(_members)
        .select('display_name')
        .eq('group_id', groupId)
        .eq('user_id', uid)
        .maybeSingle();
    return row?['display_name'] as String?;
  }

  // ── Mappers ────────────────────────────────────────────────────────────

  GroupKhatma _groupFromRow(
    Map<String, dynamic> row, {
    int memberCount = 0,
    int completedUnits = 0,
  }) {
    return GroupKhatma(
      id: row['id'] as String,
      kind: GroupKhatmaKind.fromName(row['kind'] as String? ?? 'quran'),
      title: row['title'] as String,
      totalUnits: (row['total_units'] as num?)?.toInt() ?? 30,
      status: GroupKhatmaStatus.fromName(row['status'] as String? ?? 'active'),
      inviteCode: row['invite_code'] as String,
      createdBy: row['created_by'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      zikrPhrase: row['zikr_phrase'] as String?,
      startDate: row['start_date'] != null
          ? DateTime.parse(row['start_date'] as String)
          : null,
      targetDate: row['target_date'] != null
          ? DateTime.parse(row['target_date'] as String)
          : null,
      memberCount: memberCount,
      completedUnits: completedUnits,
    );
  }

  GroupMember _memberFromRow(Map<String, dynamic> row) {
    return GroupMember(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      displayName: row['display_name'] as String,
      role: MemberRole.fromName(row['role'] as String? ?? 'member'),
      joinedAt: DateTime.parse(row['joined_at'] as String),
    );
  }

  JuzClaim _claimFromRow(Map<String, dynamic> row) {
    return JuzClaim(
      juzNumber: (row['juz_number'] as num).toInt(),
      completed: row['completed'] as bool? ?? false,
      claimedBy: row['claimed_by'] as String?,
      claimedName: row['claimed_name'] as String?,
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
    );
  }

  String _nowIso() => DateTime.now().toUtc().toIso8601String();

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
