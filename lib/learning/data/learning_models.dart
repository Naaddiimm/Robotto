// ---------------------------------------------------------------------------
// Learning data models — self-contained, no dependency on other modules.
// ---------------------------------------------------------------------------

enum LessonState { todo, active, done }

class LessonModel {
  final int id;
  final String title;
  final String duration;
  final LessonState state;

  const LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    this.state = LessonState.todo,
  });
}

class ModuleModel {
  final String title;
  final List<LessonModel> lessons;

  const ModuleModel({required this.title, required this.lessons});

  int get doneCount =>
      lessons.where((l) => l.state == LessonState.done).length;
  int get totalCount => lessons.length;

  String get totalDuration {
    final mins = lessons.fold<int>(0, (s, l) {
      final m = RegExp(r'(\d+)').firstMatch(l.duration);
      return s + (m != null ? int.parse(m.group(0)!) : 0);
    });
    return '$mins min';
  }
}

class CoursModel {
  final int id;
  final String title;
  final String module;
  final String description;
  final String level;
  final String duration;
  final double rating;
  final List<LessonModel> lessons;

  const CoursModel({
    required this.id,
    required this.title,
    required this.module,
    required this.description,
    required this.level,
    required this.duration,
    required this.rating,
    required this.lessons,
  });

  int get doneCount =>
      lessons.where((l) => l.state == LessonState.done).length;
  double get progress =>
      lessons.isEmpty ? 0 : doneCount / lessons.length;

  CoursModel copyWith({
    String? title,
    String? module,
    String? description,
    String? level,
    String? duration,
    List<LessonModel>? lessons,
  }) => CoursModel(
        id: id,
        title: title ?? this.title,
        module: module ?? this.module,
        description: description ?? this.description,
        level: level ?? this.level,
        duration: duration ?? this.duration,
        rating: rating,
        lessons: lessons ?? this.lessons,
      );
}

class FormationModel {
  final int id;
  final String title;
  final String subtitle;
  final String instructor;
  final String level;
  final String duration;
  final double rating;
  final int enrolled;
  final List<ModuleModel> modules;

  const FormationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.instructor,
    required this.level,
    required this.duration,
    required this.rating,
    required this.enrolled,
    required this.modules,
  });

  int get totalLessons =>
      modules.fold(0, (s, m) => s + m.totalCount);
  int get doneLessons =>
      modules.fold(0, (s, m) => s + m.doneCount);
  double get progress =>
      totalLessons == 0 ? 0 : doneLessons / totalLessons;

  FormationModel copyWith({
    String? title,
    String? subtitle,
    String? level,
    String? duration,
    List<ModuleModel>? modules,
  }) => FormationModel(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        instructor: instructor,
        level: level ?? this.level,
        duration: duration ?? this.duration,
        rating: rating,
        enrolled: enrolled,
        modules: modules ?? this.modules,
      );
}

// ── Sample data ───────────────────────────────────────────────────────────────

final kSampleCours = <CoursModel>[
  const CoursModel(
    id: 1,
    title: 'Initiation à Arduino',
    module: 'Module 2 · Capteurs',
    description: 'Apprenez à brancher et lire des capteurs avec Arduino.',
    level: 'Débutant',
    duration: '55 min',
    rating: 4.7,
    lessons: [
      LessonModel(id: 11, title: 'Leçon 3 · Brancher un capteur',
          duration: '12 min', state: LessonState.done),
      LessonModel(id: 12, title: 'Leçon 4 · Lire un capteur',
          duration: '9 min', state: LessonState.active),
      LessonModel(id: 13, title: 'Leçon 5 · Afficher les valeurs',
          duration: '11 min'),
      LessonModel(id: 14, title: 'Leçon 6 · Mini-projet',
          duration: '20 min'),
      LessonModel(id: 15, title: 'Quiz du module', duration: '5 questions'),
    ],
  ),
  const CoursModel(
    id: 2,
    title: 'Python pour débutants',
    module: 'Module 1 · Bases',
    description: 'Maîtrisez les fondamentaux de Python.',
    level: 'Débutant',
    duration: '1h 20min',
    rating: 4.9,
    lessons: [
      LessonModel(id: 21, title: 'Leçon 1 · Variables & types',
          duration: '14 min', state: LessonState.done),
      LessonModel(id: 22, title: 'Leçon 2 · Conditions',
          duration: '10 min', state: LessonState.done),
      LessonModel(id: 23, title: 'Leçon 3 · Boucles', duration: '12 min'),
      LessonModel(id: 24, title: 'Leçon 4 · Fonctions', duration: '16 min'),
    ],
  ),
  const CoursModel(
    id: 3,
    title: 'Électronique embarquée',
    module: 'Module 3 · Actionneurs',
    description: 'Contrôlez moteurs et servos pour vos robots.',
    level: 'Intermédiaire',
    duration: '55 min',
    rating: 4.6,
    lessons: [
      LessonModel(id: 31, title: 'Leçon 7 · Contrôler un moteur',
          duration: '14 min'),
      LessonModel(id: 32, title: 'Leçon 8 · Servomoteur',
          duration: '11 min'),
      LessonModel(id: 33, title: 'Leçon 9 · Projet final',
          duration: '30 min'),
    ],
  ),
];

final kSampleFormations = <FormationModel>[
  FormationModel(
    id: 1,
    title: 'Initiation à Arduino',
    subtitle: 'De zéro à votre premier projet embarqué',
    instructor: 'Dr. Karim Benali',
    level: 'Débutant',
    duration: '3h 20min',
    rating: 4.8,
    enrolled: 1240,
    modules: const [
      ModuleModel(title: 'Module 1 · Introduction', lessons: [
        LessonModel(id: 101, title: 'Leçon 1 · Présentation Arduino',
            duration: '8 min', state: LessonState.done),
        LessonModel(id: 102, title: 'Leçon 2 · Installer l\'IDE',
            duration: '10 min', state: LessonState.done),
      ]),
      ModuleModel(title: 'Module 2 · Capteurs', lessons: [
        LessonModel(id: 201, title: 'Leçon 3 · Brancher un capteur',
            duration: '12 min', state: LessonState.done),
        LessonModel(id: 202, title: 'Leçon 4 · Lire un capteur',
            duration: '9 min', state: LessonState.active),
        LessonModel(id: 203, title: 'Leçon 5 · Afficher les valeurs',
            duration: '11 min'),
        LessonModel(id: 204, title: 'Leçon 6 · Mini-projet',
            duration: '20 min'),
        LessonModel(id: 205, title: 'Quiz du module',
            duration: '5 questions'),
      ]),
      ModuleModel(title: 'Module 3 · Actionneurs', lessons: [
        LessonModel(id: 301, title: 'Leçon 7 · Contrôler un moteur',
            duration: '14 min'),
        LessonModel(id: 302, title: 'Leçon 8 · Servomoteur',
            duration: '11 min'),
        LessonModel(id: 303, title: 'Leçon 9 · Projet final',
            duration: '30 min'),
      ]),
    ],
  ),
  FormationModel(
    id: 2,
    title: 'Python & IA',
    subtitle: 'Du script au modèle de machine learning',
    instructor: 'Mme. Sara Meziane',
    level: 'Intermédiaire',
    duration: '5h 10min',
    rating: 4.9,
    enrolled: 870,
    modules: const [
      ModuleModel(title: 'Module 1 · Python avancé', lessons: [
        LessonModel(id: 401, title: 'Leçon 1 · Classes & objets',
            duration: '15 min', state: LessonState.done),
        LessonModel(id: 402, title: 'Leçon 2 · Générateurs',
            duration: '12 min', state: LessonState.active),
        LessonModel(id: 403, title: 'Leçon 3 · Décorateurs',
            duration: '10 min'),
      ]),
      ModuleModel(title: 'Module 2 · NumPy & Pandas', lessons: [
        LessonModel(id: 501, title: 'Leçon 4 · Arrays', duration: '14 min'),
        LessonModel(id: 502, title: 'Leçon 5 · DataFrames',
            duration: '18 min'),
      ]),
    ],
  ),
];
