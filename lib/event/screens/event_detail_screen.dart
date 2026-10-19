import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/registration_service.dart';
import '../widgets/event_theme.dart';
import 'event_form_screen.dart';

/// Écran de détail d'un événement.
/// Tout utilisateur connecté peut modifier/supprimer (v1 sans rôles).
class EventDetailScreen extends StatefulWidget {
  final int eventId;
  final int? currentUserId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.currentUserId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _eventService = EventService();
  final _regService   = RegistrationService();

  EventModel? _event;
  bool _loading        = true;
  bool _regLoading     = false;
  int  _availableSpots = 0;
  bool _alreadyRegistered = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final e = await _eventService.getEventById(widget.eventId);

    int spots = 0;
    bool reg  = false;
    if (e != null) spots = await _regService.getAvailableSpots(e);
    if (e != null && widget.currentUserId != null) {
      final myReg = await _regService.getMyRegistration(
          widget.eventId, widget.currentUserId!);
      reg = myReg != null && myReg.status == 'confirmed';
    }

    if (mounted) {
      setState(() {
        _event = e;
        _availableSpots = spots;
        _alreadyRegistered = reg;
        _loading = false;
      });
    }
  }

  // v1 : tout utilisateur connecté peut modifier/supprimer
  bool get _canEdit => widget.currentUserId != null;

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => EventFormScreen(
            organizerId: widget.currentUserId!, existingEvent: _event)));
    if (changed == true) _load();
  }

  Future<void> _delete() async {
    final confirmed = await _confirmDialog(
      title: 'Supprimer l\'événement',
      message: 'Cette action est irréversible. '
          'Toutes les inscriptions associées seront supprimées.',
    );
    if (!confirmed || !mounted) return;

    final result = await _eventService.deleteEvent(
        _event!.id!, widget.currentUserId!, _event!.organizerId);
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.pop(context, true);
    } else {
      _showError(result.error!);
    }
  }

  Future<void> _register() async {
    if (widget.currentUserId == null) {
      _showError('Connectez-vous pour vous inscrire.');
      return;
    }
    setState(() => _regLoading = true);
    final result = await _regService.register(
        eventId: widget.eventId, userId: widget.currentUserId!);
    if (!mounted) return;
    setState(() => _regLoading = false);
    if (result.isSuccess) {
      _showSuccess('Inscription confirmée !');
      _load();
    } else {
      _showError(result.error!);
    }
  }

  Future<void> _cancelRegistration() async {
    final confirmed = await _confirmDialog(
      title: 'Annuler l\'inscription',
      message: 'Voulez-vous annuler votre inscription à cet événement ?',
    );
    if (!confirmed || !mounted) return;
    final result = await _regService.cancel(
        eventId: widget.eventId, userId: widget.currentUserId!);
    if (!mounted) return;
    if (result.isSuccess) {
      _showSuccess('Inscription annulée.');
      _load();
    } else {
      _showError(result.error!);
    }
  }

  Future<bool> _confirmDialog(
      {required String title, required String message}) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: EventTheme.surfaceHigh,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title,
                style: const TextStyle(
                    fontFamily: EventTheme.fontFamily,
                    color: EventTheme.text,
                    fontWeight: FontWeight.bold)),
            content: Text(message, style: EventTheme.bodyStyle),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler',
                      style: TextStyle(
                          fontFamily: EventTheme.fontFamily,
                          color: EventTheme.textSoft))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: EventTheme.error.withValues(alpha: 0.15),
                    foregroundColor: EventTheme.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirmer',
                    style: TextStyle(
                        fontFamily: EventTheme.fontFamily,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg,
              style: const TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.error,
          behavior: SnackBarBehavior.floating));

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg,
              style: const TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.success,
          behavior: SnackBarBehavior.floating));

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
        title: Text(_event?.title ?? 'Détail',
            style: EventTheme.titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        actions: _canEdit
            ? [
                IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: EventTheme.mint),
                    tooltip: 'Modifier',
                    onPressed: _loading ? null : _edit),
                IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: EventTheme.error),
                    tooltip: 'Supprimer',
                    onPressed: _loading ? null : _delete),
              ]
            : null,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: EventTheme.mint))
          : _event == null
              ? Center(
                  child: Text('Événement introuvable.',
                      style: EventTheme.bodyStyle))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final e = _event!;
    return ListView(
      padding: const EdgeInsets.all(EventTheme.screenPadding),
      children: [
        // Badges
        Wrap(spacing: 8, children: [
          _Badge(label: 'Événement', color: EventTheme.mint),
          _Badge(
              label: EventModel.statusLabels[e.status] ?? e.status,
              color: EventTheme.statusColor(e.status)),
          _Badge(
              label: EventModel.levelLabels[e.level] ?? e.level,
              color: EventTheme.info),
        ]),
        const SizedBox(height: 16),

        // Titre + description
        Text(e.title,
            style: EventTheme.titleStyle.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        Text(e.description, style: EventTheme.bodyStyle),
        const SizedBox(height: 20),

        // Infos principales
        _InfoCard(children: [
          _InfoRow(icon: Icons.calendar_today_outlined,
              label: 'Début',    value: _fmt(e.startDate)),
          _InfoRow(icon: Icons.event_outlined,
              label: 'Fin',      value: _fmt(e.endDate)),
          if (e.registrationDeadline != null)
            _InfoRow(icon: Icons.timer_outlined,
                label: 'Limite inscription',
                value: _fmt(e.registrationDeadline!)),
          _InfoRow(icon: Icons.category_outlined,
              label: 'Catégorie', value: e.category),
          _InfoRow(icon: _modeIcon(e.mode),
              label: 'Mode',
              value: EventModel.modeLabels[e.mode] ?? e.mode),
          _InfoRow(icon: Icons.people_outline,
              label: 'Capacité',
              value: '${e.capacity} places ($_availableSpots disponibles)'),
          _InfoRow(icon: Icons.payments_outlined,
              label: 'Prix',
              value: e.price > 0
                  ? '${e.price.toStringAsFixed(0)} DZD'
                  : 'Gratuit'),
        ]),

        // Lieu
        if (e.location != null || e.address != null || e.onlineLink != null) ...[
          const SizedBox(height: 16),
          _SectionTitle('Lieu et accès'),
          _InfoCard(children: [
            if (e.location != null)
              _InfoRow(icon: Icons.location_on_outlined,
                  label: 'Lieu', value: e.location!),
            if (e.address != null)
              _InfoRow(icon: Icons.map_outlined,
                  label: 'Adresse', value: e.address!),
            if (e.onlineLink != null)
              _InfoRow(icon: Icons.link,
                  label: 'Lien', value: e.onlineLink!),
          ]),
        ],

        // Programme
        if (e.program != null) ...[
          const SizedBox(height: 16),
          _SectionTitle('Programme'),
          _TextBlock(e.program!),
        ],

        // Règlement
        if (e.rules != null) ...[
          const SizedBox(height: 16),
          _SectionTitle('Règlement'),
          _TextBlock(e.rules!),
        ],

        // Contact
        if (e.contactEmail != null || e.contactPhone != null) ...[
          const SizedBox(height: 16),
          _SectionTitle('Contact'),
          _InfoCard(children: [
            if (e.contactEmail != null)
              _InfoRow(icon: Icons.email_outlined,
                  label: 'E-mail', value: e.contactEmail!),
            if (e.contactPhone != null)
              _InfoRow(icon: Icons.phone_outlined,
                  label: 'Tél.', value: e.contactPhone!),
          ]),
        ],

        const SizedBox(height: 24),

        // Bouton inscription
        if (widget.currentUserId != null)
          _alreadyRegistered
              ? OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: EventTheme.error,
                      side: const BorderSide(color: EventTheme.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _regLoading ? null : _cancelRegistration,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Annuler mon inscription',
                      style: TextStyle(
                          fontFamily: EventTheme.fontFamily,
                          fontWeight: FontWeight.bold)))
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: EventTheme.mint,
                      foregroundColor: EventTheme.bg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: (_regLoading || _availableSpots <= 0)
                      ? null
                      : _register,
                  icon: _regLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: EventTheme.bg))
                      : const Icon(Icons.how_to_reg_outlined),
                  label: Text(
                      _availableSpots <= 0 ? 'Complet' : 'S\'inscrire',
                      style: const TextStyle(
                          fontFamily: EventTheme.fontFamily,
                          fontWeight: FontWeight.bold))),

        const SizedBox(height: 40),
      ],
    );
  }

  String _fmt(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'enligne': return Icons.videocam_outlined;
      case 'hybride': return Icons.merge_type;
      default:        return Icons.location_city_outlined;
    }
  }
}

// ─── Sous-widgets ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label,
          style: TextStyle(fontFamily: EventTheme.fontFamily,
              fontSize: 12, fontWeight: FontWeight.w600, color: color)));
}

class _SectionTitle extends StatelessWidget {
  final String title; const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: EventTheme.sectionTitle));
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children; const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: EventTheme.cardDecoration,
      child: Column(
          children: children
              .expand((w) =>
                  [w, const Divider(color: EventTheme.surfaceHigh, height: 1)])
              .take(children.length * 2 - 1)
              .toList()));
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: EventTheme.mint),
        const SizedBox(width: 12),
        Text('$label : ',
            style:
                EventTheme.labelStyle.copyWith(color: EventTheme.textSoft)),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontFamily: EventTheme.fontFamily,
                    fontSize: 13,
                    color: EventTheme.text))),
      ]));
}

class _TextBlock extends StatelessWidget {
  final String text; const _TextBlock(this.text);
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: EventTheme.cardDecoration,
      child: Text(text, style: EventTheme.bodyStyle.copyWith(height: 1.6)));
}
