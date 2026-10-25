/// Résultat d'un participant dans une compétition.
class CompetitionResult {
  final int? id;
  final int eventId;
  final int rank;
  final String participant; // nom équipe ou utilisateur
  final double? score;
  final String? notes;

  const CompetitionResult({
    this.id,
    required this.eventId,
    required this.rank,
    required this.participant,
    this.score,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'event_id': eventId,
    'rank': rank,
    'participant': participant,
    'score': score,
    'notes': notes,
  };

  factory CompetitionResult.fromMap(Map<String, dynamic> map) =>
      CompetitionResult(
        id: map['id'] as int?,
        eventId: map['event_id'] as int,
        rank: map['rank'] as int,
        participant: map['participant'] as String,
        score: map['score'] != null ? (map['score'] as num).toDouble() : null,
        notes: map['notes'] as String?,
      );
}
