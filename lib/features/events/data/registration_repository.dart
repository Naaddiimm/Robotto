import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'event_database.dart';
import '../models/event_registration.dart';

/// Repository pour les inscriptions ([event_registrations]).
class RegistrationRepository {
  final EventDatabase _db = EventDatabase.instance;

  // -------------------------------------------------------------------------
  // CREATE
  // -------------------------------------------------------------------------

  /// Inscrit un utilisateur. Génère un ticket_code unique.
  /// Lève une exception si l'utilisateur est déjà inscrit (contrainte UNIQUE).
  Future<int> register({
    required int eventId,
    required int userId,
    int? teamId,
  }) async {
    final db = await _db.database;
    final ticketCode = _generateTicketCode(eventId, userId);
    return await db.insert(
      'event_registrations',
      {
        'event_id': eventId,
        'user_id': userId,
        'status': 'confirmed',
        'team_id': teamId,
        'ticket_code': ticketCode,
        'registered_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // -------------------------------------------------------------------------
  // READ
  // -------------------------------------------------------------------------

  /// Retourne l'inscription d'un utilisateur pour un événement, ou null.
  Future<EventRegistration?> getRegistration(
      int eventId, int userId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT r.*, e.title, e.type, e.start_date
      FROM event_registrations r
      JOIN events e ON e.id = r.event_id
      WHERE r.event_id = ? AND r.user_id = ?
      LIMIT 1
    ''', [eventId, userId]);
    if (maps.isEmpty) return null;
    return EventRegistration.fromMap(maps.first);
  }

  /// Retourne toutes les inscriptions d'un utilisateur.
  Future<List<EventRegistration>> getUserRegistrations(int userId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT r.*, e.title, e.type, e.start_date
      FROM event_registrations r
      JOIN events e ON e.id = r.event_id
      WHERE r.user_id = ?
      ORDER BY r.registered_at DESC
    ''', [userId]);
    return maps.map(EventRegistration.fromMap).toList();
  }

  /// Retourne tous les participants d'un événement.
  Future<List<EventRegistration>> getEventParticipants(int eventId) async {
    final db = await _db.database;
    final maps = await db.query(
      'event_registrations',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'registered_at ASC',
    );
    return maps.map(EventRegistration.fromMap).toList();
  }

  /// Retourne le nombre d'inscriptions confirmées pour un événement.
  Future<int> getConfirmedCount(int eventId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM event_registrations WHERE event_id = ? AND status = 'confirmed'",
      [eventId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // -------------------------------------------------------------------------
  // CHECK-IN (validation de présence par QR code)
  // -------------------------------------------------------------------------

  /// Recherche une inscription par son ticket_code.
  /// Retourne null si le code n'existe pas.
  Future<EventRegistration?> getByTicketCode(String ticketCode) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT r.*, e.title, e.type, e.start_date
      FROM event_registrations r
      JOIN events e ON e.id = r.event_id
      WHERE r.ticket_code = ?
      LIMIT 1
    ''', [ticketCode]);
    if (maps.isEmpty) return null;
    return EventRegistration.fromMap(maps.first);
  }

  /// Marque une inscription comme présente de façon atomique.
  /// Utilise un UPDATE conditionnel pour éviter la double validation.
  /// Retourne true si la mise à jour a réussi (exactement 1 ligne affectée),
  /// false si checked_in_at était déjà défini (doublon détecté).
  Future<bool> checkIn(int registrationId) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    // WHERE checked_in_at IS NULL garantit l'atomicité : si déjà validé → 0 rows
    final rows = await db.rawUpdate(
      '''UPDATE event_registrations
         SET checked_in_at = ?
         WHERE id = ? AND checked_in_at IS NULL''',
      [now, registrationId],
    );
    return rows == 1;
  }

  // -------------------------------------------------------------------------
  // UPDATE
  // -------------------------------------------------------------------------

  /// Annule une inscription.
  Future<int> cancel(int eventId, int userId) async {
    final db = await _db.database;
    return await db.update(
      'event_registrations',
      {
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
      },
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
    );
  }

  /// Met à jour le statut d'une inscription.
  Future<int> updateStatus(int id, String status) async {
    final db = await _db.database;
    return await db.update(
      'event_registrations',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------------------
  // DELETE
  // -------------------------------------------------------------------------

  Future<int> deleteRegistration(int eventId, int userId) async {
    final db = await _db.database;
    return await db.delete(
      'event_registrations',
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
    );
  }

  // -------------------------------------------------------------------------
  // Helper
  // -------------------------------------------------------------------------

  /// Génère un code de billet unique : EVT-{eventId}-{userId}-{random4}.
  String _generateTicketCode(int eventId, int userId) {
    final rnd = Random.secure().nextInt(9000) + 1000;
    return 'EVT-$eventId-$userId-$rnd';
  }
}
