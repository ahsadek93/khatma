enum MemberRole {
  owner,
  member;

  static MemberRole fromName(String value) => values.firstWhere(
        (r) => r.name == value,
        orElse: () => MemberRole.member,
      );
}

/// A participant in a shared khatma. Identity is the backend user id (anonymous
/// in v1) plus a chosen [displayName].
class GroupMember {
  const GroupMember({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final MemberRole role;
  final DateTime joinedAt;

  bool get isOwner => role == MemberRole.owner;
}
