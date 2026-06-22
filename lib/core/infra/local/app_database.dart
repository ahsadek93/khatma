import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tables
//
// Every table carries sync-ready bookkeeping so the local DB can later be
// reconciled against Supabase without a schema change:
//   id        — client-generated UUID (stable across devices)
//   ownerId   — auth.uid() once signed in; null while local-only
//   createdAt / updatedAt — last-writer-wins clocks
//   deletedAt — soft delete (tombstone) so deletions propagate
//   groupId   — reserved for phase-2 multi-user (group) khatmas
// ---------------------------------------------------------------------------

@DataClassName('KhatmaRow')
class Khatmas extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  IntColumn get totalJuz => integer().withDefault(const Constant(30))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get groupId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('JuzEntryRow')
class JuzEntries extends Table {
  TextColumn get id => text()();
  TextColumn get khatmaId => text().references(Khatmas, #id)();
  IntColumn get juzNumber => integer()(); // 1..totalJuz
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get ownerId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get groupId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // One row per (khatma, juz). Un-marking soft-deletes the row rather than
  // removing it, and re-marking revives it — so this stays unique.
  @override
  List<Set<Column>> get uniqueKeys => [
        {khatmaId, juzNumber},
      ];
}

// ---------------------------------------------------------------------------
// DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [Khatmas, JuzEntries])
class KhatmaDao extends DatabaseAccessor<AppDatabase> with _$KhatmaDaoMixin {
  KhatmaDao(super.db);

  /// All non-deleted khatmas, newest first, each paired with its live count of
  /// completed (non-deleted) ajzāʾ.
  Stream<List<(KhatmaRow, int)>> watchKhatmasWithCounts() {
    final completed = juzEntries.id.count(filter: juzEntries.deletedAt.isNull());
    final query = select(khatmas).join([
      leftOuterJoin(juzEntries, juzEntries.khatmaId.equalsExp(khatmas.id)),
    ])
      ..where(khatmas.deletedAt.isNull())
      ..addColumns([completed])
      ..groupBy([khatmas.id])
      ..orderBy([OrderingTerm.desc(khatmas.createdAt)]);
    return query.watch().map(
          (rows) => rows
              .map((row) => (row.readTable(khatmas), row.read(completed) ?? 0))
              .toList(),
        );
  }

  /// A single khatma with its completed count, or null if missing/deleted.
  Stream<(KhatmaRow, int)?> watchKhatmaWithCount(String id) {
    final completed = juzEntries.id.count(filter: juzEntries.deletedAt.isNull());
    final query = select(khatmas).join([
      leftOuterJoin(juzEntries, juzEntries.khatmaId.equalsExp(khatmas.id)),
    ])
      ..where(khatmas.id.equals(id) & khatmas.deletedAt.isNull())
      ..addColumns([completed])
      ..groupBy([khatmas.id]);
    return query.watchSingleOrNull().map(
          (row) => row == null
              ? null
              : (row.readTable(khatmas), row.read(completed) ?? 0),
        );
  }

  /// Juz numbers currently marked complete for a khatma, ascending.
  Stream<List<int>> watchCompletedJuz(String khatmaId) {
    final query = select(juzEntries)
      ..where((t) => t.khatmaId.equals(khatmaId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.juzNumber)]);
    return query.watch().map((rows) => rows.map((r) => r.juzNumber).toList());
  }

  Future<KhatmaRow?> getKhatma(String id) =>
      (select(khatmas)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> completedCount(String khatmaId) async {
    final count = juzEntries.id.count();
    final query = selectOnly(juzEntries)
      ..addColumns([count])
      ..where(
        juzEntries.khatmaId.equals(khatmaId) & juzEntries.deletedAt.isNull(),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> insertKhatma(KhatmasCompanion entry) =>
      into(khatmas).insert(entry);

  Future<void> renameKhatma(String id, String title, DateTime now) =>
      (update(khatmas)..where((t) => t.id.equals(id))).write(
        KhatmasCompanion(title: Value(title), updatedAt: Value(now)),
      );

  Future<void> updateStatus(String id, String status, DateTime now) =>
      (update(khatmas)..where((t) => t.id.equals(id))).write(
        KhatmasCompanion(status: Value(status), updatedAt: Value(now)),
      );

  Future<void> softDeleteKhatma(String id, DateTime now) =>
      (update(khatmas)..where((t) => t.id.equals(id))).write(
        KhatmasCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );

  /// Marks one juz complete or not. Inserts a fresh row, revives a tombstoned
  /// one, or tombstones a live one — preserving the (khatma, juz) uniqueness.
  Future<void> setJuzCompleted({
    required String newId,
    required String khatmaId,
    required int juzNumber,
    required bool completed,
    required DateTime now,
    String? ownerId,
  }) async {
    final existing = await (select(juzEntries)
          ..where((t) =>
              t.khatmaId.equals(khatmaId) & t.juzNumber.equals(juzNumber)))
        .getSingleOrNull();

    if (completed) {
      if (existing == null) {
        await into(juzEntries).insert(
          JuzEntriesCompanion.insert(
            id: newId,
            khatmaId: khatmaId,
            juzNumber: juzNumber,
            completedAt: now,
            createdAt: now,
            updatedAt: now,
            ownerId: Value(ownerId),
          ),
        );
      } else {
        await (update(juzEntries)..where((t) => t.id.equals(existing.id))).write(
          JuzEntriesCompanion(
            completedAt: Value(now),
            deletedAt: const Value(null),
            updatedAt: Value(now),
          ),
        );
      }
    } else if (existing != null && existing.deletedAt == null) {
      await (update(juzEntries)..where((t) => t.id.equals(existing.id))).write(
        JuzEntriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Khatmas, JuzEntries], daos: [KhatmaDao])
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database. Pass a custom [executor] (e.g. an in-memory
  /// one) in tests.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'khatmah'));

  @override
  int get schemaVersion => 1;
}
