import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatmah/core/providers/app_providers.dart';
import 'package:khatmah/core/utils/streams.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma_schedule.dart';
import 'package:khatmah/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:khatmah/features/khatma/khatma_providers.dart';

/// Reactive list of all khatmas (newest first) for the list screen.
final khatmaListProvider = StreamProvider<List<Khatma>>(
  (ref) => ref.watch(khatmaRepositoryProvider).watchKhatmas(),
);

/// Combined read-model for the detail screen: the khatma, its completed juz
/// set, and the derived schedule. `null` [khatma]/[schedule] means it's gone.
class KhatmaDetailState {
  const KhatmaDetailState({
    required this.khatma,
    required this.completed,
    required this.schedule,
  });

  final Khatma? khatma;
  final Set<int> completed;
  final KhatmaSchedule? schedule;

  bool get exists => khatma != null;
}

/// Fuses the khatma and juz-progress streams and computes today's schedule.
final khatmaDetailProvider =
    StreamProvider.autoDispose.family<KhatmaDetailState, String>((ref, id) {
  final repo = ref.watch(khatmaRepositoryProvider);
  final clock = ref.watch(clockProvider);
  return combine2(
    repo.watchKhatma(id),
    repo.watchCompletedJuz(id),
    (Khatma? khatma, Set<int> completed) => KhatmaDetailState(
      khatma: khatma,
      completed: completed,
      schedule: khatma == null
          ? null
          : KhatmaSchedule.of(khatma, today: clock()),
    ),
  );
});

/// Imperative write commands shared across the khatma screens. Reads stay
/// reactive (the providers above); these are the user's intents.
class KhatmaCommands {
  KhatmaCommands(this._repo);

  final KhatmaRepository _repo;

  Future<Khatma> create({
    required String title,
    required DateTime startDate,
    required DateTime targetDate,
  }) =>
      _repo.createKhatma(
        title: title,
        startDate: startDate,
        targetDate: targetDate,
      );

  Future<void> rename(String id, String title) => _repo.renameKhatma(id, title);

  Future<void> delete(String id) => _repo.deleteKhatma(id);

  Future<void> toggleJuz(String khatmaId, int juz, {required bool completed}) =>
      _repo.setJuzCompleted(khatmaId, juz, completed);
}

final khatmaCommandsProvider = Provider<KhatmaCommands>(
  (ref) => KhatmaCommands(ref.watch(khatmaRepositoryProvider)),
);
