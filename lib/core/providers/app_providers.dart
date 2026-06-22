import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../infra/local/app_database.dart';

/// Provides the [SharedPreferences] instance. Overridden in `main()` after
/// async initialisation so the rest of the app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// Shared UUID generator for stable, sync-friendly record ids.
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

/// Injectable clock. Returning a function (not a [DateTime]) keeps reads live
/// and lets tests pin "now".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The single on-device Drift database, closed when the container disposes.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
