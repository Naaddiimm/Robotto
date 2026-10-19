/// Modèle de données pour un événement ou une compétition.
///
/// Le champ [type] distingue 'event' et 'competition'.
/// Les données spécifiques aux compétitions sont dans [CompetitionDetail].
class EventModel {
  final int? id;
  final int organizerId;
  final String title;
  final String description;
  final String type; // 'event' | 'competition'
  final String category;
  final String level; // 'debutant' | 'intermediaire' | 'avance' | 'tous'
  final String mode; // 'presentiel' | 'enligne' | 'hybride'
  final String status; // 'draft' | 'published' | 'cancelled' | 'completed'
  final String? location;
  final String? address;
  final String? onlineLink;
  final String startDate;
  final String endDate;
  final String? registrationDeadline;
  final int capacity;
  final double price;
  final String? coverImagePath;
  final String? program;
  final String? rules;
  final String? contactEmail;
  final String? contactPhone;
  final String createdAt;
  final String updatedAt;

  const EventModel({
    this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.level,
    required this.mode,
    required this.status,
    this.location,
    this.address,
    this.onlineLink,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    required this.capacity,
    required this.price,
    this.coverImagePath,
    this.program,
    this.rules,
    this.contactEmail,
    this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizer_id': organizerId,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'level': level,
      'mode': mode,
      'status': status,
      'location': location,
      'address': address,
      'online_link': onlineLink,
      'start_date': startDate,
      'end_date': endDate,
      'registration_deadline': registrationDeadline,
      'capacity': capacity,
      'price': price,
      'cover_image_path': coverImagePath,
      'program': program,
      'rules': rules,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int?,
      organizerId: map['organizer_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      level: map['level'] as String,
      mode: map['mode'] as String,
      status: map['status'] as String,
      location: map['location'] as String?,
      address: map['address'] as String?,
      onlineLink: map['online_link'] as String?,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      registrationDeadline: map['registration_deadline'] as String?,
      capacity: map['capacity'] as int,
      price: (map['price'] as num).toDouble(),
      coverImagePath: map['cover_image_path'] as String?,
      program: map['program'] as String?,
      rules: map['rules'] as String?,
      contactEmail: map['contact_email'] as String?,
      contactPhone: map['contact_phone'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  EventModel copyWith({
    int? id,
    int? organizerId,
    String? title,
    String? description,
    String? type,
    String? category,
    String? level,
    String? mode,
    String? status,
    String? location,
    String? address,
    String? onlineLink,
    String? startDate,
    String? endDate,
    String? registrationDeadline,
    int? capacity,
    double? price,
    String? coverImagePath,
    String? program,
    String? rules,
    String? contactEmail,
    String? contactPhone,
    String? createdAt,
    String? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      level: level ?? this.level,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      location: location ?? this.location,
      address: address ?? this.address,
      onlineLink: onlineLink ?? this.onlineLink,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      capacity: capacity ?? this.capacity,
      price: price ?? this.price,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      program: program ?? this.program,
      rules: rules ?? this.rules,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Catégories disponibles dans le cahier des charges
  static const List<String> categories = [
    'Compétition',
    'Hackathon',
    'Workshop',
    'Conférence',
    'Salon',
    'Autre',
  ];

  /// Niveaux disponibles
  static const List<String> levels = [
    'debutant',
    'intermediaire',
    'avance',
    'tous',
  ];

  /// Libellés affichables pour les niveaux
  static const Map<String, String> levelLabels = {
    'debutant': 'Débutant',
    'intermediaire': 'Intermédiaire',
    'avance': 'Avancé',
    'tous': 'Tous niveaux',
  };

  /// Libellés affichables pour les modes
  static const Map<String, String> modeLabels = {
    'presentiel': 'Présentiel',
    'enligne': 'En ligne',
    'hybride': 'Hybride',
  };

  /// Libellés affichables pour les statuts
  static const Map<String, String> statusLabels = {
    'draft': 'Brouillon',
    'published': 'Publié',
    'cancelled': 'Annulé',
    'completed': 'Terminé',
  };

  bool get isCompetition => type == 'competition';
  bool get isPublished => status == 'published';
  bool get isCancelled => status == 'cancelled';
}
