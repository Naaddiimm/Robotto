import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';

// ── Validation helpers ────────────────────────────────────────────────────────

String? _validateTitle(String v) {
  final t = v.trim();
  if (t.isEmpty) return 'Le titre est obligatoire.';
  if (t[0] != t[0].toUpperCase() || t[0] == t[0].toLowerCase()) {
    return 'Le titre doit commencer par une majuscule.';
  }
  return null;
}

String? _validateDesc(String v) {
  final t = v.trim();
  if (t.isEmpty) return 'La description est obligatoire.';
  if (t.length < 20) return 'La description doit dépasser 20 caractères.';
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────

class FormationAjoutScreen extends StatefulWidget {
  final void Function(FormationModel)? onSave;
  /// When non-null the screen opens in edit mode pre-filled with this formation.
  final FormationModel? initialFormation;

  const FormationAjoutScreen({super.key, this.onSave, this.initialFormation});

  @override
  State<FormationAjoutScreen> createState() => _FormationAjoutScreenState();
}

class _FormationAjoutScreenState extends State<FormationAjoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _level;
  String _category = 'Robotique';
  bool _offline = true;

  late final List<_ModuleDraft> _modules;
  late int _moduleCounter;
  late int _lessonCounter;

  bool get _isEdit => widget.initialFormation != null;

  static const _categories = [
    'Robotique', 'Électronique', 'Programmation', 'Intelligence Artificielle',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFormation;
    _titleCtrl = TextEditingController(text: f?.title ?? '');
    _descCtrl  = TextEditingController(text: f?.subtitle ?? '');
    _level     = f?.level ?? 'Débutant';

    if (f == null) {
      _modules = [
        _ModuleDraft(
          titleText: 'Module 1 · Introduction',
          lessons: [
            _LessonDraft(titleText: 'Leçon 1 · Présentation', durationText: '8 min'),
            _LessonDraft(titleText: 'Leçon 2 · Installation', durationText: '10 min'),
          ],
        ),
      ];
      _moduleCounter = 2;
      _lessonCounter = 3;
    } else {
      _modules = f.modules.map((m) => _ModuleDraft(
        titleText: m.title,
        lessons: m.lessons.map((l) => _LessonDraft(
          titleText: l.title,
          durationText: l.duration,
        )).toList(),
      )).toList();
      _moduleCounter = _modules.length + 1;
      _lessonCounter = f.modules.fold(0, (s, m) => s + m.totalCount) + 1;
    }
  }

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
      _modules[moduleIndex].lessons.add(_LessonDraft(
        titleText: 'Leçon $_lessonCounter · Nouvelle leçon',
        durationText: '10 min',
      ));
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final model = (_isEdit ? widget.initialFormation! : FormationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '', subtitle: '', instructor: 'Moi',
      level: '', duration: '—', rating: 0.0, enrolled: 0, modules: const [],
    )).copyWith(
      title: _titleCtrl.text.trim(),
      subtitle: _descCtrl.text.trim().isEmpty ? '—' : _descCtrl.text.trim(),
      level: _level,
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
    _snack(_isEdit ? 'Formation modifiée avec succès ✓' : 'Formation publiée avec succès ✓');
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: LearningTheme.surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: LearningTheme.mint, size: 18),
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
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    _validatedField(
                      controller: _titleCtrl,
                      hint: 'Ex : Initiation à Arduino',
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 16),
                    _label('Description'),
                    _validatedField(
                      controller: _descCtrl,
                      hint: 'Décrivez le contenu et les objectifs…',
                      height: 110,
                      validator: _validateDesc,
                    ),
                    const SizedBox(height: 16),
                    _label('Catégorie'),
                    _dropdown(
                      value: _category,
                      items: _categories,
                      onChanged: (v) => setState(() => _category = v!),
                    ),
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
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Espace formateur', style: LearningTheme.captionStyle),
        const SizedBox(height: 2),
        Text(_isEdit ? 'Modifier la formation' : 'Créer une formation',
            style: const TextStyle(fontFamily: LearningTheme.font,
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
        child: const Icon(Icons.add_photo_alternate_rounded, color: LearningTheme.mint, size: 26),
      ),
      const SizedBox(height: 10),
      const Text("Ajouter une image de couverture", style: LearningTheme.captionStyle),
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
          Text('Les apprenants pourront télécharger', style: LearningTheme.captionStyle),
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
                        color: LearningTheme.mint, fontSize: 13, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextField(
                controller: module.title,
                style: const TextStyle(fontFamily: LearningTheme.font,
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              )),
              GestureDetector(
                onTap: () => _removeModule(moduleIndex),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
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
                  border: Border.all(color: LearningTheme.mint.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: LearningTheme.mint, size: 16),
                    SizedBox(width: 6),
                    Text('Ajouter une leçon',
                        style: TextStyle(fontFamily: LearningTheme.font,
                            color: LearningTheme.mint, fontSize: 13, fontWeight: FontWeight.w600)),
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
            child: const Icon(Icons.close_rounded, color: LearningTheme.textSecond, size: 16),
          ),
        ]),
      );

  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: LearningTheme.border))),
    child: Row(children: [
      if (!_isEdit)
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
      if (!_isEdit) const SizedBox(width: 12),
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
          child: Text(_isEdit ? 'Enregistrer les modifications' : 'Publier la formation',
              style: LearningTheme.buttonStyle),
        ),
      )),
    ]),
  );

  // ── Static helpers ────────────────────────────────────────────────────────

  static Widget _secTitle(String t) => Text(t, style: LearningTheme.sectionStyle);

  static Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: LearningTheme.labelStyle),
  );

  static Widget _validatedField({
    TextEditingController? controller,
    required String hint,
    double? height,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String) validator,
  }) => TextFormField(
    controller: controller,
    maxLines: height != null ? null : 1,
    keyboardType: keyboardType,
    style: const TextStyle(fontFamily: LearningTheme.font, color: Colors.white, fontSize: 14),
    validator: (v) => validator(v ?? ''),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: LearningTheme.labelStyle,
      errorStyle: const TextStyle(
          fontFamily: LearningTheme.font, color: LearningTheme.error, fontSize: 11),
      filled: true,
      fillColor: LearningTheme.surface,
      contentPadding: EdgeInsets.symmetric(
          horizontal: 16, vertical: height != null ? 14 : 0),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LearningTheme.mint, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LearningTheme.error, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LearningTheme.error, width: 1.5)),
    ),
  );

  static Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: LearningTheme.cardDeco(),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value,
      dropdownColor: LearningTheme.surface,
      iconEnabledColor: LearningTheme.textSecond,
      isExpanded: true,
      style: const TextStyle(fontFamily: LearningTheme.font, color: Colors.white, fontSize: 14),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    )),
  );

  static Widget _chip(String text, {bool selected = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: selected ? LearningTheme.mint.withValues(alpha: 0.12) : LearningTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: selected ? LearningTheme.mint : LearningTheme.border),
    ),
    child: Text(text, style: TextStyle(
        fontFamily: LearningTheme.font,
        color: selected ? LearningTheme.mint : Colors.white,
        fontSize: 13, fontWeight: FontWeight.w600)),
  );

  static Widget _addBtn(String label, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Row(children: [
        const Icon(Icons.add, color: LearningTheme.mint, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: LearningTheme.font,
            color: LearningTheme.mint, fontSize: 13, fontWeight: FontWeight.w600)),
      ]));
}
