import 'sync_service.dart';

/// Offline [SyncService]: reconciliation is a no-op and status is always
/// [SyncStatus.offline]. The local database stands alone.
class NoopSyncService implements SyncService {
  const NoopSyncService();

  @override
  SyncStatus get status => SyncStatus.offline;

  @override
  Stream<SyncStatus> statusChanges() => const Stream.empty();

  @override
  Future<void> sync() async {}
}
