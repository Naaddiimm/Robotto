/// Équipe participant à une compétition.
class EventTeam {
  final int? id;
  final int eventId;
  final String name;
  final int leaderId;
  final String createdAt;

  // Champ calculé
  final int? memberCount;

  const EventTeam({
    this.id,
    required this.eventId,
    required this.name,
    required this.leaderId,
    required this.createdAt,
    this.memberCount,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'event_id': eventId,
    'name': name,
    'leader_id': leaderId,
    'created_at': createdAt,
  };

  factory EventTeam.fromMap(Map<String, dynamic> map) => EventTeam(
    id: map['id'] as int?,
    eventId: map['event_id'] as int,
    name: map['name'] as String,
    leaderId: map['leader_id'] as int,
    createdAt: map['created_at'] as String,
    memberCount: map['member_count'] as int?,
  );
}

/// Membre d'une équipe.
class EventTeamMember {
  final int? id;
  final int teamId;
  final int userId;
  final String role; // 'leader' | 'member'
  final String joinedAt;

  const EventTeamMember({
    this.id,
    required this.teamId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'team_id': teamId,
    'user_id': userId,
    'role': role,
    'joined_at': joinedAt,
  };

  factory EventTeamMember.fromMap(Map<String, dynamic> map) => EventTeamMember(
    id: map['id'] as int?,
    teamId: map['team_id'] as int,
    userId: map['user_id'] as int,
    role: map['role'] as String,
    joinedAt: map['joined_at'] as String,
  );
}
