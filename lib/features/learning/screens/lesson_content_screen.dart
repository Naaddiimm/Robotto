// ---------------------------------------------------------------------------
// LessonContentScreen — displays the text content of a single lesson.
// Opened when the user taps a lesson card in CoursDetailScreen.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../learning_theme.dart';
import '../data/learning_models.dart';
import '../widgets/orientation_aware_wrapper.dart';
import '../widgets/youtube_player_section.dart';

// Sample lesson content keyed by lesson id.
// In a real app this would come from a database or API.
final Map<int, String> _kLessonContent = {
  // ── Formation: Initiation à Arduino ──────────────────────────────────────

  // Module 1 · Introduction
  101:
      "Arduino est une plateforme électronique open-source conçue pour rendre "
      "la programmation matérielle accessible à tous — des débutants aux experts.\n\n"
      "**Qu'est-ce qu'Arduino ?**\n\n"
      "- Une carte électronique avec un microcontrôleur (AVR ou ARM)\n"
      "- Un environnement de développement (IDE) gratuit et multiplateforme\n"
      "- Une communauté mondiale qui partage des bibliothèques et projets\n\n"
      "**Les composants clés de la carte**\n\n"
      "| Composant           | Rôle                                      |\n"
      "|---------------------|-------------------------------------------|\n"
      "| Microcontrôleur     | Exécute le programme (sketch)             |\n"
      "| Broches numériques  | Lecture/écriture de signaux 0 V / 5 V    |\n"
      "| Broches analogiques | Lecture de tensions entre 0 V et 5 V     |\n"
      "| Port USB            | Alimentation + transfert de programme     |\n"
      "| LED intégrée        | Reliée à la broche 13                     |\n\n"
      "**Votre premier sketch — Blink**\n\n"
      "```cpp\n"
      "void setup() {\n"
      "  pinMode(13, OUTPUT); // Configurer la broche 13 en sortie\n"
      "}\n\n"
      "void loop() {\n"
      "  digitalWrite(13, HIGH); // Allumer la LED\n"
      "  delay(1000);            // Attendre 1 seconde\n"
      "  digitalWrite(13, LOW);  // Éteindre la LED\n"
      "  delay(1000);            // Attendre 1 seconde\n"
      "}\n"
      "```\n\n"
      "Téléversez ce sketch et observez la LED clignoter — vous venez de programmer votre premier projet !",

  102:
      "Avant d'écrire du code Arduino, vous devez installer et configurer l'IDE "
      "(Integrated Development Environment).\n\n"
      "**Téléchargement**\n\n"
      "1. Rendez-vous sur arduino.cc/en/software\n"
      "2. Choisissez la version pour votre OS (Windows, macOS ou Linux)\n"
      "3. Installez en suivant les instructions à l'écran\n\n"
      "**L'interface de l'IDE**\n\n"
      "- **Éditeur** : zone centrale où vous écrivez votre sketch\n"
      "- **Console** : affiche les erreurs de compilation et les messages série\n"
      "- **Barre d'outils** : vérifier ✓ · téléverser → · Moniteur Série 🔍\n\n"
      "**Configurer votre carte**\n\n"
      "1. Branchez Arduino via USB\n"
      "2. Menu Outils → Type de carte → Arduino Uno\n"
      "3. Menu Outils → Port → sélectionnez le port COM (Windows) ou /dev/cu… (macOS)\n\n"
      "**Vérifier l'installation**\n\n"
      "```cpp\n"
      "// Ouvrez Fichier > Exemples > 01.Basics > Blink\n"
      "// Cliquez sur la flèche → (Téléverser)\n"
      "// La LED L sur la carte doit clignoter\n"
      "```\n\n"
      "Si vous voyez « Téléversement terminé », votre environnement est prêt !",

  // Module 2 · Capteurs (reuse ids from kSampleCours lessons = ids 11-15 already defined below)
  201:
      "Un capteur est un composant électronique qui mesure une grandeur physique "
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

  202:
      "Après avoir branché votre capteur, il est temps de lire ses données depuis le code.\n\n"
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

  203:
      "Afficher les valeurs du capteur sur l'écran LCD ou le Moniteur Série vous permet "
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

  204:
      "Dans ce mini-projet, vous allez combiner tout ce que vous avez appris "
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

  205:
      "**Quiz — Module 2 · Capteurs**\n\n"
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

  // Module 3 · Actionneurs
  301:
      "Un moteur à courant continu (DC) tourne lorsqu'un courant le traverse. "
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

  302:
      "Un servomoteur tourne avec précision vers un angle donné (généralement 0° à 180°).\n\n"
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

  303:
      "**Projet final — Robot éviteur d'obstacles**\n\n"
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

  // ── Formation: Python & IA ─────────────────────────────────────────────────

  // Module 1 · Python avancé
  401:
      "La programmation orientée objet (POO) vous permet d'organiser votre code "
      "autour de classes et d'objets, rendant vos programmes plus modulaires et réutilisables.\n\n"
      "**Définir une classe**\n\n"
      "```python\n"
      "class Robot:\n"
      "    def __init__(self, nom, vitesse):\n"
      "        self.nom = nom\n"
      "        self.vitesse = vitesse\n\n"
      "    def avancer(self):\n"
      "        print(f'{self.nom} avance à {self.vitesse} cm/s')\n\n"
      "    def __str__(self):\n"
      "        return f'Robot({self.nom})'\n"
      "```\n\n"
      "**Créer et utiliser un objet**\n\n"
      "```python\n"
      "r1 = Robot('ROBOTTO-1', 30)\n"
      "r1.avancer()        # ROBOTTO-1 avance à 30 cm/s\n"
      "print(r1)           # Robot(ROBOTTO-1)\n"
      "print(r1.vitesse)   # 30\n"
      "```\n\n"
      "**Héritage**\n\n"
      "```python\n"
      "class RobotAutonome(Robot):\n"
      "    def __init__(self, nom, vitesse, capteurs):\n"
      "        super().__init__(nom, vitesse)\n"
      "        self.capteurs = capteurs\n\n"
      "    def eviter_obstacle(self):\n"
      "        print(f'{self.nom} évite un obstacle via {self.capteurs}')\n\n"
      "r2 = RobotAutonome('ROBOTTO-2', 20, ['ultrason', 'IR'])\n"
      "r2.eviter_obstacle()\n"
      "```\n\n"
      "**Encapsulation — attributs privés**\n\n"
      "```python\n"
      "class Batterie:\n"
      "    def __init__(self, capacite):\n"
      "        self.__capacite = capacite  # Attribut privé\n\n"
      "    def get_capacite(self):\n"
      "        return self.__capacite\n"
      "```",

  402:
      "Les générateurs permettent de produire des valeurs une à une, sans charger "
      "toute la séquence en mémoire — idéal pour traiter de grands flux de données.\n\n"
      "**yield — le mot-clé clé**\n\n"
      "```python\n"
      "def compter(debut, fin):\n"
      "    n = debut\n"
      "    while n <= fin:\n"
      "        yield n\n"
      "        n += 1\n\n"
      "for val in compter(1, 5):\n"
      "    print(val)   # 1 2 3 4 5\n"
      "```\n\n"
      "**Différence liste vs générateur**\n\n"
      "| Critère   | Liste             | Générateur          |\n"
      "|-----------|-------------------|---------------------|\n"
      "| Mémoire   | Tout en RAM       | Une valeur à la fois|\n"
      "| Vitesse   | Lente si grande   | Rapide              |\n"
      "| Réutilise | Oui               | Non (épuisé)        |\n\n"
      "**Expression génératrice**\n\n"
      "```python\n"
      "# Similaire à une liste en compréhension mais avec ()\n"
      "carres = (x**2 for x in range(10))\n"
      "print(next(carres))   # 0\n"
      "print(next(carres))   # 1\n"
      "```\n\n"
      "**Cas concret — lecture de capteur en continu**\n\n"
      "```python\n"
      "def lire_capteur(nb_mesures):\n"
      "    import random\n"
      "    for _ in range(nb_mesures):\n"
      "        yield round(random.uniform(20.0, 35.0), 2)\n\n"
      "for temperature in lire_capteur(5):\n"
      "    print(f'Temp: {temperature} °C')\n"
      "```",

  403:
      "Les décorateurs permettent d'ajouter un comportement à une fonction existante "
      "sans la modifier — un principe fondamental de la programmation fonctionnelle.\n\n"
      "**Principe de base**\n\n"
      "```python\n"
      "def journaliser(func):\n"
      "    def wrapper(*args, **kwargs):\n"
      "        print(f'Appel : {func.__name__}')\n"
      "        resultat = func(*args, **kwargs)\n"
      "        print(f'Fin : {func.__name__}')\n"
      "        return resultat\n"
      "    return wrapper\n\n"
      "@journaliser\n"
      "def calculer(a, b):\n"
      "    return a + b\n\n"
      "calculer(3, 4)\n"
      "# Appel : calculer\n"
      "# Fin : calculer\n"
      "```\n\n"
      "**Décorateur avec arguments**\n\n"
      "```python\n"
      "def repeter(n):\n"
      "    def decorateur(func):\n"
      "        def wrapper(*args, **kwargs):\n"
      "            for _ in range(n):\n"
      "                func(*args, **kwargs)\n"
      "        return wrapper\n"
      "    return decorateur\n\n"
      "@repeter(3)\n"
      "def saluer():\n"
      "    print('Bonjour !')\n\n"
      "saluer()   # Bonjour ! Bonjour ! Bonjour !\n"
      "```\n\n"
      "**Décorateurs courants en Python**\n\n"
      "- **@staticmethod** : méthode sans accès à l'instance\n"
      "- **@classmethod** : méthode avec accès à la classe\n"
      "- **@property** : transforme une méthode en attribut calculé\n"
      "- **@functools.lru_cache** : mémoïsation automatique",

  // Module 2 · NumPy & Pandas
  501:
      "NumPy est la bibliothèque de calcul numérique de référence en Python. "
      "Elle fournit des tableaux multidimensionnels (ndarray) hautement performants.\n\n"
      "**Installer et importer**\n\n"
      "```python\n"
      "# pip install numpy\n"
      "import numpy as np\n"
      "```\n\n"
      "**Créer un tableau**\n\n"
      "```python\n"
      "a = np.array([1, 2, 3, 4, 5])\n"
      "b = np.zeros((3, 3))          # Matrice 3×3 de zéros\n"
      "c = np.linspace(0, 1, 5)     # 5 valeurs entre 0 et 1\n"
      "print(a.shape)   # (5,)\n"
      "print(b.shape)   # (3, 3)\n"
      "```\n\n"
      "**Opérations vectorisées**\n\n"
      "```python\n"
      "temperatures = np.array([22.5, 23.1, 21.8, 24.0])\n"
      "print(temperatures.mean())    # Moyenne\n"
      "print(temperatures.max())     # Maximum\n"
      "print(temperatures.std())     # Écart-type\n"
      "# Convertir en Fahrenheit\n"
      "fahrenheit = temperatures * 9/5 + 32\n"
      "```\n\n"
      "**Slicing & indexation**\n\n"
      "```python\n"
      "data = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])\n"
      "print(data[0, :])     # Première ligne : [1 2 3]\n"
      "print(data[:, 1])     # Deuxième colonne : [2 5 8]\n"
      "print(data[1:, 1:])   # Sous-matrice 2×2\n"
      "```\n\n"
      "**Cas robotique — traitement de données capteur**\n\n"
      "```python\n"
      "mesures = np.array([15.2, 15.8, 999.0, 16.1, 15.5])  # 999 = erreur\n"
      "filtrees = mesures[mesures < 100]  # Filtrer les valeurs aberrantes\n"
      "print(filtrees.mean())   # Moyenne sans le bruit\n"
      "```",

  502:
      "Pandas est la bibliothèque Python pour la manipulation de données tabulaires. "
      "Elle repose sur deux structures : la Series (colonne) et le DataFrame (tableau).\n\n"
      "**Installer et importer**\n\n"
      "```python\n"
      "# pip install pandas\n"
      "import pandas as pd\n"
      "```\n\n"
      "**Créer un DataFrame**\n\n"
      "```python\n"
      "data = {\n"
      "    'capteur': ['temperature', 'humidite', 'pression'],\n"
      "    'valeur':  [22.5, 65.3, 1013.2],\n"
      "    'unite':   ['°C', '%', 'hPa']\n"
      "}\n"
      "df = pd.DataFrame(data)\n"
      "print(df)\n"
      "```\n\n"
      "**Lire un fichier CSV**\n\n"
      "```python\n"
      "df = pd.read_csv('donnees_robot.csv')\n"
      "print(df.head())        # 5 premières lignes\n"
      "print(df.info())        # Types et valeurs manquantes\n"
      "print(df.describe())    # Statistiques de base\n"
      "```\n\n"
      "**Sélection et filtrage**\n\n"
      "```python\n"
      "# Sélectionner une colonne\n"
      "print(df['valeur'])\n\n"
      "# Filtrer les lignes\n"
      "alertes = df[df['valeur'] > 30]\n\n"
      "# Ajouter une colonne calculée\n"
      "df['alerte'] = df['valeur'] > 30\n"
      "```\n\n"
      "**Grouper et agréger**\n\n"
      "```python\n"
      "# Moyenne par type de capteur\n"
      "df.groupby('capteur')['valeur'].mean()\n"
      "```\n\n"
      "Pandas s'intègre parfaitement avec NumPy et Matplotlib pour "
      "un pipeline complet d'analyse de données.",

  // ── Cours standalone (kSampleCours lessons) ───────────────────────────────
  11:
      "Un capteur est un composant électronique qui mesure une grandeur physique "
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

  12:
      "Après avoir branché votre capteur, il est temps de lire ses données depuis le code.\n\n"
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

  13:
      "Afficher les valeurs du capteur sur l'écran LCD ou le Moniteur Série vous permet "
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

  14:
      "Dans ce mini-projet, vous allez combiner tout ce que vous avez appris "
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

  15:
      "**Quiz — Module 2 · Capteurs**\n\n"
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

  21:
      "Python est un langage de programmation interprété, lisible et polyvalent. "
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

  22:
      "Les conditions permettent d'exécuter du code uniquement si une certaine "
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

  23:
      "Les boucles permettent de répéter un bloc de code plusieurs fois.\n\n"
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

  24:
      "Une fonction est un bloc de code réutilisable qui effectue une tâche précise.\n\n"
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

  31:
      "Un moteur à courant continu (DC) tourne lorsqu'un courant le traverse. "
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

  32:
      "Un servomoteur tourne avec précision vers un angle donné (généralement 0° à 180°).\n\n"
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

  33:
      "**Projet final — Robot éviteur d'obstacles**\n\n"
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

// Content priority: lesson.content field (written by instructor) → hardcoded map → fallback.
String _contentFor(LessonModel lesson) {
  if (lesson.content.isNotEmpty) return lesson.content;
  return _kLessonContent[lesson.id] ??
      "Contenu de la leçon à venir.\n\n"
          "Cette leçon (${lesson.title}) dure ${lesson.duration}. "
          "Le contenu détaillé sera disponible prochainement.\n\n"
          "En attendant, vous pouvez :\n"
          "- Revoir la leçon précédente\n"
          "- Consulter les ressources associées au cours\n"
          "- Poser vos questions dans la section Discussion";
}

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
      body: OrientationAwareWrapper(
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;
              return isLandscape
                  ? _buildLandscape(context, content, active, done)
                  : _buildPortrait(context, content, active, done);
            },
          ),
        ),
      ),
    );
  }

  // ── Portrait layout ────────────────────────────────────────────────────────
  Widget _buildPortrait(
    BuildContext context,
    String content,
    bool active,
    bool done,
  ) => Column(
    children: [
      _buildHeader(context, done, active),
      if (lesson.videoId != null && lesson.videoId!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: YouTubePlayerSection(
            videoId: lesson.videoId,
            label: 'Vidéo de la leçon',
          ),
        ),
      _buildMetaBar(active),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: _buildContent(content),
        ),
      ),
      _buildBottomBar(context),
    ],
  );

  // ── Landscape layout — everything scrollable ───────────────────────────────
  Widget _buildLandscape(
    BuildContext context,
    String content,
    bool active,
    bool done,
  ) => Column(
    children: [
      _buildHeader(context, done, active),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (lesson.videoId != null && lesson.videoId!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: YouTubePlayerSection(
                  videoId: lesson.videoId,
                  label: 'Vidéo de la leçon',
                ),
              ),
            _buildMetaBar(active),
            ..._buildContent(content),
            const SizedBox(height: 12),
            _buildBottomBar(context),
          ],
        ),
      ),
    ],
  );

  Widget _buildHeader(BuildContext context, bool done, bool active) => Padding(
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
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coursTitle,
                style: LearningTheme.captionStyle,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                lesson.title,
                style: const TextStyle(
                  fontFamily: LearningTheme.font,
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (done)
          _StateBadge(
            icon: Icons.check_circle_rounded,
            label: 'Terminée',
            color: LearningTheme.mint,
          )
        else if (active)
          _StateBadge(
            icon: Icons.play_circle_rounded,
            label: 'En cours',
            color: LearningTheme.violet,
          ),
        const SizedBox(width: 8),
        const RotateHintBadge(),
      ],
    ),
  );

  Widget _buildMetaBar(bool active) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: LearningTheme.cardDeco(
      border: active ? LearningTheme.mint : null,
    ),
    child: Row(
      children: [
        const Icon(
          Icons.menu_book_rounded,
          color: LearningTheme.mint,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            lesson.title,
            style: const TextStyle(
              fontFamily: LearningTheme.font,
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(
          Icons.access_time_rounded,
          color: LearningTheme.textSecond,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(lesson.duration, style: LearningTheme.captionStyle),
      ],
    ),
  );

  Widget _buildBottomBar(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: LearningTheme.border)),
    ),
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [LearningTheme.mint, LearningTheme.mintDark],
          ),
        ),
        alignment: Alignment.center,
        child: const Text('Retour au cours', style: LearningTheme.buttonStyle),
      ),
    ),
  );

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
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontFamily: LearningTheme.font,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      // Numbered list
      if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        widgets.add(
          Padding(
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
                      fontWeight: FontWeight.w700,
                    ),
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
          ),
        );
        continue;
      }

      // Bullet list (- item or   - item)
      if (line.trim().startsWith('- ')) {
        final text = line.trim().substring(2);
        final isBold = text.startsWith('**') && text.contains('**');
        widgets.add(
          Padding(
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
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
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
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: LearningTheme.surface,
              border: Border.all(color: LearningTheme.border),
            ),
            child: Row(
              children: cells
                  .map(
                    (c) => Expanded(
                      child: Text(c, style: LearningTheme.captionStyle),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
        continue;
      }

      // Empty line — spacing
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Normal paragraph
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line, style: LearningTheme.bodyStyle),
        ),
      );
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

  const _StateBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

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
          Text(
            label,
            style: TextStyle(
              fontFamily: LearningTheme.font,
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
