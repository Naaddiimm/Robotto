import 'package:sqflite/sqflite.dart';
import 'event_database.dart';
import '../models/competition_detail.dart';
import '../models/event_model.dart';
import '../models/competition_result.dart';

/// Repository pour les tables [competitions] et [competition_results].
class CompetitionRepository {
  final EventDatabase _db = EventDatabase.instance;

  // -------------------------------------------------------------------------
  // CompetitionDetail CRUD
  // -------------------------------------------------------------------------

  Future<void> upsertDetail(CompetitionDetail detail) async {
    final db = await _db.database;
    await db.insert(
      'competitions',
      detail.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CompetitionDetail?> getDetail(int eventId) async {
    final db = await _db.database;
    final maps = await db.query(
      'competitions',
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CompetitionDetail.fromMap(maps.first);
  }

  Future<void> deleteDetail(int eventId) async {
    final db = await _db.database;
    await db.delete('competitions', where: 'id = ?', whereArgs: [eventId]);
  }

  // -------------------------------------------------------------------------
  // Competitions list (joins events + competitions)
  // -------------------------------------------------------------------------

  Future<List<EventModel>> getAllCompetitions() async {
    final db = await _db.database;
    final maps = await db.query(
      'events',
      where: "type = 'competition'",
      orderBy: 'start_date ASC',
    );
    return maps.map(EventModel.fromMap).toList();
  }

  Future<List<EventModel>> getPublishedCompetitions() async {
    final db = await _db.database;
    final maps = await db.query(
      'events',
      where: "type = 'competition' AND status = 'published'",
      orderBy: 'start_date ASC',
    );
    return maps.map(EventModel.fromMap).toList();
  }

  // -------------------------------------------------------------------------
  // Results CRUD
  // -------------------------------------------------------------------------

  Future<int> addResult(CompetitionResult result) async {
    final db = await _db.database;
    return await db.insert(
      'competition_results',
      result.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CompetitionResult>> getResults(int eventId) async {
    final db = await _db.database;
    final maps = await db.query(
      'competition_results',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'rank ASC',
    );
    return maps.map(CompetitionResult.fromMap).toList();
  }

  Future<int> updateResult(CompetitionResult result) async {
    final db = await _db.database;
    return await db.update(
      'competition_results',
      result.toMap(),
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  Future<int> deleteResult(int id) async {
    final db = await _db.database;
    return await db.delete('competition_results',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllResults(int eventId) async {
    final db = await _db.database;
    await db.delete('competition_results',
        where: 'event_id = ?', whereArgs: [eventId]);
  }

  /// Publie les résultats d'une compétition.
  Future<void> publishResults(int eventId) async {
    final db = await _db.database;
    await db.update(
      'competitions',
      {'results_published': 1},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }
}
