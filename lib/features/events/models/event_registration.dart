/// Inscription d'un utilisateur à un événement ou une compétition.
class EventRegistration {
  final int? id;
  final int eventId;
  final int userId;
  final String status; // 'confirmed' | 'cancelled' | 'waitlisted'
  final int? teamId;
  final String registeredAt;
  final String? cancelledAt;
  final String? checkedInAt; // date/heure du scan QR de validation de présence

  // Champ calculé — rempli par le repository via JOIN
  final String? eventTitle;
  final String? eventType;
  final String? eventStartDate;
  final String? ticketCode; // identifiant unique pour le billet/QR

  const EventRegistration({
    this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.teamId,
    required this.registeredAt,
    this.cancelledAt,
    this.checkedInAt,
    this.eventTitle,
    this.eventType,
    this.eventStartDate,
    this.ticketCode,
  });

  bool get isCheckedIn => checkedInAt != null;

  static const Map<String, String> statusLabels = {
    'confirmed': 'Confirmée',
    'cancelled': 'Annulée',
    'waitlisted': 'Liste d\'attente',
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'event_id': eventId,
    'user_id': userId,
    'status': status,
    'team_id': teamId,
    'registered_at': registeredAt,
    'cancelled_at': cancelledAt,
    'checked_in_at': checkedInAt,
    'ticket_code': ticketCode,
  };

  factory EventRegistration.fromMap(Map<String, dynamic> map) =>
      EventRegistration(
        id: map['id'] as int?,
        eventId: map['event_id'] as int,
        userId: map['user_id'] as int,
        status: map['status'] as String,
        teamId: map['team_id'] as int?,
        registeredAt: map['registered_at'] as String,
        cancelledAt: map['cancelled_at'] as String?,
        checkedInAt: map['checked_in_at'] as String?,
        ticketCode: map['ticket_code'] as String?,
        // JOIN columns
        eventTitle: map['title'] as String?,
        eventType: map['type'] as String?,
        eventStartDate: map['start_date'] as String?,
      );
}
