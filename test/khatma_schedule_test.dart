import 'package:flutter_test/flutter_test.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma_schedule.dart';

/// Builds a khatma spanning [days] calendar days starting [startOffsetDays]
/// relative to a fixed "today", with [completed] ajzāʾ done.
Khatma _khatma({
  required DateTime today,
  required int startOffsetDays,
  required int days,
  required int completed,
}) {
  final start = today.add(Duration(days: startOffsetDays));
  final target = start.add(Duration(days: days - 1));
  return Khatma(
    id: 'k',
    title: 'Test',
    totalJuz: 30,
    startDate: start,
    targetDate: target,
    status: KhatmaStatus.active,
    createdAt: start,
    updatedAt: start,
    completedJuzCount: completed,
  );
}

void main() {
  final today = DateTime(2026, 6, 22);

  group('KhatmaSchedule', () {
    test('fresh 30-day khatma on day one is on track, target 1 juz/day', () {
      final s = KhatmaSchedule.of(
        _khatma(today: today, startOffsetDays: 0, days: 30, completed: 0),
        today: today,
      );
      expect(s.daysRemaining, 30);
      expect(s.dailyTarget, 1);
      expect(s.remainingJuz, 30);
      expect(s.pace, KhatmaPace.onTrack);
    });

    test('7-day khatma needs ceil(30/7) = 5 juz a day', () {
      final s = KhatmaSchedule.of(
        _khatma(today: today, startOffsetDays: 0, days: 7, completed: 0),
        today: today,
      );
      expect(s.dailyTarget, 5);
    });

    test('keeping pace mid-way reads as on track', () {
      final s = KhatmaSchedule.of(
        _khatma(today: today, startOffsetDays: -10, days: 30, completed: 10),
        today: today,
      );
      expect(s.pace, KhatmaPace.onTrack);
      expect(s.remainingJuz, 20);
      expect(s.daysRemaining, 20);
      expect(s.dailyTarget, 1);
    });

    test('falling behind raises the daily target and flags behind', () {
      final s = KhatmaSchedule.of(
        _khatma(today: today, startOffsetDays: -10, days: 30, completed: 5),
        today: today,
      );
      expect(s.pace, KhatmaPace.behind);
      expect(s.remainingJuz, 25);
      expect(s.daysRemaining, 20);
      expect(s.dailyTarget, 2); // ceil(25 / 20)
    });

    test('reading ahead of pace flags ahead', () {
      final s = KhatmaSchedule.of(
        _khatma(today: today, startOffsetDays: -10, days: 30, completed: 18),
        today: today,
      );
      expect(s.pace, KhatmaPace.ahead);
    });

    test('all juz complete is done with no remaining work', () {
      final s = KhatmaSchedule.of(
        _khatma(today: today, startOffsetDays: -5, days: 30, completed: 30),
        today: today,
      );
      expect(s.pace, KhatmaPace.done);
      expect(s.remainingJuz, 0);
      expect(s.dailyTarget, 0);
    });

    test('past the deadline with work left is overdue, all due now', () {
      final s = KhatmaSchedule.of(
        _khatma(today: today, startOffsetDays: -40, days: 30, completed: 20),
        today: today,
      );
      expect(s.pace, KhatmaPace.overdue);
      expect(s.daysRemaining, 0);
      expect(s.dailyTarget, 10);
    });
  });
}
