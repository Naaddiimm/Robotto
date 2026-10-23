import 'package:sqflite/sqflite.dart';
import 'event_database.dart';
import '../models/event_team.dart';

/// Repository pour [event_teams] et [event_team_members].
class TeamRepository {
  final EventDatabase _db = EventDatabase.instance;

  // -------------------------------------------------------------------------
  // Teams CRUD
  // -------------------------------------------------------------------------

  Future<int> createTeam(EventTeam team) async {
    final db = await _db.database;
    final id = await db.insert(
      'event_teams',
      team.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    // Le leader devient automatiquement membre
    await db.insert('event_team_members', {
      'team_id': id,
      'user_id': team.leaderId,
      'role': 'leader',
      'joined_at': team.createdAt,
    });
    return id;
  }

  Future<List<EventTeam>> getTeamsForEvent(int eventId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT t.*, COUNT(m.id) as member_count
      FROM event_teams t
      LEFT JOIN event_team_members m ON m.team_id = t.id
      WHERE t.event_id = ?
      GROUP BY t.id
      ORDER BY t.created_at ASC
    ''', [eventId]);
    return maps.map(EventTeam.fromMap).toList();
  }

  Future<EventTeam?> getTeamById(int id) async {
    final db = await _db.database;
    final maps = await db.query('event_teams',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return EventTeam.fromMap(maps.first);
  }

  Future<int> updateTeamName(int id, String newName) async {
    final db = await _db.database;
    return await db.update('event_teams', {'name': newName},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTeam(int id) async {
    final db = await _db.database;
    return await db.delete('event_teams', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------------------------------------------------------------
  // Members CRUD
  // -------------------------------------------------------------------------

  Future<List<EventTeamMember>> getMembers(int teamId) async {
    final db = await _db.database;
    final maps = await db.query(
      'event_team_members',
      where: 'team_id = ?',
      whereArgs: [teamId],
      orderBy: 'joined_at ASC',
    );
    return maps.map(EventTeamMember.fromMap).toList();
  }

  Future<bool> isMember(int teamId, int userId) async {
    final db = await _db.database;
    final maps = await db.query(
      'event_team_members',
      where: 'team_id = ? AND user_id = ?',
      whereArgs: [teamId, userId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> addMember(int teamId, int userId) async {
    final db = await _db.database;
    return await db.insert(
      'event_team_members',
      {
        'team_id': teamId,
        'user_id': userId,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> removeMember(int teamId, int userId) async {
    final db = await _db.database;
    return await db.delete(
      'event_team_members',
      where: 'team_id = ? AND user_id = ?',
      whereArgs: [teamId, userId],
    );
  }

  /// Retourne l'équipe d'un utilisateur pour un événement donné, ou null.
  Future<EventTeam?> getUserTeamForEvent(int eventId, int userId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT t.*, COUNT(m2.id) as member_count
      FROM event_teams t
      JOIN event_team_members m ON m.team_id = t.id AND m.user_id = ?
      LEFT JOIN event_team_members m2 ON m2.team_id = t.id
      WHERE t.event_id = ?
      GROUP BY t.id
      LIMIT 1
    ''', [userId, eventId]);
    if (maps.isEmpty) return null;
    return EventTeam.fromMap(maps.first);
  }
}
