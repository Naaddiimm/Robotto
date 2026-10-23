import '../data/registration_repository.dart';
import '../data/event_repository.dart';
import '../models/event_registration.dart';
import '../models/event_model.dart';
import 'event_service.dart';

/// Service métier pour les inscriptions aux événements et compétitions.
class RegistrationService {
  final RegistrationRepository _repo = RegistrationRepository();
  final EventRepository _eventRepo = EventRepository();

  // -------------------------------------------------------------------------
  // S'inscrire
  // -------------------------------------------------------------------------

  Future<ServiceResult<int>> register({
    required int eventId,
    required int userId,
    int? teamId,
  }) async {
    // 1. Vérifier que l'événement existe et est publié
    final event = await _eventRepo.getEventById(eventId);
    if (event == null) return ServiceResult.failure('Événement introuvable.');
    if (event.status == 'cancelled') {
      return ServiceResult.failure('Cet événement est annulé.');
    }

    // 2. Vérifier inscription existante
    final existing = await _repo.getRegistration(eventId, userId);
    if (existing != null && existing.status == 'confirmed') {
      return ServiceResult.failure('Vous êtes déjà inscrit à cet événement.');
    }

    // 3. Vérifier capacité
    final taken = await _repo.getConfirmedCount(eventId);
    if (taken >= event.capacity) {
      return ServiceResult.failure(
          'Cet événement est complet (${event.capacity} places).');
    }

    // 4. Si annulation précédente, réinscrire
    if (existing != null && existing.status == 'cancelled') {
      await _repo.updateStatus(existing.id!, 'confirmed');
      return ServiceResult.success(existing.id!);
    }

    try {
      final id = await _repo.register(
          eventId: eventId, userId: userId, teamId: teamId);
      return ServiceResult.success(id);
    } catch (e) {
      return ServiceResult.failure('Erreur inscription : $e');
    }
  }

  // -------------------------------------------------------------------------
  // READ
  // -------------------------------------------------------------------------

  Future<List<EventRegistration>> getMyRegistrations(int userId) =>
      _repo.getUserRegistrations(userId);

  Future<List<EventRegistration>> getParticipants(int eventId) =>
      _repo.getEventParticipants(eventId);

  Future<EventRegistration?> getMyRegistration(
          int eventId, int userId) =>
      _repo.getRegistration(eventId, userId);

  Future<int> getAvailableSpots(EventModel event) async {
    final taken = await _repo.getConfirmedCount(event.id!);
    return (event.capacity - taken).clamp(0, event.capacity);
  }

  // -------------------------------------------------------------------------
  // Annuler
  // -------------------------------------------------------------------------

  Future<ServiceResult<void>> cancel({
    required int eventId,
    required int userId,
  }) async {
    final reg = await _repo.getRegistration(eventId, userId);
    if (reg == null || reg.status != 'confirmed') {
      return ServiceResult.failure('Aucune inscription active trouvée.');
    }
    try {
      await _repo.cancel(eventId, userId);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur annulation : $e');
    }
  }
}
