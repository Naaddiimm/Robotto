import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/event_theme.dart';

/// Formulaire de création et de modification d'un événement.
/// Passer [existingEvent] pour passer en mode édition.
class EventFormScreen extends StatefulWidget {
  final EventModel? existingEvent;
  final int organizerId;

  const EventFormScreen({
    super.key,
    required this.organizerId,
    this.existingEvent,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = EventService();

  // Contrôleurs
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _onlineLinkCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _programCtrl;
  late final TextEditingController _rulesCtrl;
  late final TextEditingController _contactEmailCtrl;
  late final TextEditingController _contactPhoneCtrl;

  // Valeurs de sélection
  String _type = 'event';
  String _category = EventModel.categories.first;
  String _level = 'tous';
  String _mode = 'presentiel';
  String _status = 'draft';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationDeadline;

  bool _isLoading = false;
  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    _titleCtrl         = TextEditingController(text: e?.title ?? '');
    _descCtrl          = TextEditingController(text: e?.description ?? '');
    _locationCtrl      = TextEditingController(text: e?.location ?? '');
    _addressCtrl       = TextEditingController(text: e?.address ?? '');
    _onlineLinkCtrl    = TextEditingController(text: e?.onlineLink ?? '');
    _capacityCtrl      = TextEditingController(text: e != null ? '${e.capacity}' : '');
    _priceCtrl         = TextEditingController(text: e != null ? '${e.price}' : '0');
    _programCtrl       = TextEditingController(text: e?.program ?? '');
    _rulesCtrl         = TextEditingController(text: e?.rules ?? '');
    _contactEmailCtrl  = TextEditingController(text: e?.contactEmail ?? '');
    _contactPhoneCtrl  = TextEditingController(text: e?.contactPhone ?? '');

    if (e != null) {
      _type     = e.type;
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
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _descCtrl, _locationCtrl, _addressCtrl, _onlineLinkCtrl,
      _capacityCtrl, _priceCtrl, _programCtrl, _rulesCtrl,
      _contactEmailCtrl, _contactPhoneCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Date pickers
  // -------------------------------------------------------------------------

  Future<void> _pickDate(BuildContext context,
      {required DateTime? current,
      required ValueChanged<DateTime> onPicked}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
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

  // -------------------------------------------------------------------------
  // Sauvegarde
  // -------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifications de dates non couvertes par les validators de champ
    if (_startDate == null) {
      _showError('Veuillez sélectionner une date de début.');
      return;
    }
    if (_endDate == null) {
      _showError('Veuillez sélectionner une date de fin.');
      return;
    }

    final now = DateTime.now().toIso8601String();
    final event = EventModel(
      id:                   widget.existingEvent?.id,
      organizerId:          widget.organizerId,
      title:                _titleCtrl.text.trim(),
      description:          _descCtrl.text.trim(),
      type:                 _type,
      category:             _category,
      level:                _level,
      mode:                 _mode,
      status:               _status,
      location:             _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      address:              _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      onlineLink:           _onlineLinkCtrl.text.trim().isEmpty ? null : _onlineLinkCtrl.text.trim(),
      startDate:            _startDate!.toIso8601String(),
      endDate:              _endDate!.toIso8601String(),
      registrationDeadline: _registrationDeadline?.toIso8601String(),
      capacity:             int.tryParse(_capacityCtrl.text.trim()) ?? 0,
      price:                double.tryParse(_priceCtrl.text.trim()) ?? 0,
      program:              _programCtrl.text.trim().isEmpty ? null : _programCtrl.text.trim(),
      rules:                _rulesCtrl.text.trim().isEmpty ? null : _rulesCtrl.text.trim(),
      contactEmail:         _contactEmailCtrl.text.trim().isEmpty ? null : _contactEmailCtrl.text.trim(),
      contactPhone:         _contactPhoneCtrl.text.trim().isEmpty ? null : _contactPhoneCtrl.text.trim(),
      createdAt:            widget.existingEvent?.createdAt ?? now,
      updatedAt:            now,
    );

    setState(() => _isLoading = true);
    try {
      ServiceResult result;
      if (_isEditing) {
        result = await _service.updateEvent(event);
      } else {
        result = await _service.createEvent(event);
      }

      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.pop(context, true); // retourne true = succès
      } else {
        _showError(result.error ?? 'Erreur inconnue.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: EventTheme.fontFamily)),
        backgroundColor: EventTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: Text(
          _isEditing ? 'Modifier l\'événement' : 'Nouvel événement',
          style: EventTheme.titleStyle,
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: EventTheme.mint, strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text(
                'Enregistrer',
                style: TextStyle(
                  fontFamily: EventTheme.fontFamily,
                  color: EventTheme.mint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(EventTheme.screenPadding),
          children: [
            _SectionHeader('Informations générales'),
            const SizedBox(height: 12),

            // Type
            _buildDropdownField<String>(
              label: 'Type',
              value: _type,
              items: const {'event': 'Événement', 'competition': 'Compétition'},
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 14),

            // Titre
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(label: 'Titre *', hint: 'Titre de l\'événement'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Le titre est obligatoire.';
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
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'La description est obligatoire.';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Catégorie
            _buildDropdownField<String>(
              label: 'Catégorie',
              value: _category,
              items: {for (var c in EventModel.categories) c: c},
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),

            // Niveau
            _buildDropdownField<String>(
              label: 'Niveau',
              value: _level,
              items: EventModel.levelLabels,
              onChanged: (v) => setState(() => _level = v!),
            ),
            const SizedBox(height: 14),

            // Mode
            _buildDropdownField<String>(
              label: 'Mode de participation',
              value: _mode,
              items: EventModel.modeLabels,
              onChanged: (v) => setState(() => _mode = v!),
            ),
            const SizedBox(height: 14),

            // Statut
            _buildDropdownField<String>(
              label: 'Statut',
              value: _status,
              items: EventModel.statusLabels,
              onChanged: (v) => setState(() => _status = v!),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Dates'),
            const SizedBox(height: 12),

            // Date début
            _buildDateField(
              label: 'Date de début *',
              value: _startDate,
              onTap: () => _pickDate(context,
                  current: _startDate,
                  onPicked: (d) => setState(() => _startDate = d)),
            ),
            const SizedBox(height: 14),

            // Date fin
            _buildDateField(
              label: 'Date de fin *',
              value: _endDate,
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

            // Date limite inscription
            _buildDateField(
              label: 'Date limite d\'inscription (optionnel)',
              value: _registrationDeadline,
              onTap: () => _pickDate(context,
                  current: _registrationDeadline,
                  onPicked: (d) => setState(() => _registrationDeadline = d)),
              canClear: true,
              onClear: () => setState(() => _registrationDeadline = null),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Lieu et accès'),
            const SizedBox(height: 12),

            // Lieu
            TextFormField(
              controller: _locationCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Lieu', hint: 'Ville, salle, université…',
                  prefix: const Icon(Icons.location_on_outlined, color: EventTheme.textSoft, size: 20)),
              validator: (v) {
                if (_mode == 'presentiel' && (v == null || v.trim().isEmpty)) {
                  return 'Le lieu est obligatoire pour un événement présentiel.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Adresse
            TextFormField(
              controller: _addressCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(label: 'Adresse complète (optionnel)'),
            ),
            const SizedBox(height: 14),

            // Lien en ligne
            TextFormField(
              controller: _onlineLinkCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Lien Google Meet / en ligne',
                  hint: 'https://meet.google.com/xxx-yyyy-zzz',
                  prefix: const Icon(Icons.videocam_outlined, color: EventTheme.textSoft, size: 20)),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (_mode == 'enligne' && (v == null || v.trim().isEmpty)) {
                  return 'Le lien est obligatoire pour un événement en ligne.';
                }
                if (v != null && v.trim().isNotEmpty) {
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme || uri.scheme != 'https') {
                    return 'Le lien doit commencer par https://';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 24),
            _SectionHeader('Inscriptions et tarif'),
            const SizedBox(height: 12),

            // Capacité
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
                if (n == null || n <= 0) return 'Capacité invalide (entier > 0).';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Prix
            TextFormField(
              controller: _priceCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Prix (DZD)', hint: '0 = gratuit',
                  prefix: const Icon(Icons.payments_outlined, color: EventTheme.textSoft, size: 20)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n < 0) return 'Prix invalide (≥ 0).';
                return null;
              },
            ),

            const SizedBox(height: 24),
            _SectionHeader('Détails supplémentaires'),
            const SizedBox(height: 12),

            // Programme
            TextFormField(
              controller: _programCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Programme (optionnel)', hint: 'Déroulement de l\'événement…'),
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            // Règlement
            TextFormField(
              controller: _rulesCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'Règlement (optionnel)', hint: 'Règles et conditions…'),
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            _SectionHeader('Contact'),
            const SizedBox(height: 12),

            // Email contact
            TextFormField(
              controller: _contactEmailCtrl,
              style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
              decoration: EventTheme.inputDecoration(
                  label: 'E-mail de contact', hint: 'contact@exemple.com',
                  prefix: const Icon(Icons.email_outlined, color: EventTheme.textSoft, size: 20)),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!r.hasMatch(v.trim())) return 'E-mail invalide.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Téléphone contact
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

  // -------------------------------------------------------------------------
  // Helpers UI
  // -------------------------------------------------------------------------

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: EventTheme.surfaceHigh,
      style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily, fontSize: 14),
      decoration: EventTheme.inputDecoration(label: label),
      items: items.entries
          .map((e) => DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool canClear = false,
    VoidCallback? onClear,
  }) {
    final display = value != null
        ? '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}/'
          '${value.year}'
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
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: EventTheme.textSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: EventTheme.labelStyle),
                  const SizedBox(height: 2),
                  Text(
                    display,
                    style: TextStyle(
                      fontFamily: EventTheme.fontFamily,
                      fontSize: 14,
                      color: value != null ? EventTheme.text : EventTheme.textSoft,
                    ),
                  ),
                ],
              ),
            ),
            if (canClear && value != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 18, color: EventTheme.textSoft),
              ),
            if (!(canClear && value != null))
              const Icon(Icons.chevron_right, color: EventTheme.textSoft, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(
                color: EventTheme.mint,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: EventTheme.sectionTitle),
      ],
    );
  }
}
