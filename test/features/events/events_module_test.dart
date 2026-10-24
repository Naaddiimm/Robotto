import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:robotto/features/events/models/event_registration.dart';
import 'package:robotto/features/events/services/checkin_service.dart';

// ---------------------------------------------------------------------------
// Configuration SQLite FFI pour les tests (desktop/CI)
// ---------------------------------------------------------------------------
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // ── Modèle EventRegistration ─────────────────────────────────────────────

  group('EventRegistration — modèle', () {
    test('isCheckedIn retourne false si checkedInAt est null', () {
      final reg = EventRegistration(
        id: 1,
        eventId: 1,
        userId: 1,
        status: 'confirmed',
        registeredAt: DateTime.now().toIso8601String(),
        ticketCode: 'EVT-1-1-1234',
      );
      expect(reg.isCheckedIn, isFalse);
    });

    test('isCheckedIn retourne true si checkedInAt est défini', () {
      final reg = EventRegistration(
        id: 1,
        eventId: 1,
        userId: 1,
        status: 'confirmed',
        registeredAt: DateTime.now().toIso8601String(),
        checkedInAt: DateTime.now().toIso8601String(),
        ticketCode: 'EVT-1-1-1234',
      );
      expect(reg.isCheckedIn, isTrue);
    });

    test('fromMap / toMap roundtrip préserve checkedInAt', () {
      final now = DateTime.now().toIso8601String();
      final map = {
        'id': 5,
        'event_id': 2,
        'user_id': 3,
        'status': 'confirmed',
        'team_id': null,
        'registered_at': now,
        'cancelled_at': null,
        'checked_in_at': now,
        'ticket_code': 'EVT-2-3-9999',
        'title': null,
        'type': null,
        'start_date': null,
      };
      final reg = EventRegistration.fromMap(map);
      expect(reg.checkedInAt, equals(now));
      expect(reg.toMap()['checked_in_at'], equals(now));
    });

    test('fromMap accepte checked_in_at null (ancien enregistrement)', () {
      final now = DateTime.now().toIso8601String();
      final map = {
        'id': 1,
        'event_id': 1,
        'user_id': 1,
        'status': 'confirmed',
        'team_id': null,
        'registered_at': now,
        'cancelled_at': null,
        'checked_in_at': null,
        'ticket_code': 'EVT-1-1-0001',
        'title': null,
        'type': null,
        'start_date': null,
      };
      final reg = EventRegistration.fromMap(map);
      expect(reg.isCheckedIn, isFalse);
      expect(reg.checkedInAt, isNull);
    });
  });

  // ── Validation lien Google Meet ──────────────────────────────────────────

  group('Google Meet — validation du lien', () {
    // Même logique que dans event_detail_screen.dart / competition_detail_screen.dart
    String normalizeLink(String link) {
      final t = link.trim();
      if (!t.startsWith('http://') && !t.startsWith('https://')) {
        return 'https://$t';
      }
      return t;
    }

    bool isMeetLink(String? link) {
      if (link == null || link.trim().isEmpty) return false;
      final uri = Uri.tryParse(normalizeLink(link));
      if (uri == null || uri.scheme != 'https') return false;
      final host = uri.host.toLowerCase();
      return host == 'meet.google.com' || host.endsWith('.meet.google.com');
    }

    bool isValidHttpsLink(String? link) {
      if (link == null || link.trim().isEmpty) return false;
      final uri = Uri.tryParse(normalizeLink(link));
      return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
    }

    test('lien Meet complet valide', () {
      expect(isMeetLink('https://meet.google.com/abc-defg-hij'), isTrue);
    });

    test('normalisation : lien sans https:// accepté', () {
      expect(isMeetLink('meet.google.com/abc-defg-hij'), isTrue);
    });

    test('lien Meet avec sous-domaine valide', () {
      expect(isMeetLink('https://g.meet.google.com/abc'), isTrue);
    });

    test('domaine trompeur rejeté (evil.com/meet.google.com)', () {
      expect(isMeetLink('https://evil.com/meet.google.com'), isFalse);
    });

    test('domaine trompeur rejeté (meetXgoogle.com)', () {
      expect(isMeetLink('https://meetXgoogle.com/abc'), isFalse);
    });

    test('lien http non sécurisé rejeté', () {
      expect(isMeetLink('http://meet.google.com/abc'), isFalse);
    });

    test('lien Zoom non reconnu comme Meet', () {
      expect(isMeetLink('https://zoom.us/j/123'), isFalse);
    });

    test('null rejeté', () {
      expect(isMeetLink(null), isFalse);
    });

    test('chaîne vide rejetée', () {
      expect(isMeetLink(''), isFalse);
    });

    test('URL malformée rejetée', () {
      expect(isMeetLink('pas une url'), isFalse);
    });

    test('fallback https valide pour Zoom', () {
      expect(isValidHttpsLink('https://zoom.us/j/123'), isTrue);
    });

    test('fallback http invalide', () {
      expect(isValidHttpsLink('http://zoom.us/j/123'), isFalse);
    });

    test('fallback lien vide invalide', () {
      expect(isValidHttpsLink(''), isFalse);
    });
  });

  // ── CheckInResult — logique métier ───────────────────────────────────────

  group('CheckInResult — états et messages', () {
    EventRegistration makeReg({
      String status = 'confirmed',
      String? checkedInAt,
      int eventId = 1,
    }) =>
        EventRegistration(
          id: 1,
          eventId: eventId,
          userId: 1,
          status: status,
          registeredAt: DateTime.now().toIso8601String(),
          checkedInAt: checkedInAt,
          ticketCode: 'EVT-1-1-0001',
        );

    test('invalidTicket — billet inexistant', () {
      const result = CheckInResult(status: CheckInStatus.invalidTicket);
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('introuvable'));
    });

    test('notConfirmed — inscription annulée', () {
      final result = CheckInResult(
        status: CheckInStatus.notConfirmed,
        registration: makeReg(status: 'cancelled'),
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('non confirmée'));
    });

    test('alreadyCheckedIn — billet déjà utilisé', () {
      final result = CheckInResult(
        status: CheckInStatus.alreadyCheckedIn,
        registration: makeReg(checkedInAt: DateTime.now().toIso8601String()),
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('déjà'));
    });

    test('wrongEvent — billet d\'un autre événement', () {
      final result = CheckInResult(
        status: CheckInStatus.wrongEvent,
        registration: makeReg(eventId: 99),
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('ne correspond pas'));
    });

    test('success — présence validée', () {
      final result = CheckInResult(
        status: CheckInStatus.success,
        registration: makeReg(checkedInAt: DateTime.now().toIso8601String()),
      );
      expect(result.isSuccess, isTrue);
      expect(result.message, contains('validée'));
    });
  });

  // ── Migration SQLite — vérification schéma ────────────────────────────────

  group('Migration SQLite v2 → v3', () {
    Future<Database> makeV2Db() async {
      return openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE event_registrations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event_id INTEGER NOT NULL,
              user_id INTEGER NOT NULL,
              status TEXT NOT NULL DEFAULT 'confirmed',
              ticket_code TEXT,
              registered_at TEXT NOT NULL,
              cancelled_at TEXT
            )
          ''');
          // Insérer un enregistrement existant
          await db.insert('event_registrations', {
            'event_id': 1,
            'user_id': 1,
            'status': 'confirmed',
            'ticket_code': 'EVT-1-1-0001',
            'registered_at': DateTime.now().toIso8601String(),
          });
        },
      );
    }

    test('base v2 ne contient pas checked_in_at', () async {
      final db = await makeV2Db();
      final cols =
          await db.rawQuery('PRAGMA table_info(event_registrations)');
      final names = cols.map((c) => c['name'] as String).toList();
      expect(names.contains('checked_in_at'), isFalse);
      await db.close();
    });

    test('migration v2→v3 : ALTER TABLE ajoute checked_in_at sans supprimer les données', () async {
      final db = await makeV2Db();
      // Appliquer la migration
      await db.execute(
          'ALTER TABLE event_registrations ADD COLUMN checked_in_at TEXT');
      // Vérifier la colonne ajoutée
      final cols =
          await db.rawQuery('PRAGMA table_info(event_registrations)');
      final names = cols.map((c) => c['name'] as String).toList();
      expect(names.contains('checked_in_at'), isTrue);
      // Vérifier que l'enregistrement existant est préservé
      final rows = await db.query('event_registrations');
      expect(rows.length, equals(1));
      expect(rows.first['ticket_code'], equals('EVT-1-1-0001'));
      expect(rows.first['checked_in_at'], isNull);
      await db.close();
    });

    test('base v3 fraîche contient checked_in_at dès la création', () async {
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 3,
        onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE event_registrations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event_id INTEGER NOT NULL,
              user_id INTEGER NOT NULL,
              status TEXT NOT NULL DEFAULT 'confirmed',
              ticket_code TEXT,
              registered_at TEXT NOT NULL,
              cancelled_at TEXT,
              checked_in_at TEXT
            )
          ''');
        },
      );
      final cols =
          await db.rawQuery('PRAGMA table_info(event_registrations)');
      final names = cols.map((c) => c['name'] as String).toList();
      expect(names.contains('checked_in_at'), isTrue);
      await db.close();
    });

    test('validation atomique : UPDATE conditionnel bloque la double validation', () async {
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 3,
        onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE event_registrations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event_id INTEGER NOT NULL,
              user_id INTEGER NOT NULL,
              status TEXT NOT NULL DEFAULT 'confirmed',
              ticket_code TEXT,
              registered_at TEXT NOT NULL,
              cancelled_at TEXT,
              checked_in_at TEXT
            )
          ''');
          await db.insert('event_registrations', {
            'event_id': 1,
            'user_id': 1,
            'status': 'confirmed',
            'ticket_code': 'EVT-1-1-0001',
            'registered_at': DateTime.now().toIso8601String(),
          });
        },
      );
      final now = DateTime.now().toIso8601String();

      // Premier check-in → réussit (1 ligne affectée)
      final rows1 = await db.rawUpdate(
        'UPDATE event_registrations SET checked_in_at = ? WHERE id = 1 AND checked_in_at IS NULL',
        [now],
      );
      expect(rows1, equals(1));

      // Deuxième check-in → bloqué (0 ligne affectée)
      final rows2 = await db.rawUpdate(
        'UPDATE event_registrations SET checked_in_at = ? WHERE id = 1 AND checked_in_at IS NULL',
        [now],
      );
      expect(rows2, equals(0));

      await db.close();
    });
  });
}
