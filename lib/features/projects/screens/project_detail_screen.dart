import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';
import '../../../core/widgets/background_waves.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/utils/audio_helper.dart';

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
    this.attachedFileName = '',
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
  String _taskViewMode = 'Kanban'; // 'Liste' or 'Kanban'
  final TextEditingController _newTaskTitleController = TextEditingController();

  final List<KanbanItem> _kanbanTasks = [
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
    KanbanItem(
      id: 'k9',
      title: 'Installation Arduino IDE',
      priority: 'Basse priorité',
      priorityColor: AppTheme.accent,
      date: '10 oct.',
      status: 'done',
    ),
    KanbanItem(
      id: 'k10',
      title: 'Schéma électrique',
      priority: 'Basse priorité',
      priorityColor: AppTheme.accent,
      date: '12 oct.',
      status: 'done',
    ),
    KanbanItem(
      id: 'k11',
      title: 'Lecture des données capteurs',
      priority: 'Basse priorité',
      priorityColor: AppTheme.accent,
      date: '14 oct.',
      status: 'done',
    ),
    KanbanItem(
      id: 'k12',
      title: 'Structure du projet',
      priority: 'Basse priorité',
      priorityColor: AppTheme.accent,
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

  // ─── TASK DETAILS MODAL ──────────────────────────────────────────────────────

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
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.task_alt_rounded,
                            color: AppTheme.accent, size: 22),
                        const SizedBox(width: 8),
                        Text('Détails de la tâche',
                            style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ]),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.textSoft),
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
                      labelStyle: GoogleFonts.poppins(
                          color: AppTheme.accent),
                      filled: true,
                      fillColor: AppTheme.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF1E2942)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildModalTextField(
                    controller: assigneeCtrl,
                    label: '👤 Assigner à',
                    hint: 'ex: Alex Rivera',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),

                  Text('🚨 Priorité',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSoft)),
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
                            label: Center(
                              child: Text(prio.split(' ')[0],
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSel
                                          ? AppTheme.bg
                                          : Colors.white70)),
                            ),
                            selected: isSel,
                            selectedColor: pColor,
                            backgroundColor: AppTheme.bg,
                            onSelected: (_) {
                              AudioHelper.playClickSound();
                              setModalState(() => selectedPriority = prio);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  _buildModalTextField(
                    controller: dateCtrl,
                    label: '📅 Date limite',
                    hint: 'ex: 25 oct. 2025',
                    icon: Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 14),

                  _buildModalTextField(
                    controller: meetingCtrl,
                    label: '📹 Date de réunion / Meet',
                    hint: 'ex: Google Meet • Lundi 15:00',
                    icon: Icons.video_camera_front_rounded,
                  ),
                  const SizedBox(height: 14),

                  _buildModalTextField(
                    controller: linksCtrl,
                    label: '🔗 Liens utiles',
                    hint: 'ex: https://github.com/robotto/repo',
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 14),

                  // File attachment
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('📎 Fichier / Pièce jointe',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSoft)),
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
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Fichier "${result.files.single.name}" sélectionné !'),
                                      backgroundColor:
                                          AppTheme.accent,
                                    ));
                                  }
                                }
                              } catch (_) {}
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(children: [
                                const Icon(Icons.upload_file_rounded,
                                    size: 14, color: AppTheme.bg),
                                const SizedBox(width: 4),
                                Text('Téléverser',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.bg)),
                              ]),
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
                              color: AppTheme.textDisabled, fontSize: 12),
                          prefixIcon: const Icon(Icons.attach_file_rounded,
                              color: AppTheme.accent, size: 18),
                          filled: true,
                          fillColor: AppTheme.bg,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF1E2942)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  AnimatedButton(
                    isPrimary: true,
                    onPressed: () {
                      AudioHelper.playSuccessSound();
                      setState(() {
                        item.title = titleCtrl.text.trim();
                        item.assignee = assigneeCtrl.text.trim();
                        item.priority = selectedPriority;
                        item.priorityColor =
                            selectedPriority == 'Haute priorité'
                                ? Colors.pinkAccent
                                : selectedPriority == 'Moyenne priorité'
                                    ? Colors.amber
                                    : Colors.tealAccent;
                        item.date = dateCtrl.text.trim();
                        item.meetingInfo = meetingCtrl.text.trim();
                        item.usefulLinks = linksCtrl.text.trim();
                        item.attachedFileName = fileCtrl.text.trim();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Tâche mise à jour avec succès !'),
                        backgroundColor: AppTheme.accent,
                      ));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text('Enregistrer les modifications',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.bg)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSoft)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: AppTheme.textDisabled, fontSize: 12),
            prefixIcon:
                Icon(icon, color: AppTheme.accent, size: 18),
            filled: true,
            fillColor: AppTheme.bg,
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

  // ─── ADD TASK DIALOG ─────────────────────────────────────────────────────────

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
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
              Text('Ajouter une tâche',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: _newTaskTitleController,
                autofocus: true,
                style:
                    GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Titre de la tâche...',
                  hintStyle:
                      GoogleFonts.poppins(color: AppTheme.textDisabled),
                  prefixIcon: const Icon(Icons.task_alt_rounded,
                      color: AppTheme.accent),
                  filled: true,
                  fillColor: AppTheme.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF1E2942)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.accent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                isPrimary: true,
                onPressed: () {
                  final title = _newTaskTitleController.text.trim();
                  if (title.isNotEmpty) {
                    AudioHelper.playSuccessSound();
                    setState(() {
                      _kanbanTasks.add(KanbanItem(
                        id: 'k_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        priority: 'Haute priorité',
                        priorityColor: Colors.pinkAccent,
                        date: 'Aujourd\'hui',
                        status: 'todo',
                      ));
                    });
                    _newTaskTitleController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text('Ajouter la Tâche',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bg)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── MOVE TASK ────────────────────────────────────────────────────────────────

  void _moveTask(KanbanItem item, String newStatus) {
    if (item.status == newStatus) return;
    AudioHelper.playSuccessSound();
    setState(() => item.status = newStatus);
    final label = newStatus == 'todo'
        ? 'À faire'
        : newStatus == 'doing'
            ? 'En cours'
            : 'Terminées';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.swap_horiz_rounded, color: AppTheme.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Tâche "${item.title}" déplacée vers "$label"',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 12.5)),
          ),
        ]),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  // ─── DELETE TASK ──────────────────────────────────────────────────────────────

  void _deleteTask(KanbanItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceHigh),
        ),
        title: Text('Supprimer la tâche ?',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('La tâche "${item.title}" sera définitivement supprimée.',
            style: GoogleFonts.poppins(
                color: AppTheme.textSoft, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style: GoogleFonts.poppins(color: AppTheme.textDisabled)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _kanbanTasks.removeWhere((t) => t.id == item.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Tâche supprimée'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Supprimer',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── INVITE MEMBER DIALOG ─────────────────────────────────────────────────────

  void _showInviteMemberDialog() {
    AudioHelper.playClickSound();
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.person_add_rounded,
                    color: AppTheme.accent, size: 22),
                const SizedBox(width: 8),
                Text('Inviter un membre',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]),
              const SizedBox(height: 20),
              _buildModalTextField(
                controller: nameCtrl,
                label: '👤 Nom du membre',
                hint: 'ex: Youssef K.',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _buildModalTextField(
                controller: roleCtrl,
                label: '🛠️ Rôle dans le projet',
                hint: 'ex: Électronicien, Designer 3D...',
                icon: Icons.work_outline_rounded,
              ),
              const SizedBox(height: 22),
              AnimatedButton(
                isPrimary: true,
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final role = roleCtrl.text.trim();
                  if (name.isNotEmpty && role.isNotEmpty) {
                    AudioHelper.playSuccessSound();
                    setState(() {
                      widget.project.members.add(ProjectMember(
                        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        role: role,
                      ));
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('$name a rejoint l\'équipe !',
                          style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: AppTheme.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text('Inviter',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bg)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── CHANGE STATUS ────────────────────────────────────────────────────────────

  void _showChangeStatusDialog() {
    AudioHelper.playClickSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Changer le statut du projet',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              ...['En cours', 'En pause', 'Terminé'].map((s) {
                final isActive = widget.project.status == s;
                return ListTile(
                  leading: Icon(
                    isActive
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isActive
                        ? AppTheme.accent
                        : AppTheme.textDisabled,
                  ),
                  title: Text(s,
                      style: GoogleFonts.poppins(
                          color: isActive ? AppTheme.accent : Colors.white,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => widget.project.status = s);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ─── DELETE PROJECT ───────────────────────────────────────────────────────────

  void _confirmDeleteProject() {
    AudioHelper.playClickSound();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text('Supprimer le projet',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ]),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${widget.project.title}" ? Cette action est irréversible.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppTheme.textSoft)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, 'deleted');
            },
            child: Text('Supprimer',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── SCAFFOLD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            AudioHelper.playClickSound();
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.project.title,
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: AppTheme.surface,
            onSelected: (value) {
              if (value == 'status') _showChangeStatusDialog();
              if (value == 'delete') _confirmDeleteProject();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'status',
                child: Row(children: [
                  const Icon(Icons.swap_horiz_rounded,
                      size: 18, color: AppTheme.accent),
                  const SizedBox(width: 10),
                  Text('Changer le statut',
                      style:
                          GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
                ]),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text('Supprimer le projet',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.redAccent)),
                ]),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppTheme.accent,
        child: const Icon(Icons.add_rounded, color: AppTheme.bg, size: 28),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: BackgroundWavesPainter())),
          SafeArea(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.accent,
                  indicatorWeight: 3,
                  labelColor: AppTheme.accent,
                  unselectedLabelColor: AppTheme.textSoft,
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Vue d\'ensemble'),
                    Tab(text: 'Tâches'),
                    Tab(text: 'Équipe'),
                    Tab(text: 'Fichiers'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildTasksTab(),
                      _buildTeamTab(),
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

  // ─── TAB 1: VUE D'ENSEMBLE ────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    final progress = widget.project.progressPercentage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  color: AppTheme.surface,
                  child: (widget.project.imagePath != null &&
                          widget.project.imagePath!.isNotEmpty)
                      ? (kIsWeb
                          ? Image.network(widget.project.imagePath!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  _buildHeroPlaceholder())
                          : Image.file(File(widget.project.imagePath!),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  _buildHeroPlaceholder()))
                      : _buildHeroPlaceholder(),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: GestureDetector(
                  onTap: _showChangeStatusDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(widget.project.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.project.status,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.bg)),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_rounded,
                          size: 12, color: AppTheme.bg),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title & Category
          Text(widget.project.title,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.smart_toy_outlined,
                color: AppTheme.accent, size: 16),
            const SizedBox(width: 6),
            Text(widget.project.category,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSoft,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2942),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.project.level,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),

          // Description
          Text(widget.project.description,
              style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: AppTheme.text,
                  height: 1.45)),
          const SizedBox(height: 8),

          // Objectives
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1626),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.25)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.flag_outlined,
                  color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Objectifs',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent)),
                      const SizedBox(height: 2),
                      Text(widget.project.objectives,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.text,
                              height: 1.4)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Progress
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Progression globale',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppTheme.textSoft)),
            Text(
              progress > 0
                  ? '${(progress * 100).toInt()}%'
                  : '${widget.project.completedTasksCount}/${widget.project.tasks.length} tâches',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E293B),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            ),
          ),
          const SizedBox(height: 20),

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2942)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                    icon: Icons.groups_rounded,
                    title: '${widget.project.members.length}',
                    subtitle: 'membres'),
                Container(
                    width: 1, height: 30, color: const Color(0xFF1E2942)),
                _buildInfoColumn(
                    icon: Icons.calendar_today_rounded,
                    title: widget.project.dueDate,
                    subtitle: 'Échéance'),
                Container(
                    width: 1, height: 30, color: const Color(0xFF1E2942)),
                _buildInfoColumn(
                    icon: Icons.public_rounded,
                    title: widget.project.visibility,
                    subtitle: 'Visibilité'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Milestones / Prochaines étapes
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Jalons & Étapes',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(
              '${widget.project.reachedMilestonesCount}/${widget.project.milestones.isNotEmpty ? widget.project.milestones.length : 3} atteints',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accent),
            ),
          ]),
          const SizedBox(height: 12),

          // If milestones exist use them, otherwise show default steps
          if (widget.project.milestones.isNotEmpty)
            ...widget.project.milestones.asMap().entries.map((entry) {
              final i = entry.key;
              final ms = entry.value;
              return _buildMilestoneCard(
                stepNumber: '${i + 1}',
                title: ms.title,
                subtitle: ms.dueDate,
                isReached: ms.isReached,
                onTap: () {
                  setState(() => ms.isReached = !ms.isReached);
                },
              );
            })
          else ...[
            _buildMilestoneCard(
                stepNumber: '1',
                title: 'Conception mécanique',
                subtitle: '15 oct. 2025 · 2 tâches'),
            _buildMilestoneCard(
                stepNumber: '2',
                title: 'Montage électronique',
                subtitle: '25 oct. 2025 · 3 tâches'),
            _buildMilestoneCard(
                stepNumber: '3',
                title: 'Programmation & tests',
                subtitle: '10 nov. 2025 · 4 tâches'),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'En cours':
        return AppTheme.accent;
      case 'En pause':
        return const Color(0xFFF59E0B);
      case 'Terminé':
        return const Color(0xFF3B82F6);
      default:
        return AppTheme.accent;
    }
  }

  // ─── TAB 2: TÂCHES ────────────────────────────────────────────────────────────

  Widget _buildTasksTab() {
    final todoTasks = _kanbanTasks.where((t) => t.status == 'todo').toList();
    final doingTasks = _kanbanTasks.where((t) => t.status == 'doing').toList();
    final doneTasks = _kanbanTasks.where((t) => t.status == 'done').toList();

    return Column(
      children: [
        const SizedBox(height: 12),

        // Mode Switcher
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E2942)),
            ),
            child: Row(children: [
              _buildTaskModeButton('Liste'),
              _buildTaskModeButton('Kanban'),
            ]),
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: _taskViewMode == 'Kanban'
              ? _buildKanbanView(todoTasks, doingTasks, doneTasks)
              : _buildListView(),
        ),
      ],
    );
  }

  // Kanban drag-and-drop view
  Widget _buildKanbanView(
    List<KanbanItem> todoTasks,
    List<KanbanItem> doingTasks,
    List<KanbanItem> doneTasks,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanbanDragTargetColumn(
            columnStatus: 'todo',
            title: 'À faire',
            count: todoTasks.length,
            titleColor: Colors.white,
            items: todoTasks,
          ),
          const SizedBox(width: 12),
          _buildKanbanDragTargetColumn(
            columnStatus: 'doing',
            title: 'En cours',
            count: doingTasks.length,
            titleColor: AppTheme.accent,
            items: doingTasks,
          ),
          const SizedBox(width: 12),
          _buildKanbanDragTargetColumn(
            columnStatus: 'done',
            title: 'Terminées',
            count: doneTasks.length,
            titleColor: AppTheme.accent,
            items: doneTasks,
          ),
        ],
      ),
    );
  }

  // List view (flat, grouped by status)
  Widget _buildListView() {
    final groups = {
      'À faire': _kanbanTasks.where((t) => t.status == 'todo').toList(),
      'En cours': _kanbanTasks.where((t) => t.status == 'doing').toList(),
      'Terminées': _kanbanTasks.where((t) => t.status == 'done').toList(),
    };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: groups.entries.map((entry) {
        if (entry.value.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: entry.key == 'Terminées'
                        ? AppTheme.accent
                        : entry.key == 'En cours'
                            ? Colors.amber
                            : AppTheme.textDisabled,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(entry.key,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2942),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${entry.value.length}',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: Colors.white70)),
                ),
              ]),
            ),
            ...entry.value.map((item) => _buildListTaskTile(item)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildListTaskTile(KanbanItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2942)),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            AudioHelper.playSuccessSound();
            setState(() => item.status =
                item.status == 'done' ? 'todo' : 'done');
          },
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.status == 'done'
                  ? AppTheme.accent
                  : Colors.transparent,
              border: Border.all(
                color: item.status == 'done'
                    ? AppTheme.accent
                    : AppTheme.textDisabled,
                width: 2,
              ),
            ),
            child: item.status == 'done'
                ? const Icon(Icons.check_rounded,
                    size: 14, color: AppTheme.bg)
                : null,
          ),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: item.status == 'done'
                ? AppTheme.textDisabled
                : Colors.white,
            decoration: item.status == 'done'
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text(
          '${item.assignee} · ${item.date}',
          style:
              GoogleFonts.poppins(fontSize: 11, color: AppTheme.textDisabled),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: item.priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.priority.split(' ')[0],
                style: GoogleFonts.poppins(
                    fontSize: 9, color: item.priorityColor),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded,
                  size: 18, color: AppTheme.textDisabled),
              onPressed: () => _showTaskDetailsModal(item),
            ),
          ],
        ),
        onTap: () => _showTaskDetailsModal(item),
      ),
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
            color: isSelected ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(mode,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.bg
                        : AppTheme.textSoft)),
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
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => _moveTask(details.data, columnStatus),
      builder: (context, candidateData, _) {
        final isHovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 195,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHovered
                ? AppTheme.accent.withValues(alpha: 0.15)
                : AppTheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? AppTheme.accent
                  : const Color(0xFF1E2942),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: titleColor)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2942),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count',
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (_, index) =>
                      _buildDraggableKanbanCard(items[index]),
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
      onTap: () => _showTaskDetailsModal(item),
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.bg,
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
                        size: 15, color: AppTheme.accent),
                  ),
                Expanded(
                  child: Text(item.title,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      size: 16, color: AppTheme.textSoft),
                  color: AppTheme.surface,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (action) {
                    if (action == 'details') {
                      _showTaskDetailsModal(item);
                    } else if (action == 'delete') {
                      _deleteTask(item);
                    } else {
                      _moveTask(item, action);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'details',
                      child: Text('⚙️ Voir / Modifier',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.accent)),
                    ),
                    if (item.status != 'todo')
                      PopupMenuItem(
                        value: 'todo',
                        child: Text('→ À faire',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ),
                    if (item.status != 'doing')
                      PopupMenuItem(
                        value: 'doing',
                        child: Text('→ En cours',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ),
                    if (item.status != 'done')
                      PopupMenuItem(
                        value: 'done',
                        child: Text('→ Terminées',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('🗑️ Supprimer',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.status != 'done') ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.priority,
                    style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: item.priorityColor)),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: AppTheme.accent,
                    child: Text(
                      item.assignee.isNotEmpty
                          ? item.assignee[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bg),
                    ),
                  ),
                ]),
                Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 11, color: AppTheme.textSoft),
                  const SizedBox(width: 3),
                  Text(item.date,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppTheme.textSoft)),
                ]),
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
          child: Transform.rotate(angle: 0.04, child: cardWidget),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: cardWidget),
      child: cardWidget,
    );
  }

  // ─── TAB 3: ÉQUIPE ────────────────────────────────────────────────────────────

  Widget _buildTeamTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.project.members.length} membres',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              AnimatedButton(
                isPrimary: true,
                onPressed: _showInviteMemberDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.person_add_rounded,
                        size: 14, color: AppTheme.bg),
                    const SizedBox(width: 4),
                    Text('Inviter',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bg)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.project.members.length,
            itemBuilder: (context, index) {
              final m = widget.project.members[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E2942)),
                ),
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor:
                        AppTheme.accent.withValues(alpha: 0.2),
                    child: Text(
                      m.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(m.role,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSoft)),
                      ],
                    ),
                  ),
                  if (m.id != 'user_me')
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          size: 18, color: AppTheme.textDisabled),
                      color: AppTheme.surface,
                      onSelected: (action) {
                        if (action == 'remove') {
                          setState(() => widget.project.members
                              .removeWhere((mem) => mem.id == m.id));
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'remove',
                          child: Text('Retirer du projet',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.redAccent)),
                        ),
                      ],
                    ),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── TAB 4: FICHIERS ──────────────────────────────────────────────────────────

  Widget _buildFilesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.project.files.length} fichier(s) partagé(s)',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              GestureDetector(
                onTap: () async {
                  AudioHelper.playClickSound();
                  try {
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.isNotEmpty) {
                      AudioHelper.playSuccessSound();
                      setState(() {
                        widget.project.files.add(ProjectFile(
                          id:
                              'f_${DateTime.now().millisecondsSinceEpoch}',
                          name: result.files.single.name,
                          type: _getFileType(result.files.single.name),
                          uploadedBy: 'Vous',
                          uploadedAt: _formatDate(DateTime.now()),
                          path: result.files.single.path,
                        ));
                      });
                    }
                  } catch (_) {}
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.upload_rounded,
                        size: 14, color: AppTheme.bg),
                    const SizedBox(width: 4),
                    Text('Partager',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bg)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.project.files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open_rounded,
                          size: 56, color: Color(0xFF1E2942)),
                      const SizedBox(height: 12),
                      Text('Aucun fichier partagé pour le moment',
                          style: GoogleFonts.poppins(
                              color: AppTheme.textSoft, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('Appuyez sur "Partager" pour ajouter un fichier.',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF4B5563),
                              fontSize: 11)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.project.files.length,
                  itemBuilder: (context, index) {
                    final f = widget.project.files[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E2942)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _fileTypeColor(f.type)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_fileTypeIcon(f.type),
                              color: _fileTypeColor(f.type), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(
                                'Par ${f.uploadedBy} · ${f.uploadedAt}',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textDisabled),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppTheme.textDisabled),
                          onPressed: () {
                            setState(() => widget.project.files
                                .removeWhere((file) => file.id == f.id));
                          },
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  String _getFileType(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (ext == 'pdf') return 'pdf';
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'].contains(ext)) {
      return 'image';
    }
    if (['dart', 'py', 'js', 'ts', 'cpp', 'c', 'h', 'ino', 'json', 'yaml']
        .contains(ext)) {
      return 'code';
    }
    return 'other';
  }

  IconData _fileTypeIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'code':
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _fileTypeColor(String type) {
    switch (type) {
      case 'pdf':
        return Colors.redAccent;
      case 'image':
        return Colors.purpleAccent;
      case 'code':
        return AppTheme.accent;
      default:
        return Colors.blueAccent;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildMilestoneCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    bool isReached = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isReached
                ? AppTheme.accent.withValues(alpha: 0.5)
                : const Color(0xFF1E2942),
          ),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isReached
                ? AppTheme.accent
                : const Color(0xFF1E2942),
            child: isReached
                ? const Icon(Icons.check_rounded,
                    size: 16, color: AppTheme.bg)
                : Text(stepNumber,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isReached
                            ? AppTheme.textDisabled
                            : Colors.white,
                        decoration: isReached
                            ? TextDecoration.lineThrough
                            : null)),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppTheme.textSoft)),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.touch_app_rounded,
                size: 16, color: Color(0xFF4B5563)),
        ]),
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: AppTheme.accent),
        const SizedBox(width: 4),
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ]),
      Text(subtitle,
          style: GoogleFonts.poppins(
              fontSize: 10, color: AppTheme.textSoft)),
    ]);
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      color: const Color(0xFF0E1626),
      child: const Center(
        child: Icon(Icons.smart_toy_rounded,
            size: 64, color: AppTheme.accent),
      ),
    );
  }
}
