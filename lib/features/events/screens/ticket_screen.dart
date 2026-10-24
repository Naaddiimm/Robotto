import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event_registration.dart';
import '../widgets/event_theme.dart';

/// Écran "Mon billet" : affiche le QR code de participation d'une inscription.
///
/// Accessible depuis MyRegistrationsScreen pour toute inscription confirmée.
class TicketScreen extends StatelessWidget {
  final EventRegistration registration;

  const TicketScreen({super.key, required this.registration});

  @override
  Widget build(BuildContext context) {
    final ticketCode = registration.ticketCode ?? 'TICKET-${registration.id}';
    final dt = registration.eventStartDate != null
        ? DateTime.tryParse(registration.eventStartDate!)
        : null;
    final dateLabel = dt != null
        ? '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/${dt.year}'
        : '';

    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: const Text('Mon billet', style: EventTheme.titleStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EventTheme.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // Titre de l'événement
            Text(
              registration.eventTitle ?? 'Événement #${registration.eventId}',
              style: EventTheme.titleStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Badges type + statut
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _Badge(
                  label: registration.eventType == 'competition'
                      ? 'Compétition'
                      : 'Événement',
                  color: registration.eventType == 'competition'
                      ? EventTheme.warning
                      : EventTheme.mint,
                ),
                _Badge(
                  label: EventRegistration.statusLabels[registration.status] ??
                      registration.status,
                  color: registration.status == 'confirmed'
                      ? EventTheme.success
                      : EventTheme.error,
                ),
                if (registration.isCheckedIn)
                  const _Badge(
                      label: 'Présence validée ✓', color: EventTheme.mint),
              ],
            ),
            const SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: EventTheme.mint.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: ticketCode,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 20),

            // Code textuel
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: EventTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: EventTheme.mint.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      size: 16, color: EventTheme.mint),
                  const SizedBox(width: 8),
                  Text(
                    ticketCode,
                    style: const TextStyle(
                      fontFamily: EventTheme.fontFamily,
                      fontSize: 13,
                      color: EventTheme.text,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Infos de l'événement
            _InfoCard(children: [
              if (dateLabel.isNotEmpty)
                _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: dateLabel),
              _InfoRow(
                  icon: Icons.tag_outlined,
                  label: 'ID Inscription',
                  value: '#${registration.id}'),
              if (registration.isCheckedIn &&
                  registration.checkedInAt != null)
                _InfoRow(
                    icon: Icons.check_circle_outline,
                    label: 'Validé le',
                    value: _fmtDateTime(registration.checkedInAt!)),
            ]),
            const SizedBox(height: 20),

            // Note version locale
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EventTheme.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: EventTheme.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: EventTheme.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Version locale : ce billet est validé via la base '
                      'SQLite du téléphone de l\'organisateur. '
                      'Présentez ce QR code à l\'entrée de l\'événement.',
                      style: EventTheme.labelStyle.copyWith(
                          color: EventTheme.warning, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _fmtDateTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Sous-widgets ────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: EventTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color)),
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: EventTheme.cardDecoration,
        child: Column(
            children: children
                .expand((w) => [
                      w,
                      const Divider(color: EventTheme.surfaceHigh, height: 1)
                    ])
                .take(children.length * 2 - 1)
                .toList()),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: EventTheme.mint),
          const SizedBox(width: 10),
          Text('$label : ',
              style:
                  EventTheme.labelStyle.copyWith(color: EventTheme.textSoft)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontFamily: EventTheme.fontFamily,
                      fontSize: 13,
                      color: EventTheme.text))),
        ]),
      );
}
