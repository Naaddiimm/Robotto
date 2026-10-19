// ---------------------------------------------------------------------------
// LessonContentScreen — displays the text content of a single lesson.
// Opened when the user taps a lesson card in CoursDetailScreen.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';

// Sample lesson content keyed by lesson id.
// In a real app this would come from a database or API.
final Map<int, String> _kLessonContent = {
  // Initiation à Arduino — Module 2 · Capteurs
  11: "Un capteur est un composant électronique qui mesure une grandeur physique "
      "(température, lumière, distance…) et la convertit en signal électrique "
      "lisible par Arduino.\n\n"
      "**Branchement de base**\n\n"
      "1. Identifiez les trois broches du capteur : VCC (alimentation), GND (masse) et OUT (signal).\n"
      "2. Connectez VCC à la broche 5 V de la carte Arduino.\n"
      "3. Connectez GND à une broche GND de la carte Arduino.\n"
      "4. Connectez OUT à une broche analogique (ex. A0).\n\n"
      "**Schéma de câblage**\n\n"
      "```\n"
      "Arduino          Capteur\n"
      "  5V  ──────────  VCC\n"
      "  GND ──────────  GND\n"
      "  A0  ──────────  OUT\n"
      "```\n\n"
      "Une fois câblé, vous pouvez lire la valeur avec analogRead(A0) dans votre sketch.",

  12: "Après avoir branché votre capteur, il est temps de lire ses données depuis le code.\n\n"
      "**Fonction analogRead()**\n\n"
      "```cpp\n"
      "int valeur = analogRead(A0);\n"
      "```\n\n"
      "Cette fonction retourne un entier entre 0 et 1023, correspondant à une tension entre 0 V et 5 V.\n\n"
      "**Conversion en tension**\n\n"
      "```cpp\n"
      "float tension = valeur * (5.0 / 1023.0);\n"
      "```\n\n"
      "**Exemple complet**\n\n"
      "```cpp\n"
      "void setup() {\n"
      "  Serial.begin(9600);\n"
      "}\n\n"
      "void loop() {\n"
      "  int valeur = analogRead(A0);\n"
      "  float tension = valeur * (5.0 / 1023.0);\n"
      "  Serial.print(\"Valeur : \");\n"
      "  Serial.print(valeur);\n"
      "  Serial.print(\"  Tension : \");\n"
      "  Serial.println(tension);\n"
      "  delay(500);\n"
      "}\n"
      "```\n\n"
      "Ouvrez le Moniteur Série pour observer les données en temps réel.",

  13: "Afficher les valeurs du capteur sur l'écran LCD ou le Moniteur Série vous permet "
      "de déboguer et de comprendre le comportement de votre montage.\n\n"
      "**Avec le Moniteur Série**\n\n"
      "Utilisez Serial.println() pour envoyer les données au PC via USB.\n\n"
      "```cpp\n"
      "Serial.println(analogRead(A0));\n"
      "```\n\n"
      "**Avec un écran LCD I2C**\n\n"
      "```cpp\n"
      "#include <LiquidCrystal_I2C.h>\n"
      "LiquidCrystal_I2C lcd(0x27, 16, 2);\n\n"
      "void setup() {\n"
      "  lcd.init();\n"
      "  lcd.backlight();\n"
      "}\n\n"
      "void loop() {\n"
      "  int v = analogRead(A0);\n"
      "  lcd.setCursor(0, 0);\n"
      "  lcd.print(\"Valeur: \");\n"
      "  lcd.print(v);\n"
      "  delay(500);\n"
      "}\n"
      "```\n\n"
      "Connectez l'écran LCD : SDA → A4, SCL → A5, VCC → 5 V, GND → GND.",

  14: "Dans ce mini-projet, vous allez combiner tout ce que vous avez appris "
      "pour créer un système d'alerte simple.\n\n"
      "**Objectif**\n\n"
      "Allumer une LED lorsque la valeur du capteur dépasse un seuil.\n\n"
      "**Matériel**\n"
      "- 1 carte Arduino\n"
      "- 1 capteur analogique (ex. LDR ou potentiomètre)\n"
      "- 1 LED + résistance 220 Ω\n\n"
      "**Code**\n\n"
      "```cpp\n"
      "const int CAPTEUR = A0;\n"
      "const int LED     = 13;\n"
      "const int SEUIL   = 500;\n\n"
      "void setup() {\n"
      "  pinMode(LED, OUTPUT);\n"
      "}\n\n"
      "void loop() {\n"
      "  int v = analogRead(CAPTEUR);\n"
      "  digitalWrite(LED, v > SEUIL ? HIGH : LOW);\n"
      "  delay(100);\n"
      "}\n"
      "```\n\n"
      "Ajustez la valeur de SEUIL selon votre capteur.",

  15: "**Quiz — Module 2 · Capteurs**\n\n"
      "Répondez aux questions suivantes pour valider vos acquis.\n\n"
      "1. Quelle fonction lit une valeur sur une broche analogique ?\n"
      "   - a) digitalRead()\n"
      "   - **b) analogRead() ✓**\n"
      "   - c) sensorRead()\n\n"
      "2. Quelle plage de valeurs retourne analogRead() ?\n"
      "   - a) 0 – 255\n"
      "   - b) 0 – 512\n"
      "   - **c) 0 – 1023 ✓**\n\n"
      "3. Comment convertir une valeur analogique en tension (5 V) ?\n"
      "   - a) valeur / 255 × 5\n"
      "   - **b) valeur × (5.0 / 1023.0) ✓**\n"
      "   - c) valeur / 1024\n\n"
      "4. Quelle broche utilise-t-on pour la masse ?\n"
      "   - a) VCC\n"
      "   - b) OUT\n"
      "   - **c) GND ✓**\n\n"
      "5. Quel composant convertit une grandeur physique en signal électrique ?\n"
      "   - a) Actionneur\n"
      "   - **b) Capteur ✓**\n"
      "   - c) Résistance",

  // Python pour débutants — Module 1 · Bases
  21: "Python est un langage de programmation interprété, lisible et polyvalent. "
      "Il est idéal pour débuter en programmation.\n\n"
      "**Variables et types de base**\n\n"
      "```python\n"
      "# Entier\n"
      "age = 17\n\n"
      "# Flottant\n"
      "pi = 3.14\n\n"
      "# Chaîne de caractères\n"
      'nom = "ROBOTTO"\n\n'
      "# Booléen\n"
      "actif = True\n"
      "```\n\n"
      "**Afficher une valeur**\n\n"
      "```python\n"
      'print("Bonjour", nom)\n'
      'print("Âge :", age)\n'
      "```\n\n"
      "**Connaître le type d'une variable**\n\n"
      "```python\n"
      "print(type(age))    # <class 'int'>\n"
      "print(type(nom))    # <class 'str'>\n"
      "```\n\n"
      "Python détermine automatiquement le type lors de l'assignation — "
      "pas besoin de le déclarer.",

  22: "Les conditions permettent d'exécuter du code uniquement si une certaine "
      "expression est vraie.\n\n"
      "**Structure if / elif / else**\n\n"
      "```python\n"
      "note = 14\n\n"
      "if note >= 16:\n"
      '    print("Très bien")\n'
      "elif note >= 12:\n"
      '    print("Bien")\n'
      "elif note >= 10:\n"
      '    print("Passable")\n'
      "else:\n"
      '    print("Insuffisant")\n'
      "```\n\n"
      "**Opérateurs de comparaison**\n\n"
      "| Opérateur | Signification      |\n"
      "|-----------|-------------------|\n"
      "| ==        | Égal à            |\n"
      "| !=        | Différent de      |\n"
      "| >         | Supérieur à       |\n"
      "| <         | Inférieur à       |\n"
      "| >=        | Supérieur ou égal |\n"
      "| <=        | Inférieur ou égal |\n\n"
      "**Opérateurs logiques**\n\n"
      "```python\n"
      'if age >= 18 and pays == "DZ":\n'
      '    print("Accès autorisé")\n'
      "```",

  23: "Les boucles permettent de répéter un bloc de code plusieurs fois.\n\n"
      "**Boucle for**\n\n"
      "```python\n"
      "for i in range(5):\n"
      '    print("Tour", i)\n'
      "# Affiche : Tour 0, Tour 1, Tour 2, Tour 3, Tour 4\n"
      "```\n\n"
      "**Parcourir une liste**\n\n"
      "```python\n"
      'fruits = ["pomme", "banane", "orange"]\n'
      "for fruit in fruits:\n"
      "    print(fruit)\n"
      "```\n\n"
      "**Boucle while**\n\n"
      "```python\n"
      "compteur = 0\n"
      "while compteur < 3:\n"
      '    print("Compteur :", compteur)\n'
      "    compteur += 1\n"
      "```\n\n"
      "**break et continue**\n\n"
      "```python\n"
      "for i in range(10):\n"
      "    if i == 5:\n"
      "        break       # Sort de la boucle\n"
      "    if i % 2 == 0:\n"
      "        continue    # Passe à l'itération suivante\n"
      "    print(i)\n"
      "```",

  24: "Une fonction est un bloc de code réutilisable qui effectue une tâche précise.\n\n"
      "**Définir une fonction**\n\n"
      "```python\n"
      "def saluer(nom):\n"
      '    print("Bonjour,", nom)\n\n'
      'saluer("Yacine")   # Bonjour, Yacine\n'
      "```\n\n"
      "**Fonction avec valeur de retour**\n\n"
      "```python\n"
      "def addition(a, b):\n"
      "    return a + b\n\n"
      "resultat = addition(3, 7)\n"
      "print(resultat)   # 10\n"
      "```\n\n"
      "**Valeurs par défaut**\n\n"
      "```python\n"
      "def puissance(base, exposant=2):\n"
      "    return base ** exposant\n\n"
      "print(puissance(4))      # 16\n"
      "print(puissance(2, 10))  # 1024\n"
      "```\n\n"
      "Bonne pratique : une fonction = une seule responsabilité. "
      "Donnez-lui un nom de verbe (calculer_, afficher_, lire_).",

  // Électronique embarquée — Module 3 · Actionneurs
  31: "Un moteur à courant continu (DC) tourne lorsqu'un courant le traverse. "
      "Pour le contrôler depuis Arduino, on utilise un pont en H (ex. L298N ou L9110S).\n\n"
      "**Câblage L298N**\n\n"
      "```\n"
      "Arduino      L298N\n"
      "  9  ──────  IN1\n"
      "  8  ──────  IN2\n"
      "  ENA ─────  PWM (broche ~)\n"
      "  GND ─────  GND\n"
      "  5V  ─────  +5V logique\n"
      "Batterie ──  VIN (moteur)\n"
      "```\n\n"
      "**Code — sens et vitesse**\n\n"
      "```cpp\n"
      "const int IN1 = 9;\n"
      "const int IN2 = 8;\n"
      "const int ENA = 10; // PWM\n\n"
      "void setup() {\n"
      "  pinMode(IN1, OUTPUT);\n"
      "  pinMode(IN2, OUTPUT);\n"
      "  pinMode(ENA, OUTPUT);\n"
      "}\n\n"
      "void loop() {\n"
      "  // Marche avant à 50 %\n"
      "  digitalWrite(IN1, HIGH);\n"
      "  digitalWrite(IN2, LOW);\n"
      "  analogWrite(ENA, 128);\n"
      "  delay(2000);\n\n"
      "  // Arrêt\n"
      "  analogWrite(ENA, 0);\n"
      "  delay(500);\n\n"
      "  // Marche arrière\n"
      "  digitalWrite(IN1, LOW);\n"
      "  digitalWrite(IN2, HIGH);\n"
      "  analogWrite(ENA, 200);\n"
      "  delay(2000);\n"
      "}\n"
      "```",

  32: "Un servomoteur tourne avec précision vers un angle donné (généralement 0° à 180°).\n\n"
      "**Câblage**\n\n"
      "| Fil servomoteur | Arduino |\n"
      "|----------------|---------|\n"
      "| Rouge (VCC)    | 5 V     |\n"
      "| Marron (GND)   | GND     |\n"
      "| Orange (signal)| Pin 9   |\n\n"
      "**Bibliothèque Servo**\n\n"
      "```cpp\n"
      "#include <Servo.h>\n\n"
      "Servo monServo;\n\n"
      "void setup() {\n"
      "  monServo.attach(9);\n"
      "}\n\n"
      "void loop() {\n"
      "  monServo.write(0);    // 0°\n"
      "  delay(1000);\n"
      "  monServo.write(90);   // 90°\n"
      "  delay(1000);\n"
      "  monServo.write(180);  // 180°\n"
      "  delay(1000);\n"
      "}\n"
      "```\n\n"
      "Astuce : évitez d'alimenter un servomoteur puissant directement depuis le 5 V Arduino "
      "— utilisez une alimentation externe partagée sur le GND.",

  33: "**Projet final — Robot éviteur d'obstacles**\n\n"
      "Combinez un capteur ultrasonique HC-SR04, deux moteurs DC et un pont en H "
      "pour créer un robot qui évite les obstacles.\n\n"
      "**Matériel**\n"
      "- 1 Arduino Uno\n"
      "- 1 capteur HC-SR04\n"
      "- 1 pont en H L298N\n"
      "- 2 moteurs DC + châssis\n"
      "- 1 batterie 9 V\n\n"
      "**Logique**\n\n"
      "```\n"
      "distance = mesurer()\n"
      "si distance < 20 cm :\n"
      "    reculer 500 ms\n"
      "    tourner à droite 400 ms\n"
      "sinon :\n"
      "    avancer\n"
      "```\n\n"
      "**Fonction de mesure ultrason**\n\n"
      "```cpp\n"
      "long mesurer() {\n"
      "  digitalWrite(TRIG, LOW);\n"
      "  delayMicroseconds(2);\n"
      "  digitalWrite(TRIG, HIGH);\n"
      "  delayMicroseconds(10);\n"
      "  digitalWrite(TRIG, LOW);\n"
      "  long duree = pulseIn(ECHO, HIGH);\n"
      "  return duree * 0.034 / 2; // cm\n"
      "}\n"
      "```\n\n"
      "Assemblez le châssis, chargez le code et regardez votre robot naviguer seul !",
};

// Default content for lessons that don't have specific content yet.
String _contentFor(LessonModel lesson) =>
    _kLessonContent[lesson.id] ??
    "Contenu de la leçon à venir.\n\n"
        "Cette leçon (${lesson.title}) dure ${lesson.duration}. "
        "Le contenu détaillé sera disponible prochainement.\n\n"
        "En attendant, vous pouvez :\n"
        "- Revoir la leçon précédente\n"
        "- Consulter les ressources associées au cours\n"
        "- Poser vos questions dans la section Discussion";

// ─────────────────────────────────────────────────────────────────────────────

class LessonContentScreen extends StatelessWidget {
  final LessonModel lesson;
  final String coursTitle;

  const LessonContentScreen({
    super.key,
    required this.lesson,
    required this.coursTitle,
  });

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(lesson);
    final active = lesson.state == LessonState.active;
    final done = lesson.state == LessonState.done;

    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: LearningTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: LearningTheme.border),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(coursTitle,
                            style: LearningTheme.captionStyle,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(lesson.title,
                            style: const TextStyle(
                                fontFamily: LearningTheme.font,
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  // State badge
                  if (done)
                    _StateBadge(
                        icon: Icons.check_circle_rounded,
                        label: 'Terminée',
                        color: LearningTheme.mint)
                  else if (active)
                    _StateBadge(
                        icon: Icons.play_circle_rounded,
                        label: 'En cours',
                        color: LearningTheme.violet),
                ],
              ),
            ),

            // ── Meta bar ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: LearningTheme.cardDeco(
                  border: active ? LearningTheme.mint : null),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: LearningTheme.mint, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(lesson.title,
                        style: const TextStyle(
                            fontFamily: LearningTheme.font,
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.access_time_rounded,
                      color: LearningTheme.textSecond, size: 14),
                  const SizedBox(width: 4),
                  Text(lesson.duration,
                      style: LearningTheme.captionStyle),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: _buildContent(content),
              ),
            ),

            // ── Bottom bar ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                  border:
                      Border(top: BorderSide(color: LearningTheme.border))),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                        colors: [
                          LearningTheme.mint,
                          LearningTheme.mintDark
                        ]),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Retour au cours',
                      style: LearningTheme.buttonStyle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Simple content renderer ───────────────────────────────────────────────
  List<Widget> _buildContent(String raw) {
    final lines = raw.trim().split('\n');
    final widgets = <Widget>[];
    bool inCode = false;
    final codeBuffer = <String>[];

    for (final line in lines) {
      // Code block toggle
      if (line.trimLeft().startsWith('```')) {
        if (inCode) {
          widgets.add(_CodeBlock(code: codeBuffer.join('\n')));
          codeBuffer.clear();
          inCode = false;
        } else {
          inCode = true;
        }
        continue;
      }

      if (inCode) {
        codeBuffer.add(line);
        continue;
      }

      // Bold heading **text**
      if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            line.replaceAll('**', ''),
            style: const TextStyle(
                fontFamily: LearningTheme.font,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ));
        continue;
      }

      // Numbered list
      if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: const BoxDecoration(
                  color: LearningTheme.surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  line.trim().split('.').first,
                  style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: LearningTheme.mint,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text(
                  line.trim().replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                  style: LearningTheme.bodyStyle,
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Bullet list (- item or   - item)
      if (line.trim().startsWith('- ')) {
        final text = line.trim().substring(2);
        final isBold = text.startsWith('**') && text.contains('**');
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7, right: 10),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isBold
                        ? LearningTheme.mint
                        : LearningTheme.textSecond,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  text.replaceAll('**', ''),
                  style: TextStyle(
                      fontFamily: LearningTheme.font,
                      color: isBold
                          ? LearningTheme.mint
                          : LearningTheme.textSecond,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: isBold
                          ? FontWeight.w600
                          : FontWeight.w400),
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Table row (| … |)
      if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
        if (line.contains('---')) continue; // separator row
        final cells = line
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();
        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: LearningTheme.surface,
            border: Border.all(color: LearningTheme.border),
          ),
          child: Row(
            children: cells
                .map((c) => Expanded(
                      child: Text(c, style: LearningTheme.captionStyle),
                    ))
                .toList(),
          ),
        ));
        continue;
      }

      // Empty line — spacing
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Normal paragraph
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(line, style: LearningTheme.bodyStyle),
      ));
    }

    return widgets;
  }
}

// ── Code block widget ─────────────────────────────────────────────────────────
class _CodeBlock extends StatelessWidget {
  final String code;
  const _CodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF050C13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LearningTheme.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: LearningTheme.mint,
            fontSize: 12.5,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// ── State badge ───────────────────────────────────────────────────────────────
class _StateBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StateBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontFamily: LearningTheme.font,
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
