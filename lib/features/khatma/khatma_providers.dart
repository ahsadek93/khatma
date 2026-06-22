import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatmah/core/infra/local/app_database.dart';
import 'package:khatmah/core/providers/app_providers.dart';
import 'package:khatmah/core/sync/sync_providers.dart';
import 'package:khatmah/features/khatma/data/repositories/khatma_repository_impl.dart';
import 'package:khatmah/features/khatma/domain/repositories/khatma_repository.dart';

/// The khatma DAO, bound to the app's single database.
final khatmaDaoProvider = Provider<KhatmaDao>(
  (ref) => ref.watch(appDatabaseProvider).khatmaDao,
);

/// The khatma repository — the only seam the feature's UI/view-models touch.
final khatmaRepositoryProvider = Provider<KhatmaRepository>((ref) {
  return DriftKhatmaRepository(
    dao: ref.watch(khatmaDaoProvider),
    uuid: ref.watch(uuidProvider),
    now: ref.watch(clockProvider),
    auth: ref.watch(authServiceProvider),
  );
});
