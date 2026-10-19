import '../data/event_repository.dart';
import '../models/event_model.dart';

/// Résultat d'une opération métier : succès ou erreur avec message.
class ServiceResult<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  const ServiceResult.success(this.data) : error = null;
  const ServiceResult.failure(this.error) : data = null;
}

/// Couche métier du module Événements.
/// Valide les données, applique les règles métier, puis délègue au [EventRepository].
class EventService {
  final EventRepository _repo = EventRepository();

  // -------------------------------------------------------------------------
  // Validation
  // -------------------------------------------------------------------------

  /// Valide les champs d'un événement et retourne un message d'erreur ou null.
  String? validate(EventModel event) {
    // Titre
    if (event.title.trim().isEmpty) return 'Le titre est obligatoire.';
    if (event.title.trim().length < 3) {
      return 'Le titre doit contenir au moins 3 caractères.';
    }

    // Description
    if (event.description.trim().isEmpty) {
      return 'La description est obligatoire.';
    }

    // Catégorie
    if (!EventModel.categories.contains(event.category)) {
      return 'Catégorie invalide.';
    }

    // Niveau
    if (!EventModel.levels.contains(event.level)) {
      return 'Niveau invalide.';
    }

    // Mode
    if (!['presentiel', 'enligne', 'hybride'].contains(event.mode)) {
      return 'Mode de participation invalide.';
    }

    // Dates — cohérence
    final start = DateTime.tryParse(event.startDate);
    final end = DateTime.tryParse(event.endDate);
    if (start == null) return 'Date de début invalide.';
    if (end == null) return 'Date de fin invalide.';
    if (!end.isAfter(start)) {
      return 'La date de fin doit être postérieure à la date de début.';
    }

    // Date limite d'inscription
    if (event.registrationDeadline != null) {
      final dl = DateTime.tryParse(event.registrationDeadline!);
      if (dl == null) return 'Date limite d\'inscription invalide.';
      if (!dl.isBefore(end)) {
        return 'La date limite d\'inscription doit être avant la fin de l\'événement.';
      }
    }

    // Capacité
    if (event.capacity <= 0) {
      return 'La capacité doit être un entier strictement positif.';
    }

    // Prix
    if (event.price < 0) return 'Le prix ne peut pas être négatif.';

    // Lieu obligatoire en mode présentiel
    if (event.mode == 'presentiel' &&
        (event.location == null || event.location!.trim().isEmpty)) {
      return 'Le lieu est obligatoire pour un événement présentiel.';
    }

    // Lien obligatoire en mode en ligne
    if (event.mode == 'enligne' &&
        (event.onlineLink == null || event.onlineLink!.trim().isEmpty)) {
      return 'Le lien est obligatoire pour un événement en ligne.';
    }

    // Email de contact — format basique
    if (event.contactEmail != null && event.contactEmail!.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(event.contactEmail!.trim())) {
        return 'L\'adresse e-mail de contact est invalide.';
      }
    }

    return null; // tout est valide
  }

  // -------------------------------------------------------------------------
  // CREATE
  // -------------------------------------------------------------------------

  Future<ServiceResult<int>> createEvent(EventModel event) async {
    final error = validate(event);
    if (error != null) return ServiceResult.failure(error);
    try {
      final id = await _repo.createEvent(event);
      return ServiceResult.success(id);
    } catch (e) {
      return ServiceResult.failure('Erreur lors de la création : $e');
    }
  }

  // -------------------------------------------------------------------------
  // READ
  // -------------------------------------------------------------------------

  Future<List<EventModel>> getAllEvents() => _repo.getAllEvents();

  Future<List<EventModel>> getPublishedEvents() => _repo.getPublishedEvents();

  Future<EventModel?> getEventById(int id) => _repo.getEventById(id);

  Future<List<EventModel>> getEventsByOrganizer(int organizerId) =>
      _repo.getEventsByOrganizer(organizerId);

  Future<List<EventModel>> filterEvents({
    String? type,
    String? category,
    String? level,
    String? mode,
    String? status,
    String? searchQuery,
  }) =>
      _repo.filterEvents(
        type: type,
        category: category,
        level: level,
        mode: mode,
        status: status,
        searchQuery: searchQuery,
      );

  // -------------------------------------------------------------------------
  // UPDATE
  // -------------------------------------------------------------------------

  Future<ServiceResult<void>> updateEvent(EventModel event) async {
    if (event.id == null) return ServiceResult.failure('ID manquant.');
    final error = validate(event);
    if (error != null) return ServiceResult.failure(error);
    try {
      await _repo.updateEvent(event);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur lors de la mise à jour : $e');
    }
  }

  /// Publie un événement (passe de 'draft' à 'published').
  /// NOTE v1 : aucune restriction de rôle — tout utilisateur connecté peut publier.
  /// TODO v2 : restreindre à requesterId == organizerId quand les rôles seront gérés.
  Future<ServiceResult<void>> publishEvent(
      int id, int requesterId, int organizerId) async {
    try {
      await _repo.updateEventStatus(id, 'published');
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur : $e');
    }
  }

  /// Annule un événement.
  Future<ServiceResult<void>> cancelEvent(
      int id, int requesterId, int organizerId) async {
    try {
      await _repo.updateEventStatus(id, 'cancelled');
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur : $e');
    }
  }

  // -------------------------------------------------------------------------
  // DELETE
  // -------------------------------------------------------------------------

  /// Supprime un événement.
  /// NOTE v1 : aucune restriction de rôle — tout utilisateur connecté peut supprimer.
  /// TODO v2 : restreindre à requesterId == organizerId quand les rôles seront gérés.
  Future<ServiceResult<void>> deleteEvent(
      int id, int requesterId, int organizerId) async {
    try {
      await _repo.deleteEvent(id);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur lors de la suppression : $e');
    }
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  Future<int> getAvailableSpots(EventModel event) async {
    final taken = await _repo.getConfirmedRegistrationsCount(event.id!);
    return (event.capacity - taken).clamp(0, event.capacity);
  }
}
