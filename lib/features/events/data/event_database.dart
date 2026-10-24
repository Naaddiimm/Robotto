import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton SQLite pour le module Événements et Compétitions.
///
/// Ouvre sa propre base [robotto_event.db], totalement indépendante
/// de robotto.db (utilisateurs) et robotto_shop.db (shop).
/// Politique de migration non-destructive : ALTER TABLE / CREATE TABLE IF NOT EXISTS uniquement.
class EventDatabase {
  static final EventDatabase instance = EventDatabase._init();
  static Database? _database;

  EventDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('robotto_event.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onConfigure: _configureDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _configureDB(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        organizer_id      INTEGER NOT NULL,
        title             TEXT    NOT NULL,
        description       TEXT    NOT NULL,
        type              TEXT    NOT NULL CHECK(type IN ('event','competition')),
        category          TEXT    NOT NULL,
        level             TEXT    NOT NULL CHECK(level IN ('debutant','intermediaire','avance','tous')),
        mode              TEXT    NOT NULL CHECK(mode IN ('presentiel','enligne','hybride')),
        status            TEXT    NOT NULL DEFAULT 'draft'
                            CHECK(status IN ('draft','published','cancelled','completed')),
        location          TEXT,
        address           TEXT,
        online_link       TEXT,
        start_date        TEXT    NOT NULL,
        end_date          TEXT    NOT NULL,
        registration_deadline TEXT,
        capacity          INTEGER NOT NULL CHECK(capacity > 0),
        price             REAL    NOT NULL DEFAULT 0 CHECK(price >= 0),
        cover_image_path  TEXT,
        program           TEXT,
        rules             TEXT,
        contact_email     TEXT,
        contact_phone     TEXT,
        created_at        TEXT    NOT NULL,
        updated_at        TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE competitions (
        id                  INTEGER PRIMARY KEY,
        participation_type  TEXT NOT NULL CHECK(participation_type IN ('individual','team','both')),
        team_min_size       INTEGER,
        team_max_size       INTEGER,
        robot_category      TEXT,
        prize_description   TEXT,
        results_published   INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (id) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE event_registrations (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id      INTEGER NOT NULL,
        user_id       INTEGER NOT NULL,
        status        TEXT    NOT NULL DEFAULT 'confirmed'
                        CHECK(status IN ('confirmed','cancelled','waitlisted')),
        team_id       INTEGER,
        ticket_code   TEXT,
        registered_at TEXT NOT NULL,
        cancelled_at  TEXT,
        checked_in_at TEXT,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE,
        UNIQUE(event_id, user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE event_teams (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id    INTEGER NOT NULL,
        name        TEXT    NOT NULL,
        leader_id   INTEGER NOT NULL,
        created_at  TEXT    NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE,
        UNIQUE(event_id, name)
      )
    ''');

    await db.execute('''
      CREATE TABLE event_team_members (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        team_id   INTEGER NOT NULL,
        user_id   INTEGER NOT NULL,
        role      TEXT    NOT NULL DEFAULT 'member'
                    CHECK(role IN ('leader','member')),
        joined_at TEXT    NOT NULL,
        FOREIGN KEY (team_id) REFERENCES event_teams (id) ON DELETE CASCADE,
        UNIQUE(team_id, user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE competition_results (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id    INTEGER NOT NULL,
        rank        INTEGER NOT NULL,
        participant TEXT    NOT NULL,
        score       REAL,
        notes       TEXT,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE event_announcements (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id    INTEGER,
        author_id   INTEGER NOT NULL,
        title       TEXT    NOT NULL,
        content     TEXT    NOT NULL,
        type        TEXT    NOT NULL DEFAULT 'announcement'
                      CHECK(type IN ('announcement','news')),
        is_pinned   INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL,
        updated_at  TEXT    NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');

    // Index
    await db.execute('CREATE INDEX idx_events_organizer   ON events (organizer_id)');
    await db.execute('CREATE INDEX idx_events_type        ON events (type)');
    await db.execute('CREATE INDEX idx_events_status      ON events (status)');
    await db.execute('CREATE INDEX idx_events_start_date  ON events (start_date)');
    await db.execute('CREATE INDEX idx_registrations_user  ON event_registrations (user_id)');
    await db.execute('CREATE INDEX idx_registrations_event ON event_registrations (event_id)');
    await db.execute('CREATE INDEX idx_announcements_event ON event_announcements (event_id)');
  }

  /// Migration non-destructive depuis v1 → v2 → v3
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter ticket_code à event_registrations si absent
      try {
        await db.execute(
            'ALTER TABLE event_registrations ADD COLUMN ticket_code TEXT');
      } catch (_) {} // colonne déjà présente

      // Créer event_announcements si absent
      await db.execute('''
        CREATE TABLE IF NOT EXISTS event_announcements (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          event_id    INTEGER,
          author_id   INTEGER NOT NULL,
          title       TEXT    NOT NULL,
          content     TEXT    NOT NULL,
          type        TEXT    NOT NULL DEFAULT 'announcement'
                        CHECK(type IN ('announcement','news')),
          is_pinned   INTEGER NOT NULL DEFAULT 0,
          created_at  TEXT    NOT NULL,
          updated_at  TEXT    NOT NULL,
          FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_announcements_event ON event_announcements (event_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_events_start_date ON events (start_date)',
      );
    }
    if (oldVersion < 3) {
      // Ajouter checked_in_at pour la validation de présence par QR code
      try {
        await db.execute(
            'ALTER TABLE event_registrations ADD COLUMN checked_in_at TEXT');
      } catch (_) {} // colonne déjà présente
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
