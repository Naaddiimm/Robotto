import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';

class _ModuleDraft {
  final TextEditingController title;
  final List<_LessonDraft> lessons;

  _ModuleDraft({required String titleText, required this.lessons})
      : title = TextEditingController(text: titleText);

  void dispose() {
    title.dispose();
    for (final l in lessons) { l.dispose(); }
  }
}

class _LessonDraft {
  final TextEditingController title;
  final TextEditingController duration;

  _LessonDraft({required String titleText, required String durationText})
      : title = TextEditingController(text: titleText),
        duration = TextEditingController(text: durationText);

  void dispose() {
    title.dispose();
    duration.dispose();
  }
}

class FormationAjoutScreen extends StatefulWidget {
  final void Function(FormationModel)? onSave;
  const FormationAjoutScreen({super.key, this.onSave});

  @override
  State<FormationAjoutScreen> createState() => _FormationAjoutScreenState();
}

class _FormationAjoutScreenState extends State<FormationAjoutScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _level = 'Débutant';
  String _category = 'Robotique';
  bool _offline = true;

  final List<_ModuleDraft> _modules = [
    _ModuleDraft(
      titleText: 'Module 1 · Introduction',
      lessons: [
        _LessonDraft(titleText: 'Leçon 1 · Présentation', durationText: '8 min'),
        _LessonDraft(titleText: 'Leçon 2 · Installation', durationText: '10 min'),
      ],
    ),
  ];

  int _moduleCounter = 2;
  int _lessonCounter = 3;

  static const _categories = [
    'Robotique', 'Électronique', 'Programmation', 'Intelligence Artificielle',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final m in _modules) { m.dispose(); }
    super.dispose();
  }

  void _addModule() {
    setState(() {
      _modules.add(_ModuleDraft(
        titleText: 'Module $_moduleCounter · Nouveau module',
        lessons: [],
      ));
      _moduleCounter++;
    });
  }

  void _removeModule(int index) {
    setState(() {
      _modules[index].dispose();
      _modules.removeAt(index);
    });
  }

  void _addLesson(int moduleIndex) {
    setState(() {
      _modules[moduleIndex].lessons.add(
        _LessonDraft(
          titleText: 'Leçon $_lessonCounter · Nouvelle leçon',
          durationText: '10 min',
        ),
      );
      _lessonCounter++;
    });
  }

  void _removeLesson(int moduleIndex, int lessonIndex) {
    setState(() {
      _modules[moduleIndex].lessons[lessonIndex].dispose();
      _modules[moduleIndex].lessons.removeAt(lessonIndex);
    });
  }

  void _publish() {
    if (_titleCtrl.text.trim().isEmpty) {
      _snack('Veuillez saisir un titre.');
      return;
    }
    final model = FormationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      subtitle: _descCtrl.text.trim().isEmpty
          ? '—' : _descCtrl.text.trim(),
      instructor: 'Moi',
      level: _level,
      duration: '—',
      rating: 0.0,
      enrolled: 0,
      modules: _modules.map((m) => ModuleModel(
        title: m.title.text.trim().isEmpty ? 'Module' : m.title.text.trim(),
        lessons: m.lessons.asMap().entries.map((e) => LessonModel(
          id: DateTime.now().millisecondsSinceEpoch + e.key,
          title: e.value.title.text.trim().isEmpty
              ? 'Leçon ${e.key + 1}' : e.value.title.text.trim(),
          duration: e.value.duration.text.trim().isEmpty
              ? '—' : e.value.duration.text.trim(),
        )).toList(),
      )).toList(),
    );

    widget.onSave?.call(model);
    _snack('Formation publiée avec succès ✓');
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: LearningTheme.surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: LearningTheme.mint, size: 18),
        const SizedBox(width: 10),
        Text(msg, style: const TextStyle(
            fontFamily: LearningTheme.font, color: Colors.white)),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _buildCoverPicker(),
                  const SizedBox(height: 24),
                  _secTitle('Informations de la formation'),
                  const SizedBox(height: 16),
                  _label('Titre de la formation'),
                  _field(controller: _titleCtrl,
                      hint: 'Ex : Initiation à Arduino'),
                  const SizedBox(height: 16),
                  _label('Description'),
                  _field(controller: _descCtrl,
                      hint: 'Décrivez le contenu et les objectifs…',
                      height: 110),
                  const SizedBox(height: 16),
                  _label('Catégorie'),
                  _dropdown(value: _category, items: _categories,
                      onChanged: (v) => setState(() => _category = v!)),
                  const SizedBox(height: 16),
                  _label('Niveau'),
                  _levelChips(),
                  const SizedBox(height: 16),
                  _offlineRow(),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _secTitle('Modules'),
                      _addBtn('Ajouter un module', _addModule),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._modules.asMap().entries.map(
                        (e) => _buildModuleCard(e.key, e.value)),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: LearningTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LearningTheme.border),
          ),
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
        ),
      ),
      const SizedBox(width: 14),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Espace formateur', style: LearningTheme.captionStyle),
        SizedBox(height: 2),
        Text('Créer une formation',
            style: TextStyle(fontFamily: LearningTheme.font,
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );

  Widget _buildCoverPicker() => Container(
    height: 150,
    decoration: BoxDecoration(
      color: const Color(0xFF050C13),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: LearningTheme.border),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: LearningTheme.mint.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: LearningTheme.mint.withValues(alpha: 0.4)),
        ),
        child: const Icon(Icons.add_photo_alternate_rounded,
            color: LearningTheme.mint, size: 26),
      ),
      const SizedBox(height: 10),
      const Text("Ajouter une image de couverture",
          style: LearningTheme.captionStyle),
      const SizedBox(height: 4),
      const Text("PNG, JPG — max 5 Mo", style: LearningTheme.captionStyle),
    ]),
  );

  Widget _levelChips() => Row(
    children: ['Débutant', 'Intermédiaire', 'Avancé']
        .map((l) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => setState(() => _level = l),
            child: _chip(l, selected: _level == l),
          ),
        )).toList(),
  );

  Widget _offlineRow() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: LearningTheme.cardDeco(),
    child: Row(children: [
      const Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disponible hors ligne',
              style: TextStyle(fontFamily: LearningTheme.font,
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('Les apprenants pourront télécharger',
              style: LearningTheme.captionStyle),
        ],
      )),
      Switch(
        value: _offline,
        activeThumbColor: LearningTheme.mint,
        onChanged: (v) => setState(() => _offline = v),
      ),
    ]),
  );

  Widget _buildModuleCard(int moduleIndex, _ModuleDraft module) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      decoration: LearningTheme.cardDeco(),
      child: Column(
        children: [
          // Module header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: LearningTheme.mint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('${moduleIndex + 1}',
                    style: const TextStyle(fontFamily: LearningTheme.font,
                        color: LearningTheme.mint, fontSize: 13,
                        fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextField(
                controller: module.title,
                style: const TextStyle(fontFamily: LearningTheme.font,
                    color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  border: InputBorder.none, isDense: true,
                ),
              )),
              GestureDetector(
                onTap: () => _removeModule(moduleIndex),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 16),
                ),
              ),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Divider(color: LearningTheme.border, height: 1),
          ),
          if (module.lessons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Column(
                children: module.lessons.asMap().entries
                    .map((e) => _buildLessonRow(moduleIndex, e.key, e.value))
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: GestureDetector(
              onTap: () => _addLesson(moduleIndex),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: LearningTheme.mint.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: LearningTheme.mint.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: LearningTheme.mint, size: 16),
                    SizedBox(width: 6),
                    Text('Ajouter une leçon',
                        style: TextStyle(fontFamily: LearningTheme.font,
                            color: LearningTheme.mint, fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildLessonRow(int moduleIndex, int lessonIndex, _LessonDraft lesson) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: LearningTheme.border, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: lesson.title,
            style: const TextStyle(fontFamily: LearningTheme.font,
                color: LearningTheme.textSecond, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Titre de la leçon',
              hintStyle: TextStyle(fontFamily: LearningTheme.font,
                  color: LearningTheme.textSecond, fontSize: 13),
              border: InputBorder.none, isDense: true,
            ),
          )),
          SizedBox(width: 70, child: TextField(
            controller: lesson.duration,
            style: const TextStyle(fontFamily: LearningTheme.font,
                color: LearningTheme.textSecond, fontSize: 12),
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: 'durée',
              hintStyle: TextStyle(fontFamily: LearningTheme.font,
                  color: LearningTheme.textSecond, fontSize: 12),
              border: InputBorder.none, isDense: true,
            ),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeLesson(moduleIndex, lessonIndex),
            child: const Icon(Icons.close_rounded,
                color: LearningTheme.textSecond, size: 16),
          ),
        ]),
      );

  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: LearningTheme.border))),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LearningTheme.mint),
        ),
        child: const Text('Brouillon',
            style: TextStyle(fontFamily: LearningTheme.font,
                color: LearningTheme.mint, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 12),
      Expanded(child: GestureDetector(
        onTap: _publish,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
                colors: [LearningTheme.mint, LearningTheme.mintDark]),
          ),
          alignment: Alignment.center,
          child: const Text('Publier la formation',
              style: LearningTheme.buttonStyle),
        ),
      )),
    ]),
  );

  static Widget _secTitle(String t) => Text(t, style: LearningTheme.sectionStyle);

  static Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: LearningTheme.labelStyle),
  );

  static Widget _field({
    TextEditingController? controller, required String hint,
    double? height, TextInputType keyboardType = TextInputType.text,
  }) => Container(
    height: height ?? 52,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: height != null ? Alignment.topLeft : Alignment.centerLeft,
    decoration: LearningTheme.cardDeco(),
    child: Padding(
      padding: EdgeInsets.only(top: height != null ? 14 : 0),
      child: TextField(
        controller: controller, maxLines: height != null ? null : 1,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: LearningTheme.font,
            color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: LearningTheme.labelStyle,
          border: InputBorder.none, isDense: true,
        ),
      ),
    ),
  );

  static Widget _dropdown({
    required String value, required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: LearningTheme.cardDeco(),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, dropdownColor: LearningTheme.surface,
      iconEnabledColor: LearningTheme.textSecond, isExpanded: true,
      style: const TextStyle(fontFamily: LearningTheme.font,
          color: Colors.white, fontSize: 14),
      items: items.map((i) =>
          DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    )),
  );

  static Widget _chip(String text, {bool selected = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: selected
          ? LearningTheme.mint.withValues(alpha: 0.12)
          : LearningTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
          color: selected ? LearningTheme.mint : LearningTheme.border),
    ),
    child: Text(text,
        style: TextStyle(
            fontFamily: LearningTheme.font,
            color: selected ? LearningTheme.mint : Colors.white,
            fontSize: 13, fontWeight: FontWeight.w600)),
  );

  static Widget _addBtn(String label, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Row(children: [
        const Icon(Icons.add, color: LearningTheme.mint, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: LearningTheme.font,
            color: LearningTheme.mint, fontSize: 13,
            fontWeight: FontWeight.w600)),
      ]));
}
