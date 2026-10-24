// ---------------------------------------------------------------------------
// Learning data models
// ---------------------------------------------------------------------------

enum LessonState { todo, active, done }

class LessonModel {
  final int id;
  final String title;
  final String duration;
  final LessonState state;
  final String? videoId;
  final String content;

  const LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    this.state = LessonState.todo,
    this.videoId,
    this.content = '',
  });
}

class ModuleModel {
  final String title;
  final List<LessonModel> lessons;

  const ModuleModel({required this.title, required this.lessons});

  int get doneCount => lessons.where((l) => l.state == LessonState.done).length;
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
  final String content;
  final String? videoId;
  final List<LessonModel> lessons;

  const CoursModel({
    required this.id,
    required this.title,
    required this.module,
    required this.description,
    required this.level,
    required this.duration,
    required this.rating,
    this.content = '',
    this.videoId,
    required this.lessons,
  });

  int get doneCount => lessons.where((l) => l.state == LessonState.done).length;
  double get progress => lessons.isEmpty ? 0 : doneCount / lessons.length;

  CoursModel copyWith({
    String? title,
    String? module,
    String? description,
    String? level,
    String? duration,
    String? content,
    String? videoId,
    List<LessonModel>? lessons,
  }) => CoursModel(
        id: id,
        title: title ?? this.title,
        module: module ?? this.module,
        description: description ?? this.description,
        level: level ?? this.level,
        duration: duration ?? this.duration,
        rating: rating,
        content: content ?? this.content,
        videoId: videoId ?? this.videoId,
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
  final String? videoId;
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
    this.videoId,
    required this.modules,
  });

  int get totalLessons => modules.fold(0, (s, m) => s + m.totalCount);
  int get doneLessons => modules.fold(0, (s, m) => s + m.doneCount);
  double get progress => totalLessons == 0 ? 0 : doneLessons / totalLessons;

  FormationModel copyWith({
    String? title,
    String? subtitle,
    String? level,
    String? duration,
    String? videoId,
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
        videoId: videoId ?? this.videoId,
        modules: modules ?? this.modules,
      );
}

// ── Sample data ───────────────────────────────────────────────────────────────

final kSampleCours = <CoursModel>[
  CoursModel(
    id: 1,
    title: 'Initiation à Arduino',
    module: 'Module 2 · Capteurs',
    description: 'Apprenez à brancher et lire des capteurs avec Arduino.',
    level: 'Débutant',
    duration: '55 min',
    rating: 4.7,
    videoId: 'gyMwXuJrbJQ',
    content:
        "Arduino est une plateforme open-source basée sur un microcontrôleur.\n\n"
        "**Qu'est-ce qu'un capteur ?**\n\n"
        "Un capteur mesure une grandeur physique et la convertit en signal électrique.\n\n"
        "**Branchement de base**\n\n"
        "1. VCC → broche 5 V de l'Arduino\n"
        "2. GND → broche GND\n"
        "3. OUT → broche analogique A0\n\n"
        "**Lire les données**\n\n"
        "```cpp\n"
        "void setup() { Serial.begin(9600); }\n\n"
        "void loop() {\n"
        "  int valeur = analogRead(A0);\n"
        "  float tension = valeur * (5.0 / 1023.0);\n"
        "  Serial.println(valeur);\n"
        "  delay(500);\n"
        "}\n"
        "```",
    lessons: const [
      LessonModel(id: 11, title: 'Leçon 3 · Brancher un capteur',
          duration: '12 min', state: LessonState.done),
      LessonModel(id: 12, title: 'Leçon 4 · Lire un capteur',
          duration: '9 min', state: LessonState.active),
      LessonModel(id: 13, title: 'Leçon 5 · Afficher les valeurs',
          duration: '11 min'),
      LessonModel(id: 14, title: 'Leçon 6 · Mini-projet', duration: '20 min'),
      LessonModel(id: 15, title: 'Quiz du module', duration: '5 questions'),
    ],
  ),
  CoursModel(
    id: 2,
    title: 'Python pour débutants',
    module: 'Module 1 · Bases',
    description: 'Maîtrisez les fondamentaux de Python.',
    level: 'Débutant',
    duration: '1h 20min',
    rating: 4.9,
    videoId: '_uQrJ0TkZlc',
    content:
        "Python est un langage de programmation lisible et polyvalent.\n\n"
        "**Variables et types**\n\n"
        "```python\n"
        "age = 17\n"
        "nom = 'ROBOTTO'\n"
        "actif = True\n"
        "print(type(age))  # <class 'int'>\n"
        "```\n\n"
        "**Conditions**\n\n"
        "```python\n"
        "note = 14\n"
        "if note >= 16:\n"
        "    print('Très bien')\n"
        "elif note >= 12:\n"
        "    print('Bien')\n"
        "else:\n"
        "    print('Passable')\n"
        "```\n\n"
        "**Boucles**\n\n"
        "```python\n"
        "for i in range(5):\n"
        "    print('Tour', i)\n"
        "```\n\n"
        "**Fonctions**\n\n"
        "```python\n"
        "def addition(a, b):\n"
        "    return a + b\n\n"
        "print(addition(3, 7))  # 10\n"
        "```",
    lessons: const [
      LessonModel(id: 21, title: 'Leçon 1 · Variables & types',
          duration: '14 min', state: LessonState.done),
      LessonModel(id: 22, title: 'Leçon 2 · Conditions',
          duration: '10 min', state: LessonState.done),
      LessonModel(id: 23, title: 'Leçon 3 · Boucles', duration: '12 min'),
      LessonModel(id: 24, title: 'Leçon 4 · Fonctions', duration: '16 min'),
    ],
  ),
  CoursModel(
    id: 3,
    title: 'Électronique embarquée',
    module: 'Module 3 · Actionneurs',
    description: 'Contrôlez moteurs et servos pour vos robots.',
    level: 'Intermédiaire',
    duration: '55 min',
    rating: 4.6,
    videoId: 'BLrHTHUjPuw',
    content:
        "Les actionneurs convertissent un signal électrique en mouvement.\n\n"
        "**Moteur DC — câblage L298N**\n\n"
        "```\n"
        "Arduino   L298N\n"
        "  9  ───  IN1\n"
        "  8  ───  IN2\n"
        " ~10  ───  ENA\n"
        "```\n\n"
        "**Code moteur**\n\n"
        "```cpp\n"
        "void loop() {\n"
        "  digitalWrite(IN1, HIGH);\n"
        "  digitalWrite(IN2, LOW);\n"
        "  analogWrite(ENA, 128);  // 50%\n"
        "  delay(2000);\n"
        "}\n"
        "```\n\n"
        "**Servomoteur**\n\n"
        "```cpp\n"
        "#include <Servo.h>\n"
        "Servo s;\n"
        "void setup() { s.attach(9); }\n"
        "void loop() {\n"
        "  s.write(0);   delay(1000);\n"
        "  s.write(90);  delay(1000);\n"
        "  s.write(180); delay(1000);\n"
        "}\n"
        "```",
    lessons: const [
      LessonModel(id: 31, title: 'Leçon 7 · Contrôler un moteur',
          duration: '14 min'),
      LessonModel(id: 32, title: 'Leçon 8 · Servomoteur', duration: '11 min'),
      LessonModel(id: 33, title: 'Leçon 9 · Projet final', duration: '30 min'),
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
    videoId: 'gyMwXuJrbJQ',
    modules: const [
      ModuleModel(title: 'Module 1 · Introduction', lessons: [
        LessonModel(id: 101, title: 'Leçon 1 · Présentation Arduino',
            duration: '8 min', state: LessonState.done,
            videoId: 'gyMwXuJrbJQ'),
        LessonModel(id: 102, title: 'Leçon 2 · Installer l\'IDE',
            duration: '10 min', state: LessonState.done,
            videoId: 'gyMwXuJrbJQ'),
      ]),
      ModuleModel(title: 'Module 2 · Capteurs', lessons: [
        LessonModel(id: 201, title: 'Leçon 3 · Brancher un capteur',
            duration: '12 min', state: LessonState.done,
            videoId: 'gyMwXuJrbJQ'),
        LessonModel(id: 202, title: 'Leçon 4 · Lire un capteur',
            duration: '9 min', state: LessonState.active,
            videoId: 'gyMwXuJrbJQ'),
        LessonModel(id: 203, title: 'Leçon 5 · Afficher les valeurs',
            duration: '11 min'),
        LessonModel(id: 204, title: 'Leçon 6 · Mini-projet',
            duration: '20 min'),
        LessonModel(id: 205, title: 'Quiz du module', duration: '5 questions'),
      ]),
      ModuleModel(title: 'Module 3 · Actionneurs', lessons: [
        LessonModel(id: 301, title: 'Leçon 7 · Contrôler un moteur',
            duration: '14 min', videoId: 'BLrHTHUjPuw'),
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
    videoId: '_uQrJ0TkZlc',
    modules: const [
      ModuleModel(title: 'Module 1 · Python avancé', lessons: [
        LessonModel(id: 401, title: 'Leçon 1 · Classes & objets',
            duration: '15 min', state: LessonState.done,
            videoId: '_uQrJ0TkZlc'),
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
