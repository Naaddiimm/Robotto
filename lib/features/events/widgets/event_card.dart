import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'event_theme.dart';

/// Carte réutilisable affichant un résumé d'événement ou de compétition.
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.tryParse(event.startDate);
    final dateLabel = startDate != null
        ? '${startDate.day.toString().padLeft(2, '0')}/'
          '${startDate.month.toString().padLeft(2, '0')}/'
          '${startDate.year}'
        : event.startDate;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: EventTheme.itemSpacing),
        decoration: EventTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bande supérieure colorée selon le type
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: EventTheme.typeColor(event.type),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(EventTheme.cardRadius),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges + actions
                  Row(
                    children: [
                      _Badge(
                        label: event.isCompetition ? 'Compétition' : 'Événement',
                        color: EventTheme.typeColor(event.type),
                      ),
                      const SizedBox(width: 6),
                      _Badge(
                        label: EventModel.statusLabels[event.status] ?? event.status,
                        color: EventTheme.statusColor(event.status),
                      ),
                      const Spacer(),
                      if (onEdit != null)
                        _IconBtn(
                          icon: Icons.edit_outlined,
                          color: EventTheme.mint,
                          onTap: onEdit!,
                          tooltip: 'Modifier',
                        ),
                      if (onDelete != null)
                        _IconBtn(
                          icon: Icons.delete_outline,
                          color: EventTheme.error,
                          onTap: onDelete!,
                          tooltip: 'Supprimer',
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Titre
                  Text(
                    event.title,
                    style: EventTheme.titleStyle.copyWith(fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Méta-infos
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: dateLabel,
                      ),
                      _MetaChip(
                        icon: _modeIcon(event.mode),
                        label: EventModel.modeLabels[event.mode] ?? event.mode,
                      ),
                      if (event.location != null &&
                          event.location!.isNotEmpty)
                        _MetaChip(
                          icon: Icons.location_on_outlined,
                          label: event.location!,
                        ),
                      _MetaChip(
                        icon: Icons.people_outline,
                        label: '${event.capacity} places',
                      ),
                      if (event.price > 0)
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: '${event.price.toStringAsFixed(0)} DZD',
                        )
                      else
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: 'Gratuit',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'enligne':   return Icons.videocam_outlined;
      case 'hybride':   return Icons.merge_type;
      default:          return Icons.location_city_outlined;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: EventTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: EventTheme.textSoft),
        const SizedBox(width: 4),
        Text(
          label,
          style: EventTheme.labelStyle.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;
  const _IconBtn(
      {required this.icon,
      required this.color,
      required this.onTap,
      required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
