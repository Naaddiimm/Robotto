import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../widgets/background_waves.dart';
import '../widgets/animated_button.dart';
import '../utils/audio_helper.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  String _activeMainTab = 'Tous les projets'; // 'Tous les projets' | 'Mes projets'
  String _selectedCategory = 'Tous';
  String _selectedStatus = 'Tous';
  bool _showSearchInput = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Project> _allProjects = [
    Project(
      id: 'proj_1',
      title: 'Bras Robotique 6 Axes',
      description:
          'Conception et fabrication d\'un bras robotique 6 axes contrôlé par servomoteurs et carte STM32 avec interface graphique.',
      objectives: 'Contrôle à distance, cinématique inverse et manipulation d\'objets.',
      level: 'Avancé',
      category: 'Bras Robotique',
      visibility: 'Public',
      status: 'En cours',
      dueDate: '30 nov. 2025',
      isJoined: false,
      members: [
        ProjectMember(id: 'm1', name: 'Alex Rivera', role: 'Lead Dev'),
        ProjectMember(id: 'm2', name: 'Sami B.', role: 'Designer 3D'),
        ProjectMember(id: 'm3', name: 'Youssef K.', role: 'Électronicien'),
      ],
      tasks: [
        ProjectTask(
          id: 't1',
          title: 'Impression 3D des axes J1 et J2',
          isCompleted: true,
          dueDate: '10 Fév',
          assigneeName: 'Sami B.',
        ),
        ProjectTask(
          id: 't2',
          title: 'Câblage des servomoteurs MG996R',
          isCompleted: true,
          dueDate: '18 Fév',
          assigneeName: 'Youssef K.',
        ),
        ProjectTask(
          id: 't3',
          title: 'Algorithme de cinématique inverse',
          isCompleted: false,
          dueDate: '10 Mars',
          assigneeName: 'Alex Rivera',
        ),
      ],
      milestones: [],
    ),
    Project(
      id: 'proj_2',
      title: 'Robot Autonome Mobile',
      description:
          'Robot autonome tout-terrain équipé de capteurs ultrasons et LIDAR pour la cartographie.',
      objectives: 'Navigation autonome et évitement d\'obstacles.',
      level: 'Intermédiaire',
      category: 'Robotique mobile',
      visibility: 'Public',
      status: 'En cours',
      dueDate: '30 nov. 2025',
      isJoined: true,
      members: [
        ProjectMember(id: 'm1', name: 'Alex', role: 'Dev'),
        ProjectMember(id: 'm2', name: 'Sami', role: '3D'),
        ProjectMember(id: 'm3', name: 'Youssef', role: 'Elec'),
        ProjectMember(id: 'm4', name: 'Ines', role: 'QA'),
      ],
      tasks: [
        ProjectTask(
          id: 't1',
          title: 'Algorithme de cartographie',
          isCompleted: true,
          dueDate: '10 Nov',
          assigneeName: 'Alex',
        ),
        ProjectTask(
          id: 't2',
          title: 'Câblage des moteurs',
          isCompleted: true,
          dueDate: '15 Nov',
          assigneeName: 'Sami',
        ),
        ProjectTask(
          id: 't3',
          title: 'Optimisation batterie',
          isCompleted: false,
          dueDate: '30 Nov',
          assigneeName: 'Youssef',
        ),
      ],
      milestones: [],
    ),
    Project(
      id: 'proj_3',
      title: 'Smart Home IoT',
      description:
          'Système domotique intelligent basé sur ESP32 et protocole MQTT.',
      objectives: 'Gestion de l\'éclairage et sécurité centralisée.',
      level: 'Débutant',
      category: 'IoT & Domotique',
      visibility: 'Équipe',
      status: 'En pause',
      dueDate: '15 déc. 2025',
      isJoined: true,
      members: [
        ProjectMember(id: 'm1', name: 'Nour', role: 'Lead'),
        ProjectMember(id: 'm2', name: 'Karem', role: 'Dev'),
        ProjectMember(id: 'm3', name: 'Lilia', role: 'UI'),
      ],
      tasks: [
        ProjectTask(
          id: 't1',
          title: 'Serveur MQTT',
          isCompleted: true,
          dueDate: '01 Déc',
          assigneeName: 'Nour',
        ),
        ProjectTask(
          id: 't2',
          title: 'Application mobile',
          isCompleted: false,
          dueDate: '15 Déc',
          assigneeName: 'Karem',
        ),
      ],
      milestones: [],
    ),
    Project(
      id: 'proj_4',
      title: 'Drone Cartographe Photogrammétrie',
      description:
          'Drone quadricoptère sur contrôleur Pixhawk pour la modélisation 3D de terrains.',
      objectives: 'Autonomie de 25min et waypoint GPS automatique.',
      level: 'Avancé',
      category: 'Drone',
      visibility: 'Public',
      status: 'Terminé',
      dueDate: '10 oct. 2025',
      isJoined: false,
      members: [
        ProjectMember(id: 'm1', name: 'Sonia', role: 'Pilote'),
        ProjectMember(id: 'm2', name: 'Mehdi', role: 'Dev'),
      ],
      tasks: [
        ProjectTask(
          id: 't1',
          title: 'Calibration du gyroscope',
          isCompleted: true,
          dueDate: '12 Fév',
          assigneeName: 'Mehdi',
        ),
      ],
      milestones: [],
    ),
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  List<Project> get _displayedProjects {
    final query = _searchController.text.toLowerCase();

    if (_activeMainTab == 'Tous les projets') {
      return _allProjects.where((p) {
        final matchesSearch = p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
        final matchesCat =
            _selectedCategory == 'Tous' || p.category == _selectedCategory;
        return matchesSearch && matchesCat;
      }).toList();
    } else {
      // 'Mes projets'
      return _allProjects.where((p) {
        final matchesSearch = p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
        final matchesUser = p.isJoined || p.visibility != 'Public';
        // 'Terminés' pill maps to 'Terminé' in the model
        final statusFilter = _selectedStatus == 'Terminés' ? 'Terminé' : _selectedStatus;
        final matchesStatus =
            statusFilter == 'Tous' || p.status == statusFilter;
        return matchesSearch && matchesUser && matchesStatus;
      }).toList();
    }
  }

  void _openCreateProjectScreen() {
    AudioHelper.playClickSound();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(
          onProjectCreated: (newProj) {
            setState(() {
              _allProjects.insert(0, newProj);
            });
          },
        ),
      ),
    );
  }

  void _showParticipationConfirmationDialog(Project project) {
    AudioHelper.playClickSound();
    final isJoining = !project.isJoined;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1F2937)),
          ),
          title: Row(
            children: [
              Icon(
                isJoining ? Icons.group_add_rounded : Icons.logout_rounded,
                color: isJoining ? const Color(0xFF00F5C4) : Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isJoining ? 'Confirmer la participation' : 'Quitter le projet ?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            isJoining
                ? 'Voulez-vous vraiment rejoindre l\'équipe du projet "${project.title}" en tant que contributeur ?'
                : 'Voulez-vous vraiment quitter l\'équipe du projet "${project.title}" ?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AudioHelper.playClickSound();
                Navigator.pop(context);
              },
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _toggleProjectParticipation(project);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isJoining ? const Color(0xFF00F5C4) : Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isJoining ? 'Rejoindre' : 'Quitter',
                style: GoogleFonts.poppins(
                  color: isJoining ? const Color(0xFF090D16) : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleProjectParticipation(Project project) {
    if (!project.isJoined) {
      AudioHelper.playSuccessSound();
      setState(() {
        project.isJoined = true;
        project.members.add(
          ProjectMember(
            id: 'user_me',
            name: 'Vous',
            role: 'Contributeur',
          ),
        );
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF00F5C4)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vous participez maintenant au projet "${project.title}" !',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF111827),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      AudioHelper.playClickSound();
      setState(() {
        project.isJoined = false;
        project.members.removeWhere((m) => m.id == 'user_me' || m.name == 'Vous');
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vous avez quitté le projet "${project.title}".',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF111827),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Top Branding Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ROBOTT',
                              style: GoogleFonts.orbitron(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(left: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00F5C4),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00F5C4)
                                        .withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Search and Bell
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _showSearchInput
                                    ? Icons.close_rounded
                                    : Icons.search_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                AudioHelper.playClickSound();
                                setState(() {
                                  _showSearchInput = !_showSearchInput;
                                  if (!_showSearchInput) {
                                    _searchController.clear();
                                  }
                                });
                              },
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    AudioHelper.playClickSound();
                                  },
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00F5C4),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Search Input
                    if (_showSearchInput) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un projet, thème...',
                          hintStyle: GoogleFonts.poppins(
                            color: const Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF00F5C4),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF111827),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                const BorderSide(color: Color(0xFF1F2937)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                const BorderSide(color: Color(0xFF1F2937)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFF00F5C4),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Main Segmented Tab Switcher [ Tous les projets ] vs [ Mes projets ]
                    Container(
                      height: 46,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: const Color(0xFF1F2937)),
                      ),
                      child: Row(
                        children: [
                          _buildMainTabButton(
                            title: 'Tous les projets',
                            icon: Icons.public_rounded,
                          ),
                          _buildMainTabButton(
                            title: 'Mes projets',
                            icon: Icons.folder_special_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Hero Header Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeMainTab == 'Tous les projets'
                                    ? 'Projets & Communauté'
                                    : 'Mes projets',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _activeMainTab == 'Tous les projets'
                                    ? 'Découvrez, inspirez-vous et collaborez.'
                                    : 'Construisez vos idées.',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // "+ Nouveau" Button
                        AnimatedButton(
                          isPrimary: true,
                          onPressed: _openCreateProjectScreen,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5C4),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F5C4)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Color(0xFF090D16),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Nouveau',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF090D16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // If 'Mes projets', show Stats Dashboard Badges
                    if (_activeMainTab == 'Mes projets') ...[
                      Row(
                        children: [
                          _buildStatCard(
                            icon: Icons.folder_outlined,
                            iconColor: const Color(0xFF00F5C4),
                            value: '${_allProjects.where((p) => p.status == 'En cours').length}',
                            label: 'En cours',
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF00F5C4),
                            value: '${_allProjects.where((p) => p.status == 'Terminé').length}',
                            label: 'Terminés',
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            icon: Icons.pause_circle_outline_rounded,
                            iconColor: Colors.amber,
                            value: '${_allProjects.where((p) => p.status == 'En pause').length}',
                            label: 'En pause',
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            icon: Icons.people_outline_rounded,
                            iconColor: const Color(0xFF3B82F6),
                            value: '${_allProjects.expand((p) => p.members).length}',
                            label: 'Membres',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Pills Row
                      Row(
                        children: [
                          _buildStatusPill('Tous'),
                          const SizedBox(width: 6),
                          _buildStatusPill('En cours'),
                          const SizedBox(width: 6),
                          _buildStatusPill('En pause'),
                          const SizedBox(width: 6),
                          _buildStatusPill('Terminés'),
                        ],
                      ),
                    ] else ...[
                      // Category Filter Chips
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            'Tous',
                            'Bras Robotique',
                            'Robotique mobile',
                            'Drone',
                            'IoT & Domotique',
                            'Électronique',
                          ].map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (val) {
                                  AudioHelper.playClickSound();
                                  setState(() => _selectedCategory = cat);
                                },
                                selectedColor: const Color(0xFF00F5C4),
                                backgroundColor: const Color(0xFF111827),
                                labelStyle: GoogleFonts.poppins(
                                  color: isSelected
                                      ? const Color(0xFF090D16)
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 11.5,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF00F5C4)
                                      : const Color(0xFF1F2937),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Elegant Animated List of Projects
                    if (_displayedProjects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Aucun projet trouvé',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _displayedProjects.length,
                        itemBuilder: (context, index) {
                          return _buildElegantProjectCard(
                            _displayedProjects[index],
                            index,
                          );
                        },
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabButton({
    required String title,
    required IconData icon,
  }) {
    final isSelected = _activeMainTab == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioHelper.playClickSound();
          setState(() {
            _activeMainTab = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00F5C4) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF090D16) : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF090D16) : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF1F2937),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String title) {
    final isSelected = _selectedStatus == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioHelper.playClickSound();
          setState(() {
            _selectedStatus = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00F5C4) : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF00F5C4) : const Color(0xFF1F2937),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF090D16) : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElegantProjectCard(Project project, int index) {
    final progress = project.progressPercentage > 0
        ? project.progressPercentage
        : (index % 2 == 0 ? 0.65 : 0.35);

    Color statusBg;
    Color statusText;
    if (project.status == 'En cours') {
      statusBg = const Color(0xFF00F5C4);
      statusText = const Color(0xFF090D16);
    } else if (project.status == 'En pause') {
      statusBg = const Color(0xFFF59E0B);
      statusText = const Color(0xFF090D16);
    } else {
      statusBg = const Color(0xFF0284C7);
      statusText = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2937)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AudioHelper.playCardTapSound();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(project: project),
              ),
            ).then((_) => setState(() {}));
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Thumbnail + Title & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Square Project Thumbnail Box
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 85,
                        height: 85,
                        color: const Color(0xFF090D16),
                        child: (project.imagePath != null &&
                                project.imagePath!.isNotEmpty)
                            ? (kIsWeb
                                ? Image.network(
                                    project.imagePath!,
                                    width: 85,
                                    height: 85,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        _buildDefaultThumbnail(project),
                                  )
                                : Image.file(
                                    File(project.imagePath!),
                                    width: 85,
                                    height: 85,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        _buildDefaultThumbnail(project),
                                  ))
                            : _buildDefaultThumbnail(project),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  project.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  project.status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: statusText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),

                          Text(
                            project.category,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Animated Progress Line
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFF1F2937),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF00F5C4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Footer Row: Members count + Participer Button or Due Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          size: 15,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${project.members.length} membres',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFFD1D5DB),
                          ),
                        ),
                      ],
                    ),

                    // "Participer" Button for Public Projects
                    if (project.visibility == 'Public') ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showParticipationConfirmationDialog(project);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: project.isJoined
                                  ? const Color(0xFF00F5C4)
                                      .withValues(alpha: 0.2)
                                  : const Color(0xFF00F5C4),
                              borderRadius: BorderRadius.circular(14),
                              border: project.isJoined
                                  ? Border.all(color: const Color(0xFF00F5C4))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  project.isJoined
                                      ? Icons.check_circle_rounded
                                      : Icons.group_add_rounded,
                                  size: 13,
                                  color: project.isJoined
                                      ? const Color(0xFF00F5C4)
                                      : const Color(0xFF090D16),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  project.isJoined ? 'Participé' : 'Participer',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: project.isJoined
                                        ? const Color(0xFF00F5C4)
                                        : const Color(0xFF090D16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            project.dueDate,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFFD1D5DB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail(Project project) {
    IconData icon;
    if (project.category.contains('mobile') || project.category.contains('Robot')) {
      icon = Icons.smart_toy_rounded;
    } else if (project.category.contains('IoT') || project.category.contains('Domotique')) {
      icon = Icons.lightbulb_outline_rounded;
    } else if (project.category.contains('Drone')) {
      icon = Icons.flight_takeoff_rounded;
    } else {
      icon = Icons.precision_manufacturing_rounded;
    }

    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 38,
          color: const Color(0xFF00F5C4),
        ),
      ),
    );
  }
}
