/// The contribution model of a shared khatma — the heart of the multi-user
/// principle.
enum GroupKhatmaKind {
  /// PARTITIONED: the goal is split into discrete claimable units (30 juz).
  /// Each unit is claimed by one member and completed by them.
  quran,

  /// ACCUMULATIVE: the goal is a target count; members append conflict-free
  /// increments to a shared total. Reserved — ships post-v1.
  zikr;

  static GroupKhatmaKind fromName(String value) => values.firstWhere(
        (k) => k.name == value,
        orElse: () => GroupKhatmaKind.quran,
      );
}

enum GroupKhatmaStatus {
  active,
  completed,
  archived;

  static GroupKhatmaStatus fromName(String value) => values.firstWhere(
        (s) => s.name == value,
        orElse: () => GroupKhatmaStatus.active,
      );
}

/// A shared khatma completed collectively by a group. Source of truth is the
/// remote backend (membership is inherently multi-device). [memberCount] and
/// [completedUnits] are read-model conveniences the repository fills.
class GroupKhatma {
  const GroupKhatma({
    required this.id,
    required this.kind,
    required this.title,
    required this.totalUnits,
    required this.status,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    this.zikrPhrase,
    this.startDate,
    this.targetDate,
    this.memberCount = 0,
    this.completedUnits = 0,
  });

  final String id;
  final GroupKhatmaKind kind;
  final String title;

  /// Quran: number of juz (30). Zikr: the collective target count.
  final int totalUnits;
  final GroupKhatmaStatus status;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final String? zikrPhrase;
  final DateTime? startDate;
  final DateTime? targetDate;

  final int memberCount;
  final int completedUnits;

  int get remainingUnits {
    final r = totalUnits - completedUnits;
    return r < 0 ? 0 : r;
  }

  double get progress {
    if (totalUnits <= 0) return 0;
    final p = completedUnits / totalUnits;
    if (p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }

  bool get isComplete => totalUnits > 0 && completedUnits >= totalUnits;
}
