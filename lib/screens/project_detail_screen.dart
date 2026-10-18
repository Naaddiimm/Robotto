import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../widgets/background_waves.dart';
import '../widgets/animated_button.dart';
import '../utils/audio_helper.dart';

class KanbanItem {
  final String id;
  String title;
  String priority; // 'Haute priorité', 'Moyenne priorité', 'Basse priorité'
  Color priorityColor;
  String date;
  String status; // 'todo' | 'doing' | 'done'
  String assignee;
  String meetingInfo;
  String usefulLinks;
  String attachedFileName;

  KanbanItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.priorityColor,
    required this.date,
    required this.status,
    this.assignee = 'Alex Rivera',
    this.meetingInfo = 'Google Meet • Lundi 15:00',
    this.usefulLinks = 'https://docs.ros.org',
    this.attachedFileName = 'schema_circuit_v1.pdf',
  });
}

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _taskViewMode = 'Kanban'; // Liste or Kanban
  final TextEditingController _newTaskTitleController =
      TextEditingController();

  final List<KanbanItem> _kanbanTasks = [
    // À faire
    KanbanItem(
      id: 'k1',
      title: 'Assembler le châssis',
      priority: 'Haute priorité',
      priorityColor: Colors.pinkAccent,
      date: '18 oct.',
      status: 'todo',
      assignee: 'Sami B.',
      meetingInfo: 'Google Meet • Mardi 10:00',
      usefulLinks: 'https://tinkercad.com/things/chassis',
      attachedFileName: 'chassis_3d_v2.stl',
    ),
    KanbanItem(
      id: 'k2',
      title: 'Installer les roues',
      priority: 'Moyenne priorité',
      priorityColor: Colors.amber,
      date: '20 oct.',
      status: 'todo',
      assignee: 'Youssef K.',
    ),
    KanbanItem(
      id: 'k3',
      title: 'Configurer la caméra',
      priority: 'Basse priorité',
      priorityColor: Colors.tealAccent,
      date: '22 oct.',
      status: 'todo',
      assignee: 'Alex Rivera',
    ),
    KanbanItem(
      id: 'k4',
      title: 'Lire la documentation ROS 2',
      priority: 'Moyenne priorité',
      priorityColor: Colors.amber,
      date: '25 oct.',
      status: 'todo',
      assignee: 'Vous',
    ),
    KanbanItem(
      id: 'k5',
      title: 'Préparer la présentation',
      priority: 'Basse priorité',
      priorityColor: Colors.tealAccent,
      date: '28 oct.',
      status: 'todo',
      assignee: 'Ines H.',
    ),

    // En cours
    KanbanItem(
      id: 'k6',
      title: 'Configurer ESP32',
      priority: 'Haute priorité',
      priorityColor: Colors.pinkAccent,
      date: '16 oct.',
      status: 'doing',
      assignee: 'Alex Rivera',
      meetingInfo: 'Zoom • Jeudi 14:30',
      usefulLinks: 'https://github.com/robotto/esp32-code',
      attachedFileName: 'esp32_pinout.png',
    ),
    KanbanItem(
      id: 'k7',
      title: 'Tester les capteurs',
      priority: 'Moyenne priorité',
      priorityColor: Colors.amber,
      date: '19 oct.',
      status: 'doing',
      assignee: 'Youssef K.',
    ),
    KanbanItem(
      id: 'k8',
      title: 'Développer la navigation',
      priority: 'Basse priorité',
      priorityColor: Colors.tealAccent,
      date: '24 oct.',
      status: 'doing',
      assignee: 'Sami B.',
    ),

    // Terminées
    KanbanItem(
      id: 'k9',
      title: 'Installation Arduino IDE',
      priority: 'Basse priorité',
      priorityColor: const Color(0xFF00F5C4),
      date: '10 oct.',
      status: 'done',
    ),
    KanbanItem(
      id: 'k10',
      title: 'Schéma électrique',
      priority: 'Basse priorité',
      priorityColor: const Color(0xFF00F5C4),
      date: '12 oct.',
      status: 'done',
    ),
    KanbanItem(
      id: 'k11',
      title: 'Lecture des données capteurs',
      priority: 'Basse priorité',
      priorityColor: const Color(0xFF00F5C4),
      date: '14 oct.',
      status: 'done',
    ),
    KanbanItem(
      id: 'k12',
      title: 'Structure du projet',
      priority: 'Basse priorité',
      priorityColor: const Color(0xFF00F5C4),
      date: '16 oct.',
      status: 'done',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newTaskTitleController.dispose();
    super.dispose();
  }

  void _showTaskDetailsModal(KanbanItem item) {
    AudioHelper.playClickSound();

    final titleCtrl = TextEditingController(text: item.title);
    final assigneeCtrl = TextEditingController(text: item.assignee);
    final dateCtrl = TextEditingController(text: item.date);
    final meetingCtrl = TextEditingController(text: item.meetingInfo);
    final linksCtrl = TextEditingController(text: item.usefulLinks);
    final fileCtrl = TextEditingController(text: item.attachedFileName);
    String selectedPriority = item.priority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.task_alt_rounded,
                                color: Color(0xFF00F5C4), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Détails de la tâche',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF94A3B8)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Task Title
                    TextField(
                      controller: titleCtrl,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Titre de la tâche',
                        labelStyle:
                            GoogleFonts.poppins(color: const Color(0xFF00F5C4)),
                        filled: true,
                        fillColor: const Color(0xFF090D16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2942)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 1. Assigner à
                    _buildModalTextField(
                      controller: assigneeCtrl,
                      label: '👤 Assigner à',
                      hint: 'ex: Alex Rivera',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    // 2. Priorité
                    Text(
                      '🚨 Priorité',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        'Haute priorité',
                        'Moyenne priorité',
                        'Basse priorité'
                      ].map((prio) {
                        final isSel = selectedPriority == prio;
                        Color pColor = Colors.pinkAccent;
                        if (prio == 'Moyenne priorité') pColor = Colors.amber;
                        if (prio == 'Basse priorité') pColor = Colors.tealAccent;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ChoiceChip(
                              label: Text(
                                prio.split(' ')[0],
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSel
                                      ? const Color(0xFF090D16)
                                      : Colors.white70,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: pColor,
                              backgroundColor: const Color(0xFF090D16),
                              onSelected: (val) {
                                AudioHelper.playClickSound();
                                setModalState(() {
                                  selectedPriority = prio;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // 3. Date limite
                    _buildModalTextField(
                      controller: dateCtrl,
                      label: '📅 Date limite',
                      hint: 'ex: 25 oct. 2025',
                      icon: Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: 14),

                    // 4. Date de réunion / meet
                    _buildModalTextField(
                      controller: meetingCtrl,
                      label: '📹 Date de réunion / Meet',
                      hint: 'ex: Google Meet • Lundi 15:00',
                      icon: Icons.video_camera_front_rounded,
                    ),
                    const SizedBox(height: 14),

                    // 5. Liens utiles
                    _buildModalTextField(
                      controller: linksCtrl,
                      label: '🔗 Liens utiles',
                      hint: 'ex: https://github.com/robotto/repo',
                      icon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 14),

                    // 6. Fichier / Pièce jointe avec bouton Téléverser
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '📎 Fichier / Pièce jointe',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                AudioHelper.playClickSound();
                                try {
                                  final result =
                                      await FilePicker.platform.pickFiles();
                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    AudioHelper.playSuccessSound();
                                    fileCtrl.text = result.files.single.name;
                                    setModalState(() {});
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Fichier "${result.files.single.name}" sélectionné !',
                                          ),
                                          backgroundColor:
                                              const Color(0xFF00F5C4),
                                        ),
                                      );
                                    }
                                  }
                                } catch (_) {}
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00F5C4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.upload_file_rounded,
                                      size: 14,
                                      color: Color(0xFF090D16),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Téléverser',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
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
                        const SizedBox(height: 5),
                        TextField(
                          controller: fileCtrl,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'ex: chassis_3d_v2.stl',
                            hintStyle: GoogleFonts.poppins(
                                color: const Color(0xFF64748B), fontSize: 12),
                            prefixIcon: const Icon(Icons.attach_file_rounded,
                                color: Color(0xFF00F5C4), size: 18),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.folder_open_rounded,
                                  color: Color(0xFF00F5C4)),
                              onPressed: () async {
                                AudioHelper.playClickSound();
                                try {
                                  final result =
                                      await FilePicker.platform.pickFiles();
                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    AudioHelper.playSuccessSound();
                                    fileCtrl.text = result.files.single.name;
                                    setModalState(() {});
                                  }
                                } catch (_) {}
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFF090D16),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFF1E2942)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Save Button
                    AnimatedButton(
                      isPrimary: true,
                      onPressed: () {
                        AudioHelper.playSuccessSound();
                        setState(() {
                          item.title = titleCtrl.text.trim();
                          item.assignee = assigneeCtrl.text.trim();
                          item.priority = selectedPriority;
                          if (selectedPriority == 'Haute priorité') {
                            item.priorityColor = Colors.pinkAccent;
                          } else if (selectedPriority == 'Moyenne priorité') {
                            item.priorityColor = Colors.amber;
                          } else {
                            item.priorityColor = Colors.tealAccent;
                          }
                          item.date = dateCtrl.text.trim();
                          item.meetingInfo = meetingCtrl.text.trim();
                          item.usefulLinks = linksCtrl.text.trim();
                          item.attachedFileName = fileCtrl.text.trim();
                        });
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tâche mise à jour avec succès !'),
                            backgroundColor: Color(0xFF00F5C4),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F5C4),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            'Enregistrer les modifications',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF090D16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 12),
            prefixIcon: Icon(icon, color: const Color(0xFF00F5C4), size: 18),
            filled: true,
            fillColor: const Color(0xFF090D16),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E2942)),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter une tâche',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newTaskTitleController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Titre de la tâche...',
                  hintStyle:
                      GoogleFonts.poppins(color: const Color(0xFF64748B)),
                  prefixIcon:
                      const Icon(Icons.task_alt_rounded, color: Color(0xFF00F5C4)),
                  filled: true,
                  fillColor: const Color(0xFF090D16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E2942)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                isPrimary: true,
                onPressed: () {
                  if (_newTaskTitleController.text.isNotEmpty) {
                    AudioHelper.playSuccessSound();
                    setState(() {
                      _kanbanTasks.add(
                        KanbanItem(
                          id: 'k_${DateTime.now().millisecondsSinceEpoch}',
                          title: _newTaskTitleController.text.trim(),
                          priority: 'Haute priorité',
                          priorityColor: Colors.pinkAccent,
                          date: 'Aujourd\'hui',
                          status: 'todo',
                        ),
                      );
                    });
                    _newTaskTitleController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5C4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      'Ajouter la Tâche',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF090D16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _moveTask(KanbanItem item, String newStatus) {
    if (item.status == newStatus) return;

    AudioHelper.playSuccessSound();
    setState(() {
      item.status = newStatus;
    });

    String statusLabel = 'À faire';
    if (newStatus == 'doing') statusLabel = 'En cours';
    if (newStatus == 'done') statusLabel = 'Terminées';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Color(0xFF00F5C4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tâche "${item.title}" déplacée vers "$statusLabel"',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF131B2C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            AudioHelper.playClickSound();
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.project.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () {
              AudioHelper.playClickSound();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF00F5C4),
        child: const Icon(Icons.add_rounded, color: Color(0xFF090D16), size: 28),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top TabBar
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF00F5C4),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF00F5C4),
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.normal),
                  tabs: const [
                    Tab(text: 'Vue d\'ensemble'),
                    Tab(text: 'Tâches'),
                    Tab(text: 'Équipe'),
                    Tab(text: 'Fichiers'),
                  ],
                ),

                // Main Content Body
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Vue d'ensemble
                      _buildOverviewTab(),

                      // Tab 2: Tâches & Kanban Drag and Drop
                      _buildTasksKanbanTab(),

                      // Tab 3: Équipe
                      _buildTeamTab(),

                      // Tab 4: Fichiers
                      _buildFilesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final progress = widget.project.progressPercentage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner Image Box
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  color: const Color(0xFF131B2C),
                  child: (widget.project.imagePath != null &&
                          widget.project.imagePath!.isNotEmpty)
                      ? (kIsWeb
                          ? Image.network(
                              widget.project.imagePath!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  _buildHeroPlaceholder(),
                            )
                          : Image.file(
                              File(widget.project.imagePath!),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  _buildHeroPlaceholder(),
                            ))
                      : _buildHeroPlaceholder(),
                ),
              ),

              // Status Badge top right
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5C4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.project.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF090D16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.project.title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Category Subtitle
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined,
                  color: Color(0xFF00F5C4), size: 16),
              const SizedBox(width: 6),
              Text(
                widget.project.category,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description Paragraph
          Text(
            widget.project.description,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: const Color(0xFFCBD5E1),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Progression Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression globale',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : 0.65,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E293B),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF00F5C4)),
            ),
          ),
          const SizedBox(height: 20),

          // Key Info Pillars Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2942)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  icon: Icons.groups_rounded,
                  title: '${widget.project.members.length}',
                  subtitle: 'membres',
                ),
                Container(width: 1, height: 30, color: const Color(0xFF1E2942)),
                _buildInfoColumn(
                  icon: Icons.calendar_today_rounded,
                  title: widget.project.dueDate,
                  subtitle: 'Date limite',
                ),
                Container(width: 1, height: 30, color: const Color(0xFF1E2942)),
                _buildInfoColumn(
                  icon: Icons.public_rounded,
                  title: widget.project.visibility,
                  subtitle: 'Visibilité',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Prochaines étapes Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prochaines étapes',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Voir tout',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00F5C4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildStepCard(
            stepNumber: '1',
            title: 'Conception mécanique',
            subtitle: '15 oct. 2025 · 2 tâches',
          ),
          _buildStepCard(
            stepNumber: '2',
            title: 'Montage électronique',
            subtitle: '25 oct. 2025 · 3 tâches',
          ),
          _buildStepCard(
            stepNumber: '3',
            title: 'Programmation & tests',
            subtitle: '10 nov. 2025 · 4 tâches',
          ),
        ],
      ),
    );
  }

  Widget _buildTasksKanbanTab() {
    final todoTasks = _kanbanTasks.where((t) => t.status == 'todo').toList();
    final doingTasks = _kanbanTasks.where((t) => t.status == 'doing').toList();
    final doneTasks = _kanbanTasks.where((t) => t.status == 'done').toList();

    return Column(
      children: [
        const SizedBox(height: 12),

        // Mode Switcher (Liste vs Kanban)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E2942)),
                  ),
                  child: Row(
                    children: [
                      _buildTaskModeButton('Liste'),
                      _buildTaskModeButton('Kanban'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Interactive Drag and Drop Kanban Columns
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: À faire (todo)
                _buildKanbanDragTargetColumn(
                  columnStatus: 'todo',
                  title: 'À faire',
                  count: todoTasks.length,
                  titleColor: Colors.white,
                  items: todoTasks,
                ),

                const SizedBox(width: 12),

                // Column 2: En cours (doing)
                _buildKanbanDragTargetColumn(
                  columnStatus: 'doing',
                  title: 'En cours',
                  count: doingTasks.length,
                  titleColor: const Color(0xFF00F5C4),
                  items: doingTasks,
                ),

                const SizedBox(width: 12),

                // Column 3: Terminées (done)
                _buildKanbanDragTargetColumn(
                  columnStatus: 'done',
                  title: 'Terminées',
                  count: doneTasks.length,
                  titleColor: const Color(0xFF00F5C4),
                  items: doneTasks,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskModeButton(String mode) {
    final isSelected = _taskViewMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioHelper.playClickSound();
          setState(() => _taskViewMode = mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00F5C4) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              mode,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected ? const Color(0xFF090D16) : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanDragTargetColumn({
    required String columnStatus,
    required String title,
    required int count,
    required Color titleColor,
    required List<KanbanItem> items,
  }) {
    return DragTarget<KanbanItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        _moveTask(details.data, columnStatus);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 195,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHovered
                ? const Color(0xFF00F5C4).withValues(alpha: 0.15)
                : const Color(0xFF131B2C).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? const Color(0xFF00F5C4)
                  : const Color(0xFF1E2942),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Header Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2942),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Draggable Cards List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildDraggableKanbanCard(item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableKanbanCard(KanbanItem item) {
    final cardWidget = GestureDetector(
      onTap: () {
        _showTaskDetailsModal(item);
      },
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E2942)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.status == 'done')
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check_circle_rounded,
                        size: 15, color: Color(0xFF00F5C4)),
                  ),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      size: 16, color: Color(0xFF94A3B8)),
                  color: const Color(0xFF131B2C),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (action) {
                    if (action == 'details') {
                      _showTaskDetailsModal(item);
                    } else {
                      _moveTask(item, action);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'details',
                      child: Text('⚙️ Voir / Modifier détails',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: const Color(0xFF00F5C4))),
                    ),
                    if (item.status != 'todo')
                      PopupMenuItem(
                        value: 'todo',
                        child: Text('Déplacer vers À faire',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ),
                    if (item.status != 'doing')
                      PopupMenuItem(
                        value: 'doing',
                        child: Text('Déplacer vers En cours',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ),
                    if (item.status != 'done')
                      PopupMenuItem(
                        value: 'done',
                        child: Text('Déplacer vers Terminées',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (item.status != 'done') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.priority,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: item.priorityColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(radius: 8, backgroundColor: Color(0xFF00F5C4)),
                    SizedBox(width: 2),
                    CircleAvatar(radius: 8, backgroundColor: Colors.amber),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 11, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text(
                      item.date,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Draggable<KanbanItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 175,
          child: Transform.rotate(
            angle: 0.04,
            child: cardWidget,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: cardWidget,
      ),
      child: cardWidget,
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2942)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF00F5C4),
            child: Text(
              stepNumber,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF090D16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00F5C4)),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      color: const Color(0xFF0E1626),
      child: const Center(
        child: Icon(
          Icons.smart_toy_rounded,
          size: 64,
          color: Color(0xFF00F5C4),
        ),
      ),
    );
  }

  Widget _buildTeamTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.project.members.length,
      itemBuilder: (context, index) {
        final m = widget.project.members[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF131B2C),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E2942)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF00F5C4).withValues(alpha: 0.2),
                child: Text(
                  m.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00F5C4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      m.role,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilesTab() {
    return Center(
      child: Text(
        'Aucun fichier partagé pour le moment',
        style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
      ),
    );
  }
}
