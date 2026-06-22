/// Lifecycle of one juz within a shared khatma.
enum JuzClaimStatus { unclaimed, claimed, completed }

/// One juz in a group khatma: who (if anyone) has taken responsibility for it,
/// and whether it has been read.
class JuzClaim {
  const JuzClaim({
    required this.juzNumber,
    required this.completed,
    this.claimedBy,
    this.claimedName,
    this.completedAt,
  });

  final int juzNumber;
  final bool completed;

  /// Member user id who claimed it, or null if open.
  final String? claimedBy;

  /// Denormalised display name of the claimer, for direct rendering.
  final String? claimedName;
  final DateTime? completedAt;

  JuzClaimStatus get status {
    if (completed) return JuzClaimStatus.completed;
    if (claimedBy != null) return JuzClaimStatus.claimed;
    return JuzClaimStatus.unclaimed;
  }

  bool isClaimedBy(String? userId) =>
      claimedBy != null && userId != null && claimedBy == userId;
}
