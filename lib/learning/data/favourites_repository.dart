// ---------------------------------------------------------------------------
// FavouritesRepository — persists favourite lessons using the shared
// robotto.db SQLite database (via DatabaseHelper).
// The table is created on first use via a migration-safe IF NOT EXISTS.
// ---------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import '../../data/database_helper.dart';

class FavouriteLesson {
  final int id;
  final String title;
  final String duration;
  final String module;

  const FavouriteLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.module,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'duration': duration,
        'module': module,
      };

  factory FavouriteLesson.fromMap(Map<String, dynamic> m) => FavouriteLesson(
        id: m['id'] as int,
        title: m['title'] as String,
        duration: m['duration'] as String,
        module: m['module'] as String,
      );
}

class FavouritesRepository {
  FavouritesRepository._();
  static final FavouritesRepository instance = FavouritesRepository._();

  static const _table = 'learning_favourites';

  // In-memory cache for synchronous isFavourite checks
  final Set<int> _cache = {};
  bool _initialised = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialised) return;
    // sqflite not available on web — skip DB init, use in-memory only
    if (kIsWeb) {
      _initialised = true;
      return;
    }
    final db = await DatabaseHelper.instance.database;

    // Safe migration — creates the table only if it doesn't exist yet
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        id       INTEGER PRIMARY KEY,
        title    TEXT    NOT NULL,
        duration TEXT    NOT NULL,
        module   TEXT    NOT NULL
      )
    ''');

    // Seed in-memory cache from DB
    final rows = await db.query(_table);
    _cache
      ..clear()
      ..addAll(rows.map((r) => r['id'] as int));

    _initialised = true;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  bool isFavourite(int id) => _cache.contains(id);

  Future<List<FavouriteLesson>> getAll() async {
    if (kIsWeb) return [];
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(_table, orderBy: 'id ASC');
    return rows.map(FavouriteLesson.fromMap).toList();
  }

  Future<void> toggle({
    required int id,
    required String title,
    required String duration,
    required String module,
  }) async {
    if (kIsWeb) return;
    if (isFavourite(id)) {
      await _remove(id);
    } else {
      await _add(FavouriteLesson(
          id: id, title: title, duration: duration, module: module));
    }
  }

  Future<void> _add(FavouriteLesson lesson) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _table,
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _cache.add(lesson.id);
  }

  Future<void> _remove(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    _cache.remove(id);
  }
}
