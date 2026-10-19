import 'package:sqflite/sqflite.dart';
import 'event_database.dart';
import '../models/event_model.dart';

/// Repository CRUD pour la table [events].
/// Toutes les opérations passent par [EventDatabase] — jamais par robotto.db.
class EventRepository {
  final EventDatabase _db = EventDatabase.instance;

  // -------------------------------------------------------------------------
  // CREATE
  // -------------------------------------------------------------------------

  /// Insère un événement et retourne son nouvel ID.
  Future<int> createEvent(EventModel event) async {
    final db = await _db.database;
    final map = event.toMap()..remove('id');
    return await db.insert('events', map,
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  // -------------------------------------------------------------------------
  // READ
  // -------------------------------------------------------------------------

  /// Retourne tous les événements, les plus récents en premier.
  Future<List<EventModel>> getAllEvents() async {
    final db = await _db.database;
    final maps = await db.query('events', orderBy: 'created_at DESC');
    return maps.map(EventModel.fromMap).toList();
  }

  /// Retourne uniquement les événements publiés (pour les visiteurs/utilisateurs).
  Future<List<EventModel>> getPublishedEvents() async {
    final db = await _db.database;
    final maps = await db.query(
      'events',
      where: 'status = ?',
      whereArgs: ['published'],
      orderBy: 'start_date ASC',
    );
    return maps.map(EventModel.fromMap).toList();
  }

  /// Retourne un événement par son ID, ou null s'il n'existe pas.
  Future<EventModel?> getEventById(int id) async {
    final db = await _db.database;
    final maps =
        await db.query('events', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return EventModel.fromMap(maps.first);
  }

  /// Retourne tous les événements créés par un organisateur donné.
  Future<List<EventModel>> getEventsByOrganizer(int organizerId) async {
    final db = await _db.database;
    final maps = await db.query(
      'events',
      where: 'organizer_id = ?',
      whereArgs: [organizerId],
      orderBy: 'created_at DESC',
    );
    return maps.map(EventModel.fromMap).toList();
  }

  /// Filtre combiné : type, catégorie, niveau, mode, statut.
  /// Passe null pour ignorer un filtre.
  Future<List<EventModel>> filterEvents({
    String? type,
    String? category,
    String? level,
    String? mode,
    String? status,
    String? searchQuery,
  }) async {
    final db = await _db.database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      conditions.add('type = ?');
      args.add(type);
    }
    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }
    if (level != null) {
      conditions.add('level = ?');
      args.add(level);
    }
    if (mode != null) {
      conditions.add('mode = ?');
      args.add(mode);
    }
    if (status != null) {
      conditions.add('status = ?');
      args.add(status);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      conditions.add('(title LIKE ? OR description LIKE ? OR location LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      args.addAll([q, q, q]);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');
    final maps = await db.query(
      'events',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'start_date ASC',
    );
    return maps.map(EventModel.fromMap).toList();
  }

  // -------------------------------------------------------------------------
  // UPDATE
  // -------------------------------------------------------------------------

  /// Met à jour un événement existant. Retourne le nombre de lignes modifiées.
  Future<int> updateEvent(EventModel event) async {
    final db = await _db.database;
    final map = event.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'events',
      map,
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Met à jour uniquement le statut d'un événement.
  Future<int> updateEventStatus(int id, String status) async {
    final db = await _db.database;
    return await db.update(
      'events',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------------------
  // DELETE
  // -------------------------------------------------------------------------

  /// Supprime définitivement un événement (cascade sur inscriptions, équipes, etc.).
  Future<int> deleteEvent(int id) async {
    final db = await _db.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  /// Retourne le nombre de places confirmées prises pour un événement.
  Future<int> getConfirmedRegistrationsCount(int eventId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM event_registrations WHERE event_id = ? AND status = 'confirmed'",
      [eventId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
