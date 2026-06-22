/// Lifecycle of a khatma.
enum KhatmaStatus {
  active,
  completed,
  archived;

  static KhatmaStatus fromName(String value) => KhatmaStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => KhatmaStatus.active,
      );
}

/// A single Qur'an khatma: a goal to read [totalJuz] ajzāʾ between [startDate]
/// and [targetDate].
///
/// Pure domain model — no Flutter, no persistence types. [completedJuzCount] is
/// a read-model convenience the repository fills from the progress table; it is
/// not stored on the khatma itself.
class Khatma {
  const Khatma({
    required this.id,
    required this.title,
    required this.totalJuz,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedJuzCount = 0,
  });

  final String id;
  final String title;
  final int totalJuz;
  final DateTime startDate;
  final DateTime targetDate;
  final KhatmaStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// How many ajzāʾ are currently marked complete (non-deleted).
  final int completedJuzCount;

  int get remainingJuz {
    final r = totalJuz - completedJuzCount;
    if (r < 0) return 0;
    if (r > totalJuz) return totalJuz;
    return r;
  }

  double get progress {
    if (totalJuz <= 0) return 0;
    final p = completedJuzCount / totalJuz;
    if (p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }

  bool get isComplete => totalJuz > 0 && completedJuzCount >= totalJuz;

  Khatma copyWith({
    String? title,
    int? totalJuz,
    DateTime? startDate,
    DateTime? targetDate,
    KhatmaStatus? status,
    DateTime? updatedAt,
    int? completedJuzCount,
  }) {
    return Khatma(
      id: id,
      title: title ?? this.title,
      totalJuz: totalJuz ?? this.totalJuz,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedJuzCount: completedJuzCount ?? this.completedJuzCount,
    );
  }
}
