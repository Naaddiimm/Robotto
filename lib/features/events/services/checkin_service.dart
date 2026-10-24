import '../data/registration_repository.dart';
import '../models/event_registration.dart';

/// Résultat d'une tentative de validation de présence par QR code.
enum CheckInStatus {
  success,         // Présence enregistrée avec succès
  alreadyCheckedIn,// Billet déjà utilisé
  notConfirmed,    // Inscription annulée ou en liste d'attente
  invalidTicket,   // Code QR inconnu dans la base
  wrongEvent,      // Le billet appartient à un autre événement
}

class CheckInResult {
  final CheckInStatus status;
  final EventRegistration? registration;

  const CheckInResult({required this.status, this.registration});

  bool get isSuccess => status == CheckInStatus.success;

  String get message {
    switch (status) {
      case CheckInStatus.success:
        return 'Présence validée ✓';
      case CheckInStatus.alreadyCheckedIn:
        return 'Ce billet a déjà été scanné.';
      case CheckInStatus.notConfirmed:
        return 'Inscription non confirmée ou annulée.';
      case CheckInStatus.invalidTicket:
        return 'QR code invalide — billet introuvable.';
      case CheckInStatus.wrongEvent:
        return 'Ce billet ne correspond pas à cet événement.';
    }
  }
}

/// Service de validation de présence via scan QR.
///
/// AVERTISSEMENT — VERSION UNIVERSITAIRE LOCALE :
/// La validation repose uniquement sur la base SQLite du téléphone de
/// l'organisateur. Elle n'est pas connectée à un serveur central.
/// Un billet peut donc être accepté sur plusieurs appareils si la base
/// n'est pas la même. Pour une utilisation en production, un backend
/// centralisé avec vérification côté serveur est indispensable.
class CheckInService {
  final RegistrationRepository _repo = RegistrationRepository();

  /// Valide la présence d'un participant à partir de son [ticketCode] scanné.
  ///
  /// Si [expectedEventId] est fourni, vérifie que le billet correspond
  /// bien à cet événement.
  Future<CheckInResult> validateTicket({
    required String ticketCode,
    int? expectedEventId,
  }) async {
    // 1. Recherche du billet
    final reg = await _repo.getByTicketCode(ticketCode.trim());
    if (reg == null) {
      return const CheckInResult(status: CheckInStatus.invalidTicket);
    }

    // 2. Vérification de l'événement si précisé
    if (expectedEventId != null && reg.eventId != expectedEventId) {
      return CheckInResult(
          status: CheckInStatus.wrongEvent, registration: reg);
    }

    // 3. L'inscription doit être confirmée
    if (reg.status != 'confirmed') {
      return CheckInResult(
          status: CheckInStatus.notConfirmed, registration: reg);
    }

    // 4. Billet déjà scanné ?
    if (reg.isCheckedIn) {
      return CheckInResult(
          status: CheckInStatus.alreadyCheckedIn, registration: reg);
    }

    // 5. Enregistrement atomique de la présence
    final success = await _repo.checkIn(reg.id!);
    if (!success) {
      // Rare : deux scans simultanés — le second perd la course
      return CheckInResult(
          status: CheckInStatus.alreadyCheckedIn, registration: reg);
    }

    // Recharger pour avoir checked_in_at à jour
    final updated = await _repo.getByTicketCode(ticketCode.trim());
    return CheckInResult(
        status: CheckInStatus.success, registration: updated ?? reg);
  }
}
