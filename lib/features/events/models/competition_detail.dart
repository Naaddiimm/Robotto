/// Données spécifiques à une compétition (complète EventModel, relation 1-to-1).
class CompetitionDetail {
  final int eventId; // FK → events.id
  final String participationType; // 'individual' | 'team' | 'both'
  final int? teamMinSize;
  final int? teamMaxSize;
  final String? robotCategory;
  final String? prizeDescription;
  final bool resultsPublished;

  const CompetitionDetail({
    required this.eventId,
    required this.participationType,
    this.teamMinSize,
    this.teamMaxSize,
    this.robotCategory,
    this.prizeDescription,
    this.resultsPublished = false,
  });

  static const List<String> participationTypes = ['individual', 'team', 'both'];

  static const Map<String, String> participationLabels = {
    'individual': 'Individuel',
    'team': 'Par équipe',
    'both': 'Individuel ou équipe',
  };

  static const List<String> robotCategories = [
    'Sumo',
    'Line follower',
    'Maze solver',
    'Combat',
    'Drone',
    'Bras robotique',
    'Robot mobile',
    'Autre',
  ];

  Map<String, dynamic> toMap() => {
    'id': eventId,
    'participation_type': participationType,
    'team_min_size': teamMinSize,
    'team_max_size': teamMaxSize,
    'robot_category': robotCategory,
    'prize_description': prizeDescription,
    'results_published': resultsPublished ? 1 : 0,
  };

  factory CompetitionDetail.fromMap(Map<String, dynamic> map) =>
      CompetitionDetail(
        eventId: map['id'] as int,
        participationType: map['participation_type'] as String,
        teamMinSize: map['team_min_size'] as int?,
        teamMaxSize: map['team_max_size'] as int?,
        robotCategory: map['robot_category'] as String?,
        prizeDescription: map['prize_description'] as String?,
        resultsPublished: (map['results_published'] as int) == 1,
      );

  CompetitionDetail copyWith({
    int? eventId,
    String? participationType,
    int? teamMinSize,
    int? teamMaxSize,
    String? robotCategory,
    String? prizeDescription,
    bool? resultsPublished,
  }) => CompetitionDetail(
    eventId: eventId ?? this.eventId,
    participationType: participationType ?? this.participationType,
    teamMinSize: teamMinSize ?? this.teamMinSize,
    teamMaxSize: teamMaxSize ?? this.teamMaxSize,
    robotCategory: robotCategory ?? this.robotCategory,
    prizeDescription: prizeDescription ?? this.prizeDescription,
    resultsPublished: resultsPublished ?? this.resultsPublished,
  );
}
