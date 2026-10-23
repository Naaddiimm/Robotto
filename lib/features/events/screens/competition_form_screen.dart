import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event_model.dart';
import '../models/competition_detail.dart';
import '../services/competition_service.dart';
import '../widgets/event_theme.dart';

/// Formulaire de création / modification d'une compétition.
/// Une compétition = EventModel (type=competition) + CompetitionDetail.
class CompetitionFormScreen extends StatefulWidget {
  final EventModel? existingEvent;
  final CompetitionDetail? existingDetail;
  final int organizerId;

  const CompetitionFormScreen({
    super.key,
    required this.organizerId,
    this.existingEvent,
    this.existingDetail,
  });

  @override
  State<CompetitionFormScreen> createState() => _CompetitionFormScreenState();
}

class _CompetitionFormScreenState extends State<CompetitionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CompetitionService();

  // Contrôleurs communs (hérités de EventModel)
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _onlineLinkCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _rulesCtrl;
  late final TextEditingController _contactEmailCtrl;
  late final TextEditingController _contactPhoneCtrl;

  // Contrôleurs spécifiques compétition
  late final TextEditingController _prizeCtrl;
  late final TextEditingController _minSizeCtrl;
  late final TextEditingController _maxSizeCtrl;

  // Sélecteurs
  String _category = EventModel.categories.first;
  String _level = 'tous';
  String _mode = 'presentiel';
  String _status = 'draft';
  String _participationType = 'individual';
  String? _robotCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationDeadline;

  bool _isLoading = false;
  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    final d = widget.existingDetail;

    _titleCtrl        = TextEditingController(text: e?.title ?? '');
    _descCtrl         = TextEditingController(text: e?.description ?? '');
    _locationCtrl     = TextEditingController(text: e?.location ?? '');
    _onlineLinkCtrl   = TextEditingController(text: e?.onlineLink ?? '');
    _capacityCtrl     = TextEditingController(text: e != null ? '${e.capacity}' : '');
    _priceCtrl        = TextEditingController(text: e != null ? '${e.price}' : '0');
    _rulesCtrl        = TextEditingController(text: e?.rules ?? '');
    _contactEmailCtrl = TextEditingController(text: e?.contactEmail ?? '');
    _contactPhoneCtrl = TextEditingController(text: e?.contactPhone ?? '');
    _prizeCtrl        = TextEditingController(text: d?.prizeDescription ?? '');
    _minSizeCtrl      = TextEditingController(text: d?.teamMinSize?.toString() ?? '');
    _maxSizeCtrl      = TextEditingController(text: d?.teamMaxSize?.toString() ?? '');

    if (e != null) {
      _category = e.category;
      _level    = e.level;
      _mode     = e.mode;
      _status   = e.status;
      _startDate            = DateTime.tryParse(e.startDate);
      _endDate              = DateTime.tryParse(e.endDate);
      _registrationDeadline = e.registrationDeadline != null
          ? DateTime.tryParse(e.registrationDeadline!)
          : null;
    }
    if (d != null) {
      _participationType = d.participationType;
      _robotCategory     = d.robotCategory;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _descCtrl, _locationCtrl, _onlineLinkCtrl,
      _capacityCtrl, _priceCtrl, _rulesCtrl, _contactEmailCtrl,
      _contactPhoneCtrl, _prizeCtrl, _minSizeCtrl, _maxSizeCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context,
      {required DateTime? current, required ValueChanged<DateTime> onPicked}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: EventTheme.mint,
            surface: EventTheme.surfaceHigh,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) { _showError('Date de début requise.'); return; }
    if (_endDate == null)   { _showError('Date de fin requise.'); return; }

    final now = DateTime.now().toIso8601String();

    final event = EventModel(
      id:                   widget.existingEvent?.id,
      organizerId:          widget.organizerId,
      title:                _titleCtrl.text.trim(),
      description:          _descCtrl.text.trim(),
      type:                 'competition',
      category:             _category,
      level:                _level,
      mode:                 _mode,
      status:               _status,
      location:             _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      onlineLink:           _onlineLinkCtrl.text.trim().isEmpty ? null : _onlineLinkCtrl.text.trim(),
      startDate:            _startDate!.toIso8601String(),
      endDate:              _endDate!.toIso8601String(),
      registrationDeadline: _registrationDeadline?.toIso8601String(),
      capacity:             int.tryParse(_capacityCtrl.text.trim()) ?? 0,
      price:                double.tryParse(_priceCtrl.text.trim()) ?? 0,
      rules:                _rulesCtrl.text.trim().isEmpty ? null : _rulesCtrl.text.trim(),
      contactEmail:         _contactEmailCtrl.text.trim().isEmpty ? null : _contactEmailCtrl.text.trim(),
      contactPhone:         _contactPhoneCtrl.text.trim().isEmpty ? null : _contactPhoneCtrl.text.trim(),
      createdAt:            widget.existingEvent?.createdAt ?? now,
      updatedAt:            now,
    );

    final detail = CompetitionDetail(
      eventId:           widget.existingEvent?.id ?? 0,
      participationType: _participationType,
      teamMinSize:       int.tryParse(_minSizeCtrl.text.trim()),
      teamMaxSize:       int.tryParse(_maxSizeCtrl.text.trim()),
      robotCategory:     _robotCategory,
      prizeDescription:  _prizeCtrl.text.trim().isEmpty ? null : _prizeCtrl.text.trim(),
    );

    setState(() => _isLoading = true);
    try {
      final result = _isEditing
          ? await _service.updateCompetition(event, detail)
          : await _service.createCompetition(event, detail);

      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.pop(context, true);
      } else {
        _showError(result.error ?? 'Erreur inconnue.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: EventTheme.fontFamily)),
      backgroundColor: EventTheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: Text(_isEditing ? 'Modifier la compétition' : 'Nouvelle compétition',
            style: EventTheme.titleStyle),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                      child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: EventTheme.mint, strokeWidth: 2))))
              : TextButton(
                  onPressed: _submit,
                  child: const Text('Enregistrer',
                      style: TextStyle(
                          fontFamily: EventTheme.fontFamily,
                          color: EventTheme.mint,
                          fontWeight: FontWeight.bold))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(EventTheme.screenPadding),
          children: [
            _SectionHeader('Informations générales'),
            const SizedBox(height: 12),

            // Titre
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(label: 'Nom de la compétition *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ obligatoire.';
                if (v.trim().length < 3) return 'Minimum 3 caractères.';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _descCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(label: 'Description *'),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire.' : null,
            ),
            const SizedBox(height: 14),

            // Catégorie
            _Dropdown(
              label: 'Catégorie',
              value: _category,
              items: {for (var c in EventModel.categories) c: c},
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),

            // Niveau
            _Dropdown(
              label: 'Niveau',
              value: _level,
              items: EventModel.levelLabels,
              onChanged: (v) => setState(() => _level = v!),
            ),
            const SizedBox(height: 14),

            // Mode
            _Dropdown(
              label: 'Mode',
              value: _mode,
              items: EventModel.modeLabels,
              onChanged: (v) => setState(() => _mode = v!),
            ),
            const SizedBox(height: 14),

            // Statut
            _Dropdown(
              label: 'Statut',
              value: _status,
              items: EventModel.statusLabels,
              onChanged: (v) => setState(() => _status = v!),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Dates'),
            const SizedBox(height: 12),

            _DateField(
              label: 'Date de début *', value: _startDate,
              onTap: () => _pickDate(context,
                  current: _startDate,
                  onPicked: (d) => setState(() => _startDate = d)),
            ),
            const SizedBox(height: 14),
            _DateField(
              label: 'Date de fin *', value: _endDate,
              onTap: () => _pickDate(context,
                  current: _endDate,
                  onPicked: (d) {
                    if (_startDate != null && !d.isAfter(_startDate!)) {
                      _showError('La date de fin doit être après la date de début.');
                      return;
                    }
                    setState(() => _endDate = d);
                  }),
            ),
            const SizedBox(height: 14),
            _DateField(
              label: 'Date limite d\'inscription (optionnel)',
              value: _registrationDeadline,
              onTap: () => _pickDate(context,
                  current: _registrationDeadline,
                  onPicked: (d) => setState(() => _registrationDeadline = d)),
              canClear: true,
              onClear: () => setState(() => _registrationDeadline = null),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Lieu'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _locationCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Lieu', hint: 'Ville, campus…',
                  prefix: const Icon(Icons.location_on_outlined, color: EventTheme.textSoft, size: 20)),
              validator: (v) {
                if (_mode == 'presentiel' && (v == null || v.trim().isEmpty)) {
                  return 'Lieu obligatoire en présentiel.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _onlineLinkCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Lien en ligne', hint: 'https://…',
                  prefix: const Icon(Icons.videocam_outlined, color: EventTheme.textSoft, size: 20)),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (_mode == 'enligne' && (v == null || v.trim().isEmpty)) {
                  return 'Lien obligatoire pour un événement en ligne.';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),
            _SectionHeader('Participation'),
            const SizedBox(height: 12),

            _Dropdown(
              label: 'Type de participation',
              value: _participationType,
              items: CompetitionDetail.participationLabels,
              onChanged: (v) => setState(() => _participationType = v!),
            ),
            const SizedBox(height: 14),

            if (_participationType != 'individual') ...[
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _minSizeCtrl,
                    style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
                    decoration: EventTheme.inputDecoration(label: 'Taille min équipe'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final n = int.tryParse(v);
                        if (n == null || n < 1) return '≥ 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxSizeCtrl,
                    style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
                    decoration: EventTheme.inputDecoration(label: 'Taille max équipe'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ]),
              const SizedBox(height: 14),
            ],

            // Catégorie robot
            DropdownButtonFormField<String?>(
              initialValue: _robotCategory,
              dropdownColor: EventTheme.surfaceHigh,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily, fontSize: 14),
              decoration: EventTheme.inputDecoration(label: 'Catégorie de robot (optionnel)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Aucune')),
                ...CompetitionDetail.robotCategories.map((c) =>
                    DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (v) => setState(() => _robotCategory = v),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Inscriptions et tarif'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _capacityCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Capacité (places) *',
                  prefix: const Icon(Icons.people_outline, color: EventTheme.textSoft, size: 20)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Entier > 0 requis.';
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _priceCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Prix inscription (DZD)', hint: '0 = gratuit',
                  prefix: const Icon(Icons.payments_outlined, color: EventTheme.textSoft, size: 20)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n < 0) return 'Prix invalide (≥ 0).';
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _prizeCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Prix / récompenses (optionnel)',
                  prefix: const Icon(Icons.emoji_events_outlined, color: EventTheme.textSoft, size: 20)),
              maxLines: 2,
            ),

            const SizedBox(height: 24),
            _SectionHeader('Règlement'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _rulesCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(label: 'Règlement (optionnel)'),
              maxLines: 4,
            ),

            const SizedBox(height: 24),
            _SectionHeader('Contact'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _contactEmailCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'E-mail de contact',
                  prefix: const Icon(Icons.email_outlined, color: EventTheme.textSoft, size: 20)),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                    return 'E-mail invalide.';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _contactPhoneCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Téléphone de contact',
                  prefix: const Icon(Icons.phone_outlined, color: EventTheme.textSoft, size: 20)),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sous-widgets locaux réutilisables dans ce fichier
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(
                color: EventTheme.warning,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: EventTheme.sectionTitle),
      ]);
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  const _Dropdown({required this.label, required this.value,
      required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
        initialValue: value,
        dropdownColor: EventTheme.surfaceHigh,
        style: const TextStyle(color: EventTheme.text,
            fontFamily: EventTheme.fontFamily, fontSize: 14),
        decoration: EventTheme.inputDecoration(label: label),
        items: items.entries
            .map((e) => DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      );
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool canClear;
  final VoidCallback? onClear;
  const _DateField({required this.label, required this.value,
      required this.onTap, this.canClear = false, this.onClear});

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? '${value!.day.toString().padLeft(2, '0')}/'
          '${value!.month.toString().padLeft(2, '0')}/${value!.year}'
        : 'Sélectionner une date';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: EventTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: value != null
                  ? EventTheme.mint.withValues(alpha: 0.5)
                  : EventTheme.textSoft.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 18, color: EventTheme.textSoft),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: EventTheme.labelStyle),
            const SizedBox(height: 2),
            Text(display, style: TextStyle(
                fontFamily: EventTheme.fontFamily, fontSize: 14,
                color: value != null ? EventTheme.text : EventTheme.textSoft)),
          ])),
          if (canClear && value != null)
            GestureDetector(onTap: onClear,
                child: const Icon(Icons.close, size: 18, color: EventTheme.textSoft))
          else
            const Icon(Icons.chevron_right, color: EventTheme.textSoft, size: 20),
        ]),
      ),
    );
  }
}
