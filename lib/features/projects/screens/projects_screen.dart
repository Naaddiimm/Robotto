import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../../../core/widgets/background_waves.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/utils/audio_helper.dart';
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

  final List<Project> _allProjects = [];
  String _currentUserId = '1';
  bool _isLoading = true;

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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await AuthService().getCurrentUserId();
      _currentUserId = userId?.toString() ?? '1';
      await _loadSavedProjects();
    } catch (e) {
      debugPrint('Error loading project data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSavedProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('robotto_user_projects');
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        _allProjects.clear();
        for (final item in list) {
          _allProjects.add(Project.fromMap(item as Map<String, dynamic>));
        }
      }
    } catch (e) {
      debugPrint('Error loading saved projects: $e');
    }
  }

  Future<void> _saveProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _allProjects.map((p) => p.toMap()).toList();
      await prefs.setString('robotto_user_projects', jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving projects: $e');
    }
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
        final matchesUser = (p.userId == _currentUserId) || p.isJoined;
        // 'Terminés' pill maps to 'Terminé' in the model
        final statusFilter =
            _selectedStatus == 'Terminés' ? 'Terminé' : _selectedStatus;
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
            _saveProjects();
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
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.surfaceHigh),
          ),
          title: Row(
            children: [
              Icon(
                isJoining ? Icons.group_add_rounded : Icons.logout_rounded,
                color: isJoining ? AppTheme.accent : Colors.amber,
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
              color: AppTheme.textSoft,
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
                  color: AppTheme.textDisabled,
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
                    isJoining ? AppTheme.accent : Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isJoining ? 'Rejoindre' : 'Quitter',
                style: GoogleFonts.poppins(
                  color: isJoining ? AppTheme.bg : Colors.white,
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
            id: 'user_$_currentUserId',
            name: 'Vous',
            role: 'Contributeur',
          ),
        );
      });
      _saveProjects();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vous participez maintenant au projet "${project.title}" !',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      AudioHelper.playClickSound();
      setState(() {
        project.isJoined = false;
        project.members.removeWhere(
            (m) => m.id == 'user_$_currentUserId' || m.name == 'Vous');
      });
      _saveProjects();

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
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─── EDIT / UPDATE PROJECT ────────────────────────────────────────────────────

  void _openEditProjectScreen(Project project) {
    AudioHelper.playClickSound();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(
          existingProject: project,
          onProjectCreated: (_) {},
          onProjectUpdated: (updated) {
            setState(() {});
            _saveProjects();
          },
        ),
      ),
    );
  }

  // ─── DELETE PROJECT ──────────────────────────────────────────────────────────

  void _confirmDeleteProject(Project project) {
    AudioHelper.playClickSound();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.surfaceHigh),
          ),
          title: Row(
            children: [
              const Icon(Icons.delete_forever_rounded,
                  color: Colors.redAccent, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Supprimer le projet ?',
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
            'Le projet "${project.title}" sera définitivement supprimé avec toutes ses tâches, fichiers et membres. Cette action est irréversible.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSoft,
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
                  color: AppTheme.textDisabled,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProject(project);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Supprimer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProject(Project project) {
    setState(() {
      _allProjects.removeWhere((p) => p.id == project.id);
    });
    _saveProjects();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Projet "${project.title}" supprimé.',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProjects = _allProjects
        .where((p) => p.userId == _currentUserId || p.isJoined)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accent,
                      ),
                    )
                  : FadeTransition(
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
                                          color: AppTheme.accent,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accent
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
                                              color: AppTheme.accent,
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
                                    color: AppTheme.textDisabled,
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppTheme.accent,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                        color: AppTheme.surfaceHigh),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                        color: AppTheme.surfaceHigh),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                      color: AppTheme.accent,
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
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: AppTheme.surfaceHigh),
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
                                          color: AppTheme.textSoft,
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
                                      color: AppTheme.accent,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accent
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
                                          color: AppTheme.bg,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Nouveau',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.bg,
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
                                    iconColor: AppTheme.accent,
                                    value:
                                        '${userProjects.where((p) => p.status == 'En cours').length}',
                                    label: 'En cours',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatCard(
                                    icon: Icons.check_circle_outline_rounded,
                                    iconColor: AppTheme.accent,
                                    value:
                                        '${userProjects.where((p) => p.status == 'Terminé').length}',
                                    label: 'Terminés',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatCard(
                                    icon: Icons.pause_circle_outline_rounded,
                                    iconColor: Colors.amber,
                                    value:
                                        '${userProjects.where((p) => p.status == 'En pause').length}',
                                    label: 'En pause',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatCard(
                                    icon: Icons.people_outline_rounded,
                                    iconColor: const Color(0xFF3B82F6),
                                    value:
                                        '${userProjects.expand((p) => p.members).length}',
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
                                    final isSelected =
                                        _selectedCategory == cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(cat),
                                        selected: isSelected,
                                        onSelected: (val) {
                                          AudioHelper.playClickSound();
                                          setState(
                                              () => _selectedCategory = cat);
                                        },
                                        selectedColor: AppTheme.accent,
                                        backgroundColor: AppTheme.surface,
                                        labelStyle: GoogleFonts.poppins(
                                          color: isSelected
                                              ? AppTheme.bg
                                              : Colors.white70,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 11.5,
                                        ),
                                        side: BorderSide(
                                          color: isSelected
                                              ? AppTheme.accent
                                              : AppTheme.surfaceHigh,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 50),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.folder_open_rounded,
                                        size: 52,
                                        color: AppTheme.textDisabled,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Aucun projet trouvé',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme.textSoft,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Cliquez sur "+ Nouveau" pour créer votre projet.',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme.textDisabled,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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

                            const SizedBox(height: 120),
                          ],
                        ),
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
            color: isSelected ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.bg : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.bg : Colors.white70,
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
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.surfaceHigh,
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
                color: AppTheme.textSoft,
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
            color: isSelected ? AppTheme.accent : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.surfaceHigh,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.bg : Colors.white70,
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
      statusBg = AppTheme.accent;
      statusText = AppTheme.bg;
    } else if (project.status == 'En pause') {
      statusBg = const Color(0xFFF59E0B);
      statusText = AppTheme.bg;
    } else {
      statusBg = const Color(0xFF0284C7);
      statusText = Colors.white;
    }

    final isOwner = project.userId == _currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceHigh),
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
            ).then((result) {
              if (result == 'deleted') {
                _deleteProject(project);
              } else {
                setState(() {});
                _saveProjects();
              }
            });
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
                        color: AppTheme.bg,
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
                              // Edit / Delete menu (if owner or in "Mes projets")
                              if (isOwner || _activeMainTab == 'Mes projets') ...[
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: AppTheme.textSoft,
                                  ),
                                  color: AppTheme.surface,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onSelected: (action) {
                                    if (action == 'edit') {
                                      _openEditProjectScreen(project);
                                    } else if (action == 'delete') {
                                      _confirmDeleteProject(project);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit_rounded,
                                              size: 16,
                                              color: AppTheme.accent),
                                          const SizedBox(width: 10),
                                          Text('Modifier',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 16,
                                              color: Colors.redAccent),
                                          const SizedBox(width: 10),
                                          Text('Supprimer',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),

                          Text(
                            project.category,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: AppTheme.textSoft,
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
                                    backgroundColor: AppTheme.surfaceHigh,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppTheme.accent,
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
                          color: AppTheme.textSoft,
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

                    // "Participer" Button for Public Projects not owned
                    if (project.visibility == 'Public' && !isOwner) ...[
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
                                  ? AppTheme.accent
                                      .withValues(alpha: 0.2)
                                  : AppTheme.accent,
                              borderRadius: BorderRadius.circular(14),
                              border: project.isJoined
                                  ? Border.all(color: AppTheme.accent)
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
                                      ? AppTheme.accent
                                      : AppTheme.bg,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  project.isJoined ? 'Participé' : 'Participer',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: project.isJoined
                                        ? AppTheme.accent
                                        : AppTheme.bg,
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
                            color: AppTheme.textSoft,
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
    if (project.category.contains('mobile') ||
        project.category.contains('Robot')) {
      icon = Icons.smart_toy_rounded;
    } else if (project.category.contains('IoT') ||
        project.category.contains('Domotique')) {
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
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 38,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}
