import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Provides the [SharedPreferences] instance. Overridden in `main()` after
/// async initialisation so the rest of the app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// Shared UUID generator for stable, sync-friendly record ids.
final uuidProvider = Provider<Uuid>((ref) => const Uuid());
