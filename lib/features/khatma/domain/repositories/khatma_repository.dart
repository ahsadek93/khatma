import '../entities/khatma.dart';

/// Contract for khatma persistence.
///
/// Implemented in the data layer; the domain and presentation never see Drift,
/// Supabase or any storage detail — they depend only on this interface.
abstract interface class KhatmaRepository {
  /// All non-deleted khatmas, newest first, with live completed-juz counts.
  Stream<List<Khatma>> watchKhatmas();

  /// A single khatma (with its completed-juz count), or null if missing.
  Stream<Khatma?> watchKhatma(String id);

  /// The set of juz numbers (1..totalJuz) currently marked complete.
  Stream<Set<int>> watchCompletedJuz(String khatmaId);

  Future<Khatma> createKhatma({
    required String title,
    required DateTime startDate,
    required DateTime targetDate,
    int totalJuz,
  });

  Future<void> renameKhatma(String id, String title);

  Future<void> deleteKhatma(String id);

  /// Marks [juzNumber] (1..totalJuz) complete or not for a khatma. Toggling
  /// also keeps the khatma's [KhatmaStatus] in sync (active ↔ completed).
  Future<void> setJuzCompleted(String khatmaId, int juzNumber, bool completed);
}
