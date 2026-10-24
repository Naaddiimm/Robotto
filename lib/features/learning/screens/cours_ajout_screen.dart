import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';
import '../widgets/youtube_search_sheet.dart';

// ── Validation helpers ────────────────────────────────────────────────────────

/// Extracts a YouTube video ID from a full URL or returns the raw value.
String _extractVideoId(String input) {
  final t = input.trim();
  if (t.isEmpty) return '';
  final uri = Uri.tryParse(t);
  if (uri != null && uri.queryParameters.containsKey('v')) {
    return uri.queryParameters['v']!;
  }
  if (uri != null && uri.host == 'youtu.be') {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : t;
  }
  return t;
}

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

// ── Lesson draft — holds controllers for one leçon row ───────────────────────
class _LessonDraft {
  final TextEditingController title;
  final TextEditingController duration;
  final TextEditingController content;
  final TextEditingController videoUrl;

  _LessonDraft({
    String titleText = '',
    String durationText = '10 min',
    String contentText = '',
    String videoUrlText = '',
  })  : title = TextEditingController(text: titleText),
        duration = TextEditingController(text: durationText),
        content = TextEditingController(text: contentText),
        videoUrl = TextEditingController(text: videoUrlText);

  void dispose() {
    title.dispose();
    duration.dispose();
    content.dispose();
    videoUrl.dispose();
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────
class CoursAjoutScreen extends StatefulWidget {
  final void Function(CoursModel)? onSave;
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
  late final TextEditingController _videoUrlCtrl;

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
    final rawDur  = c?.duration.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    _durationCtrl = TextEditingController(text: rawDur);
    _videoUrlCtrl = TextEditingController(text: c?.videoId ?? '');
    _level        = c?.level ?? 'Débutant';
    _lessons      = c == null
        ? []
        : c.lessons.map((l) => _LessonDraft(
              titleText:    l.title,
              durationText: l.duration,
              contentText:  l.content,
              videoUrlText: l.videoId ?? '',
            )).toList();
    _counter = _lessons.length + 1;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _moduleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _videoUrlCtrl.dispose();
    for (final l in _lessons) { l.dispose(); }
    super.dispose();
  }

  void _addLesson() {
    setState(() {
      _lessons.add(_LessonDraft(titleText: 'Leçon $_counter · '));
      _counter++;
    });
  }

  void _removeLesson(int i) {
    setState(() {
      _lessons[i].dispose();
      _lessons.removeAt(i);
    });
  }

  /// Opens the full-screen content editor for a single leçon.
  void _editLessonContent(int idx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LessonContentEditor(
          lessonTitle: _lessons[idx].title.text.isEmpty
              ? 'Leçon ${idx + 1}'
              : _lessons[idx].title.text,
          controller: _lessons[idx].content,
          videoUrlController: _lessons[idx].videoUrl,
        ),
      ),
    );
  }

  void _publish() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final model = (_isEdit
            ? widget.initialCours!
            : CoursModel(
                id: DateTime.now().millisecondsSinceEpoch,
                title: '', module: '', description: '',
                level: '', duration: '', rating: 0.0, lessons: const [],
              ))
        .copyWith(
      title:       _titleCtrl.text.trim(),
      module:      _moduleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      level:       _level,
      duration:    '${_durationCtrl.text.trim()} min',
      videoId:     _extractVideoId(_videoUrlCtrl.text),
      lessons: _lessons.asMap().entries.map((e) {
        final l = e.value;
        final existingId = _isEdit && e.key < (widget.initialCours!.lessons.length)
            ? widget.initialCours!.lessons[e.key].id
            : DateTime.now().millisecondsSinceEpoch + e.key;
        return LessonModel(
          id:       existingId,
          title:    l.title.text.trim().isEmpty ? 'Leçon ${e.key + 1}' : l.title.text.trim(),
          duration: l.duration.text.trim().isEmpty ? '—' : l.duration.text.trim(),
          content:  l.content.text.trim(),
          videoId:  _extractVideoId(l.videoUrl.text).isEmpty
                        ? null
                        : _extractVideoId(l.videoUrl.text),
        );
      }).toList(),
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
                    // ── YouTube URL for the cours ──────────────────────
                    _videoPicker(),
                    const SizedBox(height: 24),

                    // ── Cours info ────────────────────────────────────
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

                    // ── Leçons ────────────────────────────────────────
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
                    ..._lessons.asMap().entries.map(
                        (e) => _lessonRow(e.key, e.value)),
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

  Widget _videoPicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Vidéo du cours (YouTube)'),
      GestureDetector(
        onTap: () async {
          final id = await showYouTubeSearchSheet(
            context,
            hint: _titleCtrl.text.isNotEmpty
                ? _titleCtrl.text
                : 'Arduino',
          );
          if (id != null) setState(() => _videoUrlCtrl.text = id);
        },
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: LearningTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _videoUrlCtrl.text.isNotEmpty
                  ? const Color(0xFFFF4444).withValues(alpha: 0.6)
                  : LearningTheme.border,
            ),
          ),
          child: Row(children: [
            Icon(
              Icons.smart_display_rounded,
              color: _videoUrlCtrl.text.isNotEmpty
                  ? const Color(0xFFFF4444)
                  : LearningTheme.textSecond,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _videoUrlCtrl,
                builder: (context, val, child) => Text(
                  val.text.isNotEmpty
                      ? 'Vidéo sélectionnée : ${val.text}'
                      : 'Rechercher une vidéo sur YouTube…',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: LearningTheme.font,
                    color: val.text.isNotEmpty
                        ? Colors.white
                        : LearningTheme.textSecond,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            if (_videoUrlCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _videoUrlCtrl.clear()),
                child: const Icon(Icons.close_rounded,
                    color: LearningTheme.textSecond, size: 18),
              )
            else
              const Icon(Icons.search_rounded,
                  color: LearningTheme.mint, size: 20),
          ]),
        ),
      ),
    ],
  );

  Widget _levelChips() => Row(
    children: ['Débutant', 'Intermédiaire', 'Avancé']
        .map((l) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _level = l),
                child: _chip(l, selected: _level == l),
              ),
            ))
        .toList(),
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

  Widget _lessonRow(int idx, _LessonDraft draft) {
    final hasContent = draft.content.text.trim().isNotEmpty;
    final hasVideo   = draft.videoUrl.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: LearningTheme.cardDeco(
            border: hasContent ? LearningTheme.mint : null),
        child: Column(
          children: [
            // ── Top row: number, title, duration, delete ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: LearningTheme.mint.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('${idx + 1}',
                      style: const TextStyle(fontFamily: LearningTheme.font,
                          color: LearningTheme.mint, fontSize: 12,
                          fontWeight: FontWeight.w700))),
                ),
                const SizedBox(width: 10),
                Expanded(flex: 3, child: TextField(
                  controller: draft.title,
                  style: const TextStyle(fontFamily: LearningTheme.font,
                      color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Titre de la leçon',
                    hintStyle: TextStyle(fontFamily: LearningTheme.font,
                        color: LearningTheme.textSecond, fontSize: 13),
                    border: InputBorder.none, isDense: true,
                  ),
                )),
                SizedBox(width: 72, child: TextField(
                  controller: draft.duration,
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
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _removeLesson(idx),
                  child: const Icon(Icons.close_rounded,
                      color: LearningTheme.textSecond, size: 18),
                ),
              ]),
            ),

            // ── Action buttons row ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(children: [
                // Content editor button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _editLessonContent(idx);
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: hasContent
                            ? LearningTheme.mint.withValues(alpha: 0.12)
                            : LearningTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasContent
                              ? LearningTheme.mint.withValues(alpha: 0.5)
                              : LearningTheme.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasContent
                                ? Icons.edit_note_rounded
                                : Icons.add_circle_outline_rounded,
                            color: hasContent
                                ? LearningTheme.mint
                                : LearningTheme.textSecond,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasContent ? 'Modifier le contenu' : 'Écrire le contenu',
                            style: TextStyle(
                              fontFamily: LearningTheme.font,
                              color: hasContent
                                  ? LearningTheme.mint
                                  : LearningTheme.textSecond,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Video URL mini field
                GestureDetector(
                  onTap: () => _showVideoDialog(idx),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: hasVideo
                          ? const Color(0xFFFF0000).withValues(alpha: 0.10)
                          : LearningTheme.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: hasVideo
                            ? const Color(0xFFFF4444).withValues(alpha: 0.5)
                            : LearningTheme.border,
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.smart_display_rounded,
                          color: hasVideo
                              ? const Color(0xFFFF4444)
                              : LearningTheme.textSecond,
                          size: 16),
                      const SizedBox(width: 5),
                      Text(hasVideo ? 'Vidéo ✓' : 'Vidéo',
                          style: TextStyle(
                            fontFamily: LearningTheme.font,
                            color: hasVideo
                                ? const Color(0xFFFF4444)
                                : LearningTheme.textSecond,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ]),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the YouTube search sheet to pick a video for a leçon.
  void _showVideoDialog(int idx) async {
    final id = await showYouTubeSearchSheet(
      context,
      hint: _lessons[idx].title.text.isNotEmpty
          ? _lessons[idx].title.text
          : 'Arduino',
    );
    if (id != null) setState(() => _lessons[idx].videoUrl.text = id);
  }

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
          child: Text(
              _isEdit ? 'Enregistrer les modifications' : 'Publier le cours',
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
    style: const TextStyle(fontFamily: LearningTheme.font,
        color: Colors.white, fontSize: 14),
    validator: (v) => validator(v ?? ''),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: LearningTheme.labelStyle,
      errorStyle: const TextStyle(fontFamily: LearningTheme.font,
          color: LearningTheme.error, fontSize: 11),
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
      style: const TextStyle(fontFamily: LearningTheme.font,
          color: Colors.white, fontSize: 14),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
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
            fontSize: 13,
            fontWeight: FontWeight.w600)),
  );

  static Widget _addBtn(String label, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Row(children: [
        const Icon(Icons.add, color: LearningTheme.mint, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: LearningTheme.font,
            color: LearningTheme.mint, fontSize: 13,
            fontWeight: FontWeight.w600)),
      ]));

  static Widget _emptyHint(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: LearningTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: LearningTheme.mint.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: Text(text, style: LearningTheme.captionStyle),
    ),
  );
}

// ── Lesson content editor (full-screen) ──────────────────────────────────────
class _LessonContentEditor extends StatefulWidget {
  final String lessonTitle;
  final TextEditingController controller;
  final TextEditingController videoUrlController;

  const _LessonContentEditor({
    required this.lessonTitle,
    required this.controller,
    required this.videoUrlController,
  });

  @override
  State<_LessonContentEditor> createState() => _LessonContentEditorState();
}

class _LessonContentEditorState extends State<_LessonContentEditor> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    // Work on a copy; save only on confirm.
    _ctrl  = TextEditingController(text: widget.controller.text);
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    widget.controller.text = _ctrl.text;
    Navigator.pop(context);
  }

  /// Inserts a formatting snippet at the current cursor position.
  void _insert(String snippet, {int cursorOffset = 0}) {
    final sel   = _ctrl.selection;
    final text  = _ctrl.text;
    final start = sel.start < 0 ? text.length : sel.start;
    final end   = sel.end   < 0 ? text.length : sel.end;

    final before   = text.substring(0, start);
    final selected = text.substring(start, end);
    final after    = text.substring(end);

    final newText = selected.isEmpty
        ? '$before$snippet$after'
        : '$before${snippet.replaceFirst('|', selected)}$after';

    _ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + snippet.length - cursorOffset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contenu de la leçon',
                        style: LearningTheme.captionStyle),
                    const SizedBox(height: 2),
                    Text(widget.lessonTitle,
                        style: const TextStyle(
                            fontFamily: LearningTheme.font,
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                  ],
                )),
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                          colors: [LearningTheme.mint, LearningTheme.mintDark]),
                    ),
                    child: const Text('Enregistrer',
                        style: TextStyle(
                            fontFamily: LearningTheme.font,
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),

            // ── Formatting toolbar ────────────────────────────────────
            _FormattingToolbar(onInsert: _insert),

            const Divider(color: LearningTheme.border, height: 1),

            // ── Syntax hint ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: LearningTheme.surfaceHigh,
              child: const Text(
                '**Titre**  ·  - puce  ·  1. liste  ·  ```code```  ·  | col |',
                style: TextStyle(
                    fontFamily: LearningTheme.font,
                    color: LearningTheme.textSecond,
                    fontSize: 11),
              ),
            ),

            const Divider(color: LearningTheme.border, height: 1),

            // ── Text editor ───────────────────────────────────────────
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                    fontFamily: LearningTheme.font,
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.7),
                decoration: const InputDecoration(
                  hintText:
                      'Écrivez ici le contenu de la leçon…\n\n'
                      'Exemple :\n'
                      '**Introduction**\n\n'
                      'Dans cette leçon, vous allez apprendre…\n\n'
                      '1. Premier point\n'
                      '2. Deuxième point\n\n'
                      '```cpp\n'
                      'void setup() {}\n'
                      '```',
                  hintStyle: TextStyle(
                      fontFamily: LearningTheme.font,
                      color: LearningTheme.textSecond,
                      fontSize: 13,
                      height: 1.7),
                  contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Formatting toolbar ────────────────────────────────────────────────────────
class _FormattingToolbar extends StatelessWidget {
  final void Function(String snippet, {int cursorOffset}) onInsert;
  const _FormattingToolbar({required this.onInsert});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: LearningTheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          _btn('B', '**|**', label: 'Gras', cursorOffset: 2),
          _btn('H', '\n**|**\n\n', label: 'Titre', cursorOffset: 3),
          _btn('•', '\n- |', label: 'Puce', cursorOffset: 0),
          _btn('1.', '\n1. |', label: 'Liste', cursorOffset: 0),
          _codeBtn(),
          _btn('|T|', '\n| | |\n|---|---|\n| | |\n', label: 'Tableau', cursorOffset: 0),
          _dividerBtn(),
        ]),
      ),
    );
  }

  Widget _btn(String icon, String snippet,
      {required String label, int cursorOffset = 0}) =>
      Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Tooltip(
          message: label,
          child: GestureDetector(
            onTap: () => onInsert(snippet, cursorOffset: cursorOffset),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: LearningTheme.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LearningTheme.border),
              ),
              child: Text(icon,
                  style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );

  Widget _codeBtn() => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Tooltip(
      message: 'Bloc de code',
      child: GestureDetector(
        onTap: () => onInsert('\n```\n|\n```\n', cursorOffset: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: LearningTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LearningTheme.border),
          ),
          child: const Text('{ }',
              style: TextStyle(
                  fontFamily: 'monospace',
                  color: LearningTheme.mint,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    ),
  );

  Widget _dividerBtn() => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Tooltip(
      message: 'Séparateur',
      child: GestureDetector(
        onTap: () => onInsert('\n---\n', cursorOffset: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: LearningTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LearningTheme.border),
          ),
          child: const Text('—',
              style: TextStyle(
                  fontFamily: LearningTheme.font,
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    ),
  );
}
