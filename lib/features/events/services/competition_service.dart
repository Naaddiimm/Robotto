import '../data/competition_repository.dart';
import '../data/event_repository.dart';
import '../models/competition_detail.dart';
import '../models/competition_result.dart';
import '../models/event_model.dart';
import 'event_service.dart';

/// Service métier pour les compétitions.
/// Une compétition = EventModel (type='competition') + CompetitionDetail (1-to-1).
class CompetitionService {
  final EventService _eventService = EventService();
  final EventRepository _eventRepo = EventRepository();
  final CompetitionRepository _compRepo = CompetitionRepository();

  // -------------------------------------------------------------------------
  // Validation spécifique aux compétitions
  // -------------------------------------------------------------------------

  String? validateDetail(CompetitionDetail detail) {
    if (!CompetitionDetail.participationTypes.contains(detail.participationType)) {
      return 'Type de participation invalide.';
    }
    if (detail.participationType != 'individual') {
      if (detail.teamMinSize != null && detail.teamMinSize! < 1) {
        return 'La taille minimale d\'équipe doit être ≥ 1.';
      }
      if (detail.teamMaxSize != null && detail.teamMinSize != null) {
        if (detail.teamMaxSize! < detail.teamMinSize!) {
          return 'La taille maximale doit être ≥ à la taille minimale.';
        }
      }
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // CREATE
  // -------------------------------------------------------------------------

  /// Crée un événement de type 'competition' + ses détails en transaction.
  Future<ServiceResult<int>> createCompetition(
      EventModel event, CompetitionDetail detail) async {
    // L'événement doit être de type competition
    final eventToCreate = event.copyWith(type: 'competition');
    final eventError = _eventService.validate(eventToCreate);
    if (eventError != null) return ServiceResult.failure(eventError);
    final detailError = validateDetail(detail);
    if (detailError != null) return ServiceResult.failure(detailError);

    try {
      final id = await _eventRepo.createEvent(eventToCreate);
      await _compRepo.upsertDetail(detail.copyWith(eventId: id));
      return ServiceResult.success(id);
    } catch (e) {
      return ServiceResult.failure('Erreur création compétition : $e');
    }
  }

  // -------------------------------------------------------------------------
  // READ
  // -------------------------------------------------------------------------

  Future<List<EventModel>> getAllCompetitions() =>
      _compRepo.getAllCompetitions();

  Future<List<EventModel>> getPublishedCompetitions() =>
      _compRepo.getPublishedCompetitions();

  Future<EventModel?> getById(int id) => _eventRepo.getEventById(id);

  Future<CompetitionDetail?> getDetail(int eventId) =>
      _compRepo.getDetail(eventId);

  // -------------------------------------------------------------------------
  // UPDATE
  // -------------------------------------------------------------------------

  Future<ServiceResult<void>> updateCompetition(
      EventModel event, CompetitionDetail detail) async {
    if (event.id == null) return ServiceResult.failure('ID manquant.');
    final eventToUpdate = event.copyWith(type: 'competition');
    final eventError = _eventService.validate(eventToUpdate);
    if (eventError != null) return ServiceResult.failure(eventError);
    final detailError = validateDetail(detail);
    if (detailError != null) return ServiceResult.failure(detailError);

    try {
      await _eventRepo.updateEvent(eventToUpdate);
      await _compRepo.upsertDetail(detail.copyWith(eventId: event.id));
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur mise à jour : $e');
    }
  }

  // -------------------------------------------------------------------------
  // DELETE
  // -------------------------------------------------------------------------

  Future<ServiceResult<void>> deleteCompetition(int id) async {
    try {
      await _eventRepo.deleteEvent(id); // cascade sur competitions
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur suppression : $e');
    }
  }

  // -------------------------------------------------------------------------
  // Results
  // -------------------------------------------------------------------------

  Future<List<CompetitionResult>> getResults(int eventId) =>
      _compRepo.getResults(eventId);

  Future<ServiceResult<int>> addResult(CompetitionResult result) async {
    if (result.rank < 1) return ServiceResult.failure('Le rang doit être ≥ 1.');
    if (result.participant.trim().isEmpty) {
      return ServiceResult.failure('Le nom du participant est obligatoire.');
    }
    try {
      final id = await _compRepo.addResult(result);
      return ServiceResult.success(id);
    } catch (e) {
      return ServiceResult.failure('Erreur ajout résultat : $e');
    }
  }

  Future<ServiceResult<void>> updateResult(CompetitionResult result) async {
    if (result.id == null) return ServiceResult.failure('ID manquant.');
    try {
      await _compRepo.updateResult(result);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur mise à jour résultat : $e');
    }
  }

  Future<ServiceResult<void>> deleteResult(int id) async {
    try {
      await _compRepo.deleteResult(id);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur suppression résultat : $e');
    }
  }
}
