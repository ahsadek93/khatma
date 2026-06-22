/// Current state of background synchronisation.
enum SyncStatus { offline, idle, syncing, synced, error }

/// Synchronisation seam between the local database and the remote backend.
///
/// The local DB is always the source of truth; a [SyncService] reconciles it
/// with the cloud when configured. The real push/pull implementation lands in
/// P4 — for now the app ships with a no-op so everything works offline.
abstract interface class SyncService {
  SyncStatus get status;
  Stream<SyncStatus> statusChanges();
  Future<void> sync();
}
