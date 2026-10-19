// Tests unitaires des règles de validation du module Événements.
//
// Ces tests couvrent EventService.validate() sans aucune dépendance SQLite
// ni widget — pure logique Dart, même approche que test/shop/product_validators_test.dart.

import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/event/services/event_service.dart';
import 'package:robotto/event/models/event_model.dart';

// ---------------------------------------------------------------------------
// Helper : construit un EventModel valide que les tests peuvent modifier
// champ par champ pour tester les cas invalides.
// ---------------------------------------------------------------------------
EventModel _base({
  String title          = 'Robotics Workshop 2026',
  String description    = 'Un atelier complet sur la robotique mobile.',
  String type           = 'event',
  String category       = 'Workshop',
  String level          = 'tous',
  String mode           = 'presentiel',
  String status         = 'draft',
  String startDate      = '2026-11-01T09:00:00.000',
  String endDate        = '2026-11-02T18:00:00.000',
  String? regDeadline,
  int    capacity       = 50,
  double price          = 0,
  String? location      = 'ESI Alger',
  String? onlineLink,
  String? contactEmail,
  String? contactPhone,
}) {
  final now = DateTime.now().toIso8601String();
  return EventModel(
    organizerId:          1,
    title:                title,
    description:          description,
    type:                 type,
    category:             category,
    level:                level,
    mode:                 mode,
    status:               status,
    startDate:            startDate,
    endDate:              endDate,
    registrationDeadline: regDeadline,
    capacity:             capacity,
    price:                price,
    location:             location,
    onlineLink:           onlineLink,
    contactEmail:         contactEmail,
    contactPhone:         contactPhone,
    createdAt:            now,
    updatedAt:            now,
  );
}

void main() {
  final service = EventService();

  // =========================================================================
  // Cas valide de référence
  // =========================================================================
  group('EventService.validate — cas valide de référence', () {
    test('retourne null pour un événement présentiel complet et valide', () {
      expect(service.validate(_base()), isNull);
    });

    test('retourne null pour une compétition en ligne valide', () {
      final e = _base(
        type:       'competition',
        mode:       'enligne',
        location:   null,
        onlineLink: 'https://meet.example.com/robotto',
      );
      expect(service.validate(e), isNull);
    });

    test('retourne null pour un événement hybride sans lieu ni lien obligatoire', () {
      final e = _base(mode: 'hybride', location: null, onlineLink: null);
      expect(service.validate(e), isNull);
    });
  });

  // =========================================================================
  // Titre
  // =========================================================================
  group('EventService.validate — titre', () {
    test('erreur si titre vide', () {
      expect(service.validate(_base(title: '')), isNotNull);
    });

    test('erreur si titre uniquement des espaces', () {
      expect(service.validate(_base(title: '   ')), isNotNull);
    });

    test('erreur si titre trop court (< 3 caractères)', () {
      expect(service.validate(_base(title: 'AB')), isNotNull);
    });

    test('null à exactement 3 caractères', () {
      expect(service.validate(_base(title: 'ABC')), isNull);
    });

    test('null pour un titre long valide', () {
      expect(service.validate(_base(title: 'A' * 80)), isNull);
    });
  });

  // =========================================================================
  // Description
  // =========================================================================
  group('EventService.validate — description', () {
    test('erreur si description vide', () {
      expect(service.validate(_base(description: '')), isNotNull);
    });

    test('erreur si description uniquement des espaces', () {
      expect(service.validate(_base(description: '     ')), isNotNull);
    });

    test('null pour une description valide', () {
      expect(service.validate(_base(description: 'Description valide de cet événement.')), isNull);
    });
  });

  // =========================================================================
  // Catégorie
  // =========================================================================
  group('EventService.validate — catégorie', () {
    test('null pour chaque catégorie autorisée', () {
      for (final cat in EventModel.categories) {
        expect(service.validate(_base(category: cat)), isNull,
            reason: 'catégorie "$cat" devrait être valide');
      }
    });

    test('erreur pour une catégorie non reconnue', () {
      expect(service.validate(_base(category: 'Inconnu')), isNotNull);
    });

    test('erreur pour une catégorie vide', () {
      expect(service.validate(_base(category: '')), isNotNull);
    });

    test('erreur pour une catégorie avec casse différente (sensible à la casse)', () {
      expect(service.validate(_base(category: 'workshop')), isNotNull);
    });
  });

  // =========================================================================
  // Niveau
  // =========================================================================
  group('EventService.validate — niveau', () {
    test('null pour chaque niveau autorisé', () {
      for (final level in EventModel.levels) {
        expect(service.validate(_base(level: level)), isNull,
            reason: 'niveau "$level" devrait être valide');
      }
    });

    test('erreur pour un niveau inconnu', () {
      expect(service.validate(_base(level: 'expert')), isNotNull);
    });

    test('erreur pour un niveau vide', () {
      expect(service.validate(_base(level: '')), isNotNull);
    });
  });

  // =========================================================================
  // Mode de participation
  // =========================================================================
  group('EventService.validate — mode', () {
    test('null pour presentiel', () {
      expect(service.validate(_base(mode: 'presentiel', location: 'ESI')), isNull);
    });

    test('null pour enligne', () {
      expect(service.validate(_base(
        mode: 'enligne',
        location: null,
        onlineLink: 'https://zoom.us/j/123',
      )), isNull);
    });

    test('null pour hybride', () {
      expect(service.validate(_base(mode: 'hybride')), isNull);
    });

    test('erreur pour un mode invalide', () {
      expect(service.validate(_base(mode: 'virtuel')), isNotNull);
    });
  });

  // =========================================================================
  // Dates
  // =========================================================================
  group('EventService.validate — dates', () {
    test('erreur si date de début invalide (non ISO)', () {
      expect(service.validate(_base(startDate: '01/11/2026')), isNotNull);
    });

    test('erreur si date de fin invalide (non ISO)', () {
      expect(service.validate(_base(endDate: 'demain')), isNotNull);
    });

    test('erreur si date de fin égale à la date de début', () {
      expect(service.validate(_base(
        startDate: '2026-11-01T09:00:00.000',
        endDate:   '2026-11-01T09:00:00.000',
      )), isNotNull);
    });

    test('erreur si date de fin avant la date de début', () {
      expect(service.validate(_base(
        startDate: '2026-11-02T09:00:00.000',
        endDate:   '2026-11-01T18:00:00.000',
      )), isNotNull);
    });

    test('null si date de fin est un jour après la date de début', () {
      expect(service.validate(_base(
        startDate: '2026-11-01T09:00:00.000',
        endDate:   '2026-11-02T09:00:01.000',
      )), isNull);
    });

    test('null si même jour mais heure de fin après heure de début', () {
      expect(service.validate(_base(
        startDate: '2026-11-01T09:00:00.000',
        endDate:   '2026-11-01T18:00:00.000',
      )), isNull);
    });

    test('erreur si deadline d\'inscription est invalide (non ISO)', () {
      expect(service.validate(_base(regDeadline: 'pas-une-date')), isNotNull);
    });

    test('erreur si deadline d\'inscription est après la date de fin', () {
      expect(service.validate(_base(
        startDate:   '2026-11-01T09:00:00.000',
        endDate:     '2026-11-02T18:00:00.000',
        regDeadline: '2026-11-03T00:00:00.000', // après la fin
      )), isNotNull);
    });

    test('null si deadline d\'inscription est avant la date de fin', () {
      expect(service.validate(_base(
        startDate:   '2026-11-01T09:00:00.000',
        endDate:     '2026-11-02T18:00:00.000',
        regDeadline: '2026-11-01T23:59:00.000',
      )), isNull);
    });
  });

  // =========================================================================
  // Capacité
  // =========================================================================
  group('EventService.validate — capacité', () {
    test('erreur si capacité est 0', () {
      expect(service.validate(_base(capacity: 0)), isNotNull);
    });

    test('erreur si capacité est négative', () {
      expect(service.validate(_base(capacity: -1)), isNotNull);
    });

    test('null pour capacité = 1 (minimum valide)', () {
      expect(service.validate(_base(capacity: 1)), isNull);
    });

    test('null pour une grande capacité', () {
      expect(service.validate(_base(capacity: 10000)), isNull);
    });
  });

  // =========================================================================
  // Prix
  // =========================================================================
  group('EventService.validate — prix', () {
    test('null pour prix = 0 (gratuit)', () {
      expect(service.validate(_base(price: 0)), isNull);
    });

    test('null pour prix positif', () {
      expect(service.validate(_base(price: 1500.0)), isNull);
    });

    test('erreur si prix négatif', () {
      expect(service.validate(_base(price: -1)), isNotNull);
    });

    test('null pour prix très grand', () {
      expect(service.validate(_base(price: 999999.0)), isNull);
    });
  });

  // =========================================================================
  // Lieu (mode présentiel)
  // =========================================================================
  group('EventService.validate — lieu obligatoire en présentiel', () {
    test('erreur si lieu null en mode présentiel', () {
      expect(service.validate(_base(mode: 'presentiel', location: null)), isNotNull);
    });

    test('erreur si lieu vide en mode présentiel', () {
      expect(service.validate(_base(mode: 'presentiel', location: '')), isNotNull);
    });

    test('erreur si lieu uniquement des espaces en mode présentiel', () {
      expect(service.validate(_base(mode: 'presentiel', location: '   ')), isNotNull);
    });

    test('null si lieu renseigné en mode présentiel', () {
      expect(service.validate(_base(mode: 'presentiel', location: 'Campus USTHB')), isNull);
    });

    test('null si lieu null en mode en ligne (non obligatoire)', () {
      expect(service.validate(_base(
        mode: 'enligne',
        location: null,
        onlineLink: 'https://example.com/meet',
      )), isNull);
    });

    test('null si lieu null en mode hybride (non obligatoire)', () {
      expect(service.validate(_base(mode: 'hybride', location: null)), isNull);
    });
  });

  // =========================================================================
  // Lien en ligne (mode enligne)
  // =========================================================================
  group('EventService.validate — lien obligatoire en ligne', () {
    test('erreur si lien null en mode enligne', () {
      expect(service.validate(_base(
        mode: 'enligne', location: null, onlineLink: null,
      )), isNotNull);
    });

    test('erreur si lien vide en mode enligne', () {
      expect(service.validate(_base(
        mode: 'enligne', location: null, onlineLink: '',
      )), isNotNull);
    });

    test('null si lien renseigné en mode enligne', () {
      expect(service.validate(_base(
        mode: 'enligne',
        location: null,
        onlineLink: 'https://meet.google.com/abc',
      )), isNull);
    });

    test('null si lien null en mode présentiel (non obligatoire)', () {
      expect(service.validate(_base(
        mode: 'presentiel', location: 'ESI', onlineLink: null,
      )), isNull);
    });
  });

  // =========================================================================
  // Email de contact
  // =========================================================================
  group('EventService.validate — email de contact', () {
    test('null si email null (champ optionnel)', () {
      expect(service.validate(_base(contactEmail: null)), isNull);
    });

    test('null si email vide (champ optionnel)', () {
      expect(service.validate(_base(contactEmail: '')), isNull);
    });

    test('null pour un email valide', () {
      expect(service.validate(_base(contactEmail: 'contact@robotto.dz')), isNull);
    });

    test('null pour un email avec sous-domaine', () {
      expect(service.validate(_base(contactEmail: 'events@club.usthb.dz')), isNull);
    });

    test('erreur si email sans @', () {
      expect(service.validate(_base(contactEmail: 'contactrobotto.dz')), isNotNull);
    });

    test('erreur si email sans domaine', () {
      expect(service.validate(_base(contactEmail: 'contact@')), isNotNull);
    });

    test('erreur si email sans extension', () {
      expect(service.validate(_base(contactEmail: 'contact@robotto')), isNotNull);
    });

    test('erreur pour un format clairement invalide', () {
      expect(service.validate(_base(contactEmail: 'pas-un-email')), isNotNull);
    });
  });
}
