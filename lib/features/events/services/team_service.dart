import '../data/team_repository.dart';
import '../models/event_team.dart';
import 'event_service.dart';

/// Service métier pour les équipes.
class TeamService {
  final TeamRepository _repo = TeamRepository();

  String? validateTeamName(String name) {
    if (name.trim().isEmpty) return 'Le nom de l\'équipe est obligatoire.';
    if (name.trim().length < 2) return 'Minimum 2 caractères.';
    if (name.trim().length > 50) return 'Maximum 50 caractères.';
    return null;
  }

  Future<ServiceResult<int>> createTeam({
    required int eventId,
    required String name,
    required int leaderId,
  }) async {
    final err = validateTeamName(name);
    if (err != null) return ServiceResult.failure(err);
    try {
      final team = EventTeam(
        eventId: eventId,
        name: name.trim(),
        leaderId: leaderId,
        createdAt: DateTime.now().toIso8601String(),
      );
      final id = await _repo.createTeam(team);
      return ServiceResult.success(id);
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        return ServiceResult.failure(
          'Une équipe avec ce nom existe déjà pour cette compétition.',
        );
      }
      return ServiceResult.failure('Erreur création équipe : $e');
    }
  }

  Future<List<EventTeam>> getTeams(int eventId) =>
      _repo.getTeamsForEvent(eventId);

  Future<EventTeam?> getTeam(int id) => _repo.getTeamById(id);

  Future<List<EventTeamMember>> getMembers(int teamId) =>
      _repo.getMembers(teamId);

  Future<ServiceResult<void>> renameTeam(int id, String newName) async {
    final err = validateTeamName(newName);
    if (err != null) return ServiceResult.failure(err);
    try {
      await _repo.updateTeamName(id, newName.trim());
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur renommage : $e');
    }
  }

  Future<ServiceResult<void>> deleteTeam(int id) async {
    try {
      await _repo.deleteTeam(id);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur suppression : $e');
    }
  }

  Future<ServiceResult<void>> addMember(int teamId, int userId) async {
    final already = await _repo.isMember(teamId, userId);
    if (already)
      return ServiceResult.failure('Cet utilisateur est déjà membre.');
    try {
      await _repo.addMember(teamId, userId);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur ajout membre : $e');
    }
  }

  Future<ServiceResult<void>> removeMember(int teamId, int userId) async {
    try {
      await _repo.removeMember(teamId, userId);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure('Erreur retrait membre : $e');
    }
  }

  Future<EventTeam?> getUserTeam(int eventId, int userId) =>
      _repo.getUserTeamForEvent(eventId, userId);
}
