import 'package:flutter/material.dart';
import '../models/event_registration.dart';
import '../services/registration_service.dart';
import '../widgets/event_theme.dart';
import 'event_detail_screen.dart';
import 'competition_detail_screen.dart';
import 'ticket_screen.dart';

/// Écran "Mes inscriptions" : liste toutes les inscriptions de l'utilisateur.
class MyRegistrationsScreen extends StatefulWidget {
  final int currentUserId;
  const MyRegistrationsScreen({super.key, required this.currentUserId});

  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> {
  final _service = RegistrationService();
  List<EventRegistration> _registrations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.getMyRegistrations(widget.currentUserId);
    if (mounted) setState(() { _registrations = list; _loading = false; });
  }

  Future<void> _cancel(EventRegistration reg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EventTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler l\'inscription',
            style: TextStyle(fontFamily: EventTheme.fontFamily,
                color: EventTheme.text, fontWeight: FontWeight.bold)),
        content: Text(
            'Annuler votre inscription à « ${reg.eventTitle ?? 'cet événement'} » ?',
            style: EventTheme.bodyStyle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Non', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, color: EventTheme.textSoft))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: EventTheme.error.withValues(alpha: 0.15),
                  foregroundColor: EventTheme.error, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Annuler l\'inscription', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await _service.cancel(
        eventId: reg.eventId, userId: widget.currentUserId);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Inscription annulée.',
              style: TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.success,
          behavior: SnackBarBehavior.floating));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.error ?? 'Erreur.',
              style: const TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.error,
          behavior: SnackBarBehavior.floating));
    }
  }

  void _openEvent(EventRegistration reg) {
    final isCompetition = reg.eventType == 'competition';
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => isCompetition
            ? CompetitionDetailScreen(
                eventId: reg.eventId,
                currentUserId: widget.currentUserId)
            : EventDetailScreen(
                eventId: reg.eventId,
                currentUserId: widget.currentUserId)));
  }

  void _openTicket(EventRegistration reg) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => TicketScreen(registration: reg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: const Text('Mes inscriptions', style: EventTheme.titleStyle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: EventTheme.mint))
          : _registrations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 64,
                          color: EventTheme.textSoft.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('Aucune inscription.',
                          style: EventTheme.bodyStyle),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: EventTheme.mint,
                  backgroundColor: EventTheme.surfaceHigh,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(EventTheme.screenPadding),
                    itemCount: _registrations.length,
                    itemBuilder: (_, i) => _RegCard(
                      reg: _registrations[i],
                      onTap: () => _openEvent(_registrations[i]),
                      onTicket: _registrations[i].status == 'confirmed'
                          ? () => _openTicket(_registrations[i])
                          : null,
                      onCancel: _registrations[i].status == 'confirmed'
                          ? () => _cancel(_registrations[i])
                          : null,
                    ),
                  ),
                ),
    );
  }
}

class _RegCard extends StatelessWidget {
  final EventRegistration reg;
  final VoidCallback onTap;
  final VoidCallback? onTicket;
  final VoidCallback? onCancel;

  const _RegCard({required this.reg, required this.onTap, this.onTicket, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final statusColor = reg.status == 'confirmed'
        ? EventTheme.success
        : reg.status == 'cancelled'
            ? EventTheme.error
            : EventTheme.warning;

    final dt = reg.eventStartDate != null
        ? DateTime.tryParse(reg.eventStartDate!)
        : null;
    final dateLabel = dt != null
        ? '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}'
        : '';

    final isCompetition = reg.eventType == 'competition';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: EventTheme.itemSpacing),
        decoration: EventTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Bande couleur statut
          Container(
            height: 4,
            decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(EventTheme.cardRadius)))),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _Badge(
                    label: isCompetition ? 'Compétition' : 'Événement',
                    color: isCompetition ? EventTheme.warning : EventTheme.mint),
                const SizedBox(width: 6),
                _Badge(
                    label: EventRegistration.statusLabels[reg.status] ?? reg.status,
                    color: statusColor),
                const Spacer(),
                if (onCancel != null)
                  GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: EventTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('Annuler',
                          style: TextStyle(fontFamily: EventTheme.fontFamily,
                              fontSize: 11, color: EventTheme.error,
                              fontWeight: FontWeight.bold)))),
              ]),
              const SizedBox(height: 10),
              Text(reg.eventTitle ?? 'Événement #${reg.eventId}',
                  style: EventTheme.titleStyle.copyWith(fontSize: 15),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              if (dateLabel.isNotEmpty)
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: EventTheme.textSoft),
                  const SizedBox(width: 4),
                  Text(dateLabel, style: EventTheme.labelStyle),
                ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.confirmation_number_outlined,
                    size: 13, color: EventTheme.textSoft),
                const SizedBox(width: 4),
                Text(reg.ticketCode ?? 'Billet #${reg.id}',
                    style: EventTheme.labelStyle.copyWith(fontSize: 11)),
              ]),
              // Bouton Mon billet (inscriptions confirmées uniquement)
              if (onTicket != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EventTheme.mint,
                      side: BorderSide(
                          color: EventTheme.mint.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onTicket,
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text(
                      'Mon billet',
                      style: TextStyle(
                          fontFamily: EventTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4))),
    child: Text(label, style: TextStyle(fontFamily: EventTheme.fontFamily,
        fontSize: 11, fontWeight: FontWeight.w600, color: color)));
}
