import 'event_database.dart';
import '../models/event_announcement.dart';

/// Repository pour les annonces et actualités ([event_announcements]).
class AnnouncementRepository {
  final EventDatabase _db = EventDatabase.instance;

  Future<int> create(EventAnnouncement a) async {
    final db = await _db.database;
    return await db.insert('event_announcements', a.toMap()..remove('id'));
  }

  /// Toutes les annonces (globales + événement), les épinglées en premier.
  Future<List<EventAnnouncement>> getAll() async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT a.*, e.title as event_title
      FROM event_announcements a
      LEFT JOIN events e ON e.id = a.event_id
      ORDER BY a.is_pinned DESC, a.created_at DESC
    ''');
    return maps.map(EventAnnouncement.fromMap).toList();
  }

  /// Annonces liées à un événement précis.
  Future<List<EventAnnouncement>> getByEvent(int eventId) async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      '''
      SELECT a.*, e.title as event_title
      FROM event_announcements a
      LEFT JOIN events e ON e.id = a.event_id
      WHERE a.event_id = ?
      ORDER BY a.is_pinned DESC, a.created_at DESC
    ''',
      [eventId],
    );
    return maps.map(EventAnnouncement.fromMap).toList();
  }

  /// Actualités générales uniquement (event_id IS NULL, type = 'news').
  Future<List<EventAnnouncement>> getNews() async {
    final db = await _db.database;
    final maps = await db.query(
      'event_announcements',
      where: "event_id IS NULL AND type = 'news'",
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return maps.map(EventAnnouncement.fromMap).toList();
  }

  Future<EventAnnouncement?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      '''
      SELECT a.*, e.title as event_title
      FROM event_announcements a
      LEFT JOIN events e ON e.id = a.event_id
      WHERE a.id = ?
      LIMIT 1
    ''',
      [id],
    );
    if (maps.isEmpty) return null;
    return EventAnnouncement.fromMap(maps.first);
  }

  Future<int> update(EventAnnouncement a) async {
    final db = await _db.database;
    final map = a.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'event_announcements',
      map,
      where: 'id = ?',
      whereArgs: [a.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'event_announcements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> togglePin(int id, bool pinned) async {
    final db = await _db.database;
    return await db.update(
      'event_announcements',
      {'is_pinned': pinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
