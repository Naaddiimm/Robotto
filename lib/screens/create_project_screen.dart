import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/project.dart';
import '../widgets/background_waves.dart';
import '../widgets/animated_button.dart';
import '../utils/audio_helper.dart';

class CreateProjectScreen extends StatefulWidget {
  final Function(Project) onProjectCreated;

  const CreateProjectScreen({
    super.key,
    required this.onProjectCreated,
  });

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _customCategoryController = TextEditingController();

  XFile? _selectedImage;
  String _selectedLevel = 'Intermédiaire';
  String _selectedCategory = 'Bras Robotique';
  String _selectedVisibility = 'Public';

  static const List<String> levels = ['Débutant', 'Intermédiaire', 'Avancé'];
  static const List<String> categories = [
    'Bras Robotique',
    'Suiveur de Ligne',
    'Drone',
    'IoT & Domotique',
    'Bipède & Humanoïde',
    'Automatisme',
    'Autre',
  ];
  static const List<String> visibilities = ['Privé', 'Équipe', 'Public'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        AudioHelper.playClickSound();
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir la galerie/appareil photo'),
          ),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    AudioHelper.playClickSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131B2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ajouter une image du projet',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFF00F5C4)),
                title: Text('Galerie de photos',
                    style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFF00F5C4)),
                title: Text('Prendre une photo',
                    style: GoogleFonts.poppins(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getVisibilityDescription(String visibility) {
    switch (visibility) {
      case 'Privé':
        return 'Visible uniquement par vous. Idéal pour vos brouillons et projets confidentiels.';
      case 'Équipe':
        return 'Accessible uniquement par vous et les membres invités de votre équipe.';
      case 'Public':
        return 'Visible par toute la communauté Robotto. Idéal pour collaborer et partager en Open-Source.';
      default:
        return '';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      AudioHelper.playSuccessSound();

      final finalCategory = _selectedCategory == 'Autre'
          ? (_customCategoryController.text.trim().isEmpty
              ? 'Autre'
              : _customCategoryController.text.trim())
          : _selectedCategory;

      final newProject = Project(
        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        objectives: _objectivesController.text.trim(),
        level: _selectedLevel,
        category: finalCategory,
        visibility: _selectedVisibility,
        imagePath: _selectedImage?.path,
        members: [
          ProjectMember(
            id: 'm1',
            name: 'Vous (Chef de Projet)',
            role: 'Lead Robotics Engineer',
          ),
        ],
        tasks: [
          ProjectTask(
            id: 't1',
            title: 'Analyse des besoins et composants',
            isCompleted: true,
            dueDate: '15 Mars 2025',
            assigneeName: 'Vous',
          ),
          ProjectTask(
            id: 't2',
            title: 'Conception du schéma électronique',
            isCompleted: false,
            dueDate: '22 Mars 2025',
            assigneeName: 'Vous',
          ),
        ],
        milestones: [
          ProjectMilestone(
            id: 'm1',
            title: 'Validation du prototype Alpha',
            dueDate: '30 Mars 2025',
            isReached: false,
          ),
        ],
      );

      widget.onProjectCreated(newProject);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF00F5C4)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Projet "${newProject.title}" créé avec succès !',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF131B2C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context);
    }
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
          'Créer un Projet',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    _buildSectionTitle('Image ou Illustration du projet'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00F5C4).withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 38,
                                    color: Color(0xFF00F5C4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ajouter une image (Galerie / Caméra)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: kIsWeb
                                        ? Image.network(
                                            _selectedImage!.path,
                                            width: double.infinity,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_selectedImage!.path),
                                            width: double.infinity,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        AudioHelper.playClickSound();
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title Input
                    _buildTextField(
                      controller: _titleController,
                      label: 'Titre du projet',
                      hint: 'ex: Robot Suiveur de Ligne Autonome V2',
                      icon: Icons.title_rounded,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Titre requis' : null,
                    ),
                    const SizedBox(height: 18),

                    // Description Input
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description du projet',
                      hint:
                          'Expliquez en quelques lignes le concept de votre robot...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Description requise' : null,
                    ),
                    const SizedBox(height: 18),

                    // Objectives Input
                    _buildTextField(
                      controller: _objectivesController,
                      label: 'Objectifs principaux',
                      hint:
                          'ex: Résoudre un parcours en moins de 30s, intégration caméra...',
                      icon: Icons.flag_outlined,
                      maxLines: 2,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Objectifs requis' : null,
                    ),
                    const SizedBox(height: 22),

                    // Category Selector
                    _buildSectionTitle('Catégorie de la robotique'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            AudioHelper.playClickSound();
                            setState(() => _selectedCategory = cat);
                          },
                          selectedColor: const Color(0xFF00F5C4),
                          backgroundColor: const Color(0xFF131B2C),
                          labelStyle: GoogleFonts.poppins(
                            color: isSelected
                                ? const Color(0xFF090D16)
                                : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF00F5C4)
                                : const Color(0xFF1E2942),
                          ),
                        );
                      }).toList(),
                    ),

                    // Custom Category Field if "Autre" is selected
                    if (_selectedCategory == 'Autre') ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _customCategoryController,
                        label: 'Saisissez votre catégorie personnalisée',
                        hint: 'ex: Sous-marin, Exo-squelette, Prothèse...',
                        icon: Icons.category_rounded,
                        validator: (v) => _selectedCategory == 'Autre' &&
                                (v == null || v.isEmpty)
                            ? 'Veuillez préciser la catégorie'
                            : null,
                      ),
                    ],

                    const SizedBox(height: 22),

                    // Level Selector
                    _buildSectionTitle('Niveau de difficulté'),
                    const SizedBox(height: 8),
                    Row(
                      children: levels.map((lvl) {
                        final isSelected = lvl == _selectedLevel;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Center(child: Text(lvl)),
                              selected: isSelected,
                              onSelected: (selected) {
                                AudioHelper.playClickSound();
                                setState(() => _selectedLevel = lvl);
                              },
                              selectedColor: const Color(0xFF00F5C4),
                              backgroundColor: const Color(0xFF131B2C),
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
                                    : const Color(0xFF1E2942),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),

                    // Visibility Selector
                    _buildSectionTitle('Visibilité du projet'),
                    const SizedBox(height: 8),
                    Row(
                      children: visibilities.map((vis) {
                        final isSelected = vis == _selectedVisibility;
                        IconData icon;
                        if (vis == 'Privé') {
                          icon = Icons.lock_outline_rounded;
                        } else if (vis == 'Équipe') {
                          icon = Icons.group_outlined;
                        } else {
                          icon = Icons.public_rounded;
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              avatar: Icon(
                                icon,
                                size: 16,
                                color: isSelected
                                    ? const Color(0xFF090D16)
                                    : const Color(0xFF00F5C4),
                              ),
                              label: Center(child: Text(vis)),
                              selected: isSelected,
                              onSelected: (selected) {
                                AudioHelper.playClickSound();
                                setState(() => _selectedVisibility = vis);
                              },
                              selectedColor: const Color(0xFF00F5C4),
                              backgroundColor: const Color(0xFF131B2C),
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
                                    : const Color(0xFF1E2942),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Explanation Box below Visibility Options
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00F5C4).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedVisibility == 'Privé'
                                ? Icons.lock_outline_rounded
                                : _selectedVisibility == 'Équipe'
                                    ? Icons.group_outlined
                                    : Icons.public_rounded,
                            color: const Color(0xFF00F5C4),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _getVisibilityDescription(_selectedVisibility),
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: const Color(0xFFCBD5E1),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    AnimatedButton(
                      isPrimary: true,
                      onPressed: _submitForm,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF20EAA8), Color(0xFF00F5C4)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F5C4)
                                  .withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Créer le Projet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF090D16),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF64748B), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF00F5C4), size: 20),
            filled: true,
            fillColor: const Color(0xFF131B2C),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E2942)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E2942)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00F5C4), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
