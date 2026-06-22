import 'khatma.dart';

/// How a khatma is tracking against its deadline.
enum KhatmaPace { done, ahead, onTrack, behind, overdue }

/// Pure scheduling math derived from a [Khatma] and a given "today".
///
/// All inputs are reduced to calendar days (time-of-day ignored) so results are
/// stable no matter when during the day they're computed.
class KhatmaSchedule {
  const KhatmaSchedule({
    required this.remainingJuz,
    required this.daysRemaining,
    required this.dailyTarget,
    required this.pace,
  });

  /// Ajzāʾ still to read.
  final int remainingJuz;

  /// Calendar days from today through the target date, inclusive. Never < 0.
  final int daysRemaining;

  /// Ajzāʾ to read today to stay on schedule — ceil(remaining / days).
  final int dailyTarget;

  final KhatmaPace pace;

  bool get isOverdue => pace == KhatmaPace.overdue;
  bool get isDone => pace == KhatmaPace.done;

  static KhatmaSchedule of(Khatma khatma, {required DateTime today}) {
    final start = _dateOnly(khatma.startDate);
    final target = _dateOnly(khatma.targetDate);
    final now = _dateOnly(today);

    final remainingJuz = khatma.remainingJuz;

    final rawDaysRemaining = target.difference(now).inDays + 1;
    final daysRemaining = rawDaysRemaining < 0 ? 0 : rawDaysRemaining;

    final int dailyTarget;
    if (remainingJuz == 0) {
      dailyTarget = 0;
    } else if (daysRemaining <= 0) {
      dailyTarget = remainingJuz; // past the deadline: it's all due now
    } else {
      dailyTarget = (remainingJuz / daysRemaining).ceil();
    }

    return KhatmaSchedule(
      remainingJuz: remainingJuz,
      daysRemaining: daysRemaining,
      dailyTarget: dailyTarget,
      pace: _pace(
        khatma: khatma,
        start: start,
        target: target,
        now: now,
        remainingJuz: remainingJuz,
      ),
    );
  }

  static KhatmaPace _pace({
    required Khatma khatma,
    required DateTime start,
    required DateTime target,
    required DateTime now,
    required int remainingJuz,
  }) {
    if (remainingJuz == 0) return KhatmaPace.done;
    if (now.isAfter(target)) return KhatmaPace.overdue;

    final totalSpanDays = target.difference(start).inDays + 1;
    if (totalSpanDays <= 0) return KhatmaPace.onTrack;

    // Days fully elapsed *before* today — so a fresh khatma (and anyone who has
    // read today's portion) reads as on-track rather than instantly "behind".
    var elapsedDays = now.difference(start).inDays;
    if (elapsedDays < 0) elapsedDays = 0;
    if (elapsedDays > totalSpanDays) elapsedDays = totalSpanDays;

    // Ajzāʾ a reader on an even pace should have finished by the start of today.
    final expected = (khatma.totalJuz * elapsedDays / totalSpanDays).round();
    final actual = khatma.completedJuzCount;

    if (actual > expected) return KhatmaPace.ahead;
    if (actual == expected) return KhatmaPace.onTrack;
    return KhatmaPace.behind;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
