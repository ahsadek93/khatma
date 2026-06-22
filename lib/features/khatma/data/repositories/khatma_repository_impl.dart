// Public ctor labels (dao:/uuid:/now:/auth:) are kept deliberately distinct
// from the private fields, so initializing formals don't apply here.
// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart' show Value;
import 'package:khatmah/core/infra/local/app_database.dart';
import 'package:khatmah/core/sync/auth_service.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma.dart';
import 'package:khatmah/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:uuid/uuid.dart';

/// Drift-backed [KhatmaRepository]. Maps storage rows to pure domain entities
/// and stamps every write with sync bookkeeping (uuid, ownerId, clocks).
class DriftKhatmaRepository implements KhatmaRepository {
  DriftKhatmaRepository({
    required KhatmaDao dao,
    required Uuid uuid,
    required DateTime Function() now,
    required AuthService auth,
  })  : _dao = dao,
        _uuid = uuid,
        _now = now,
        _auth = auth;

  final KhatmaDao _dao;
  final Uuid _uuid;
  final DateTime Function() _now;
  final AuthService _auth;

  @override
  Stream<List<Khatma>> watchKhatmas() =>
      _dao.watchKhatmasWithCounts().map((rows) => rows.map(_toEntity).toList());

  @override
  Stream<Khatma?> watchKhatma(String id) => _dao
      .watchKhatmaWithCount(id)
      .map((record) => record == null ? null : _toEntity(record));

  @override
  Stream<Set<int>> watchCompletedJuz(String khatmaId) =>
      _dao.watchCompletedJuz(khatmaId).map((list) => list.toSet());

  @override
  Future<Khatma> createKhatma({
    required String title,
    required DateTime startDate,
    required DateTime targetDate,
    int totalJuz = 30,
  }) async {
    final now = _now();
    final id = _uuid.v4();
    await _dao.insertKhatma(
      KhatmasCompanion.insert(
        id: id,
        title: title,
        startDate: startDate,
        targetDate: targetDate,
        createdAt: now,
        updatedAt: now,
        totalJuz: Value(totalJuz),
        ownerId: Value(_auth.currentUserId),
      ),
    );
    return Khatma(
      id: id,
      title: title,
      totalJuz: totalJuz,
      startDate: startDate,
      targetDate: targetDate,
      status: KhatmaStatus.active,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> renameKhatma(String id, String title) =>
      _dao.renameKhatma(id, title, _now());

  @override
  Future<void> deleteKhatma(String id) => _dao.softDeleteKhatma(id, _now());

  @override
  Future<void> setJuzCompleted(
    String khatmaId,
    int juzNumber,
    bool completed,
  ) async {
    final now = _now();
    await _dao.setJuzCompleted(
      newId: _uuid.v4(),
      khatmaId: khatmaId,
      juzNumber: juzNumber,
      completed: completed,
      now: now,
      ownerId: _auth.currentUserId,
    );

    // Keep the khatma's status in step with its completion (active ↔ completed,
    // never touching an archived khatma).
    final row = await _dao.getKhatma(khatmaId);
    if (row == null || row.status == KhatmaStatus.archived.name) return;
    final count = await _dao.completedCount(khatmaId);
    final desired = count >= row.totalJuz
        ? KhatmaStatus.completed.name
        : KhatmaStatus.active.name;
    if (row.status != desired) {
      await _dao.updateStatus(khatmaId, desired, now);
    }
  }

  Khatma _toEntity((KhatmaRow, int) record) {
    final (row, completedCount) = record;
    return Khatma(
      id: row.id,
      title: row.title,
      totalJuz: row.totalJuz,
      startDate: row.startDate,
      targetDate: row.targetDate,
      status: KhatmaStatus.fromName(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedJuzCount: completedCount,
    );
  }
}
