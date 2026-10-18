import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';

// ── Validation helpers ────────────────────────────────────────────────────────

/// Returns null if valid, otherwise an error message.
String? _validateTitle(String v) {
  final t = v.trim();
  if (t.isEmpty) return 'Le titre est obligatoire.';
  if (t[0] != t[0].toUpperCase() || t[0] == t[0].toLowerCase()) {
    return 'Le titre doit commencer par une majuscule.';
  }
  return null;
}

String? _validateModule(String v) {
  final t = v.trim();
  if (t.isEmpty) return 'Le module est obligatoire.';
  if (!RegExp(r'\d').hasMatch(t)) return 'Le module doit contenir un nombre (ex: Module 2).';
  return null;
}

String? _validateDesc(String v) {
  final t = v.trim();
  if (t.isEmpty) return 'La description est obligatoire.';
  if (t.length < 20) return 'La description doit dépasser 20 caractères.';
  return null;
}

String? _validateDuration(String v) {
  final t = v.trim();
  if (t.isEmpty) return 'La durée est obligatoire.';
  if (!RegExp(r'^\d+$').hasMatch(t)) return 'La durée doit être un nombre (en minutes).';
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────

class _LessonDraft {
  final TextEditingController title;
  final TextEditingController duration;
  _LessonDraft({String titleText = '', String durationText = '10 min'})
      : title = TextEditingController(text: titleText),
        duration = TextEditingController(text: durationText);
  void dispose() {
    title.dispose();
    duration.dispose();
  }
}

class CoursAjoutScreen extends StatefulWidget {
  final void Function(CoursModel)? onSave;
  /// When non-null the screen opens in edit mode pre-filled with this cours.
  final CoursModel? initialCours;

  const CoursAjoutScreen({super.key, this.onSave, this.initialCours});

  @override
  State<CoursAjoutScreen> createState() => _CoursAjoutScreenState();
}

class _CoursAjoutScreenState extends State<CoursAjoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _moduleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;

  late String _level;
  String _category = 'Robotique';
  bool _offline = true;
  late final List<_LessonDraft> _lessons;
  late int _counter;

  bool get _isEdit => widget.initialCours != null;

  static const _categories = [
    'Robotique', 'Électronique', 'Programmation', 'Intelligence Artificielle',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initialCours;
    _titleCtrl    = TextEditingController(text: c?.title ?? '');
    _moduleCtrl   = TextEditingController(text: c?.module ?? '');
    _descCtrl     = TextEditingController(text: c?.description ?? '');
    // strip "min" suffix if present for the duration field
    final rawDur  = c?.duration.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    _durationCtrl = TextEditingController(text: rawDur);
    _level        = c?.level ?? 'Débutant';
    _lessons      = c == null
        ? []
        : c.lessons.map((l) => _LessonDraft(
              titleText: l.title,
              durationText: l.duration,
            )).toList();
    _counter      = _lessons.length + 1;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _moduleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    for (final l in _lessons) { l.dispose(); }
    super.dispose();
  }

  void _addLesson() {
    setState(() {
      final d = _LessonDraft(titleText: 'Leçon $_counter · ', durationText: '10 min');
      _lessons.add(d);
      _counter++;
    });
  }

  void _removeLesson(int i) {
    setState(() {
      _lessons[i].dispose();
      _lessons.removeAt(i);
    });
  }

  void _publish() {
    // Trigger form validation
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final model = (_isEdit ? widget.initialCours! : CoursModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '',
      module: '',
      description: '',
      level: '',
      duration: '',
      rating: 0.0,
      lessons: const [],
    )).copyWith(
      title: _titleCtrl.text.trim(),
      module: _moduleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      level: _level,
      duration: '${_durationCtrl.text.trim()} min',
      lessons: _lessons.asMap().entries.map((e) => LessonModel(
        id: _isEdit && e.key < (widget.initialCours!.lessons.length)
            ? widget.initialCours!.lessons[e.key].id
            : DateTime.now().millisecondsSinceEpoch + e.key,
        title: e.value.title.text.trim().isEmpty
            ? 'Leçon ${e.key + 1}' : e.value.title.text.trim(),
        duration: e.value.duration.text.trim().isEmpty
            ? '—' : e.value.duration.text.trim(),
      )).toList(),
    );

    widget.onSave?.call(model);
    _snack(_isEdit ? 'Cours modifié avec succès ✓' : 'Cours publié avec succès ✓');
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
        Text(msg, style: const TextStyle(fontFamily: LearningTheme.font, color: Colors.white)),
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
                    _videoPicker(),
                    const SizedBox(height: 24),
                    _secTitle('Informations du cours'),
                    const SizedBox(height: 16),
                    _label('Titre du cours'),
                    _validatedField(
                      controller: _titleCtrl,
                      hint: 'Ex : Initiation à Arduino',
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 16),
                    _label('Module'),
                    _validatedField(
                      controller: _moduleCtrl,
                      hint: 'Ex : Module 2 · Capteurs',
                      validator: _validateModule,
                    ),
                    const SizedBox(height: 16),
                    _label('Description'),
                    _validatedField(
                      controller: _descCtrl,
                      hint: 'Décrivez le contenu…',
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
                    _label('Durée totale (min)'),
                    _validatedField(
                      controller: _durationCtrl,
                      hint: 'Ex : 55',
                      keyboardType: TextInputType.number,
                      validator: _validateDuration,
                    ),
                    const SizedBox(height: 16),
                    _offlineRow(),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _secTitle('Leçons'),
                        _addBtn('Ajouter', _addLesson),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_lessons.isEmpty)
                      _emptyHint('Aucune leçon — appuyez sur Ajouter'),
                    ..._lessons.asMap().entries.map((e) => _lessonRow(e.key, e.value)),
                  ],
                ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

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
        Text(_isEdit ? 'Modifier le cours' : 'Ajouter un cours',
            style: const TextStyle(fontFamily: LearningTheme.font,
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );

  Widget _videoPicker() => Container(
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
        child: const Icon(Icons.video_call_rounded, color: LearningTheme.mint, size: 26),
      ),
      const SizedBox(height: 10),
      const Text("Ajouter une vidéo d'aperçu", style: LearningTheme.captionStyle),
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

  Widget _lessonRow(int idx, _LessonDraft draft) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: LearningTheme.cardDeco(),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: LearningTheme.mint.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('${idx + 1}',
              style: const TextStyle(fontFamily: LearningTheme.font,
                  color: LearningTheme.mint, fontSize: 12, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: TextField(
          controller: draft.title,
          style: const TextStyle(fontFamily: LearningTheme.font, color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Titre de la leçon',
            hintStyle: TextStyle(fontFamily: LearningTheme.font, color: LearningTheme.textSecond, fontSize: 13),
            border: InputBorder.none, isDense: true,
          ),
        )),
        const SizedBox(width: 8),
        SizedBox(width: 72, child: TextField(
          controller: draft.duration,
          style: const TextStyle(fontFamily: LearningTheme.font, color: LearningTheme.textSecond, fontSize: 12),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'durée',
            hintStyle: TextStyle(fontFamily: LearningTheme.font, color: LearningTheme.textSecond, fontSize: 12),
            border: InputBorder.none, isDense: true,
          ),
        )),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => _removeLesson(idx),
          child: const Icon(Icons.close_rounded, color: LearningTheme.textSecond, size: 18),
        ),
      ]),
    ),
  );

  Widget _bottomBar() => Container(
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
          child: Text(_isEdit ? 'Enregistrer les modifications' : 'Publier le cours',
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

  /// A field wired to the Form with inline error display.
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
          fontFamily: LearningTheme.font,
          color: LearningTheme.error,
          fontSize: 11),
      filled: true,
      fillColor: LearningTheme.surface,
      contentPadding: EdgeInsets.symmetric(
          horizontal: 16, vertical: height != null ? 14 : 0),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
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

  static Widget _emptyHint(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: LearningTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LearningTheme.mint.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: Text(text, style: LearningTheme.captionStyle),
    ),
  );
}
