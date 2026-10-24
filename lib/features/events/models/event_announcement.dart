/// Annonce publiée pour un événement ou actualité générale.
class EventAnnouncement {
  final int? id;
  final int? eventId; // null = actualité générale robotique
  final int authorId;
  final String title;
  final String content;
  final String type; // 'announcement' | 'news'
  final bool isPinned;
  final String createdAt;
  final String updatedAt;

  // Champ calculé via JOIN
  final String? eventTitle;

  const EventAnnouncement({
    this.id,
    this.eventId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.type,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.eventTitle,
  });

  static const Map<String, String> typeLabels = {
    'announcement': 'Annonce',
    'news': 'Actualité',
  };

  Map<String, dynamic> toMap() => {
        'id': id,
        'event_id': eventId,
        'author_id': authorId,
        'title': title,
        'content': content,
        'type': type,
        'is_pinned': isPinned ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory EventAnnouncement.fromMap(Map<String, dynamic> map) =>
      EventAnnouncement(
        id: map['id'] as int?,
        eventId: map['event_id'] as int?,
        authorId: map['author_id'] as int,
        title: map['title'] as String,
        content: map['content'] as String,
        type: map['type'] as String,
        isPinned: (map['is_pinned'] as int) == 1,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
        eventTitle: map['event_title'] as String?,
      );
}
