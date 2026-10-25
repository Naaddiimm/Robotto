import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import '../widgets/event_theme.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';

/// Liste des événements (type='event') avec recherche, filtres et CRUD.
/// Utilisé dans l'onglet 0 de EventModule — pas de Scaffold ni SafeArea propres.
class EventListScreen extends StatefulWidget {
  final int? currentUserId;
  const EventListScreen({super.key, this.currentUserId});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _service = EventService();

  List<EventModel> _all = [];
  List<EventModel> _filtered = [];
  bool _loading = true;

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedMode;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Données
  // -------------------------------------------------------------------------

  Future<void> _load() async {
    setState(() => _loading = true);
    // Charge uniquement les events (pas les compétitions)
    final all = widget.currentUserId != null
        ? await _service.getAllEvents()
        : await _service.getPublishedEvents();
    final events = all.where((e) => e.type == 'event').toList();
    if (mounted) {
      setState(() {
        _all = events;
        _loading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filtered = _all.where((e) {
        if (_selectedCategory != null && e.category != _selectedCategory)
          return false;
        if (_selectedLevel != null && e.level != _selectedLevel) return false;
        if (_selectedMode != null && e.mode != _selectedMode) return false;
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          return e.title.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q) ||
              (e.location?.toLowerCase().contains(q) ?? false);
        }
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedLevel = null;
      _selectedMode = null;
      _searchQuery = '';
      _searchCtrl.clear();
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _selectedLevel != null ||
      _selectedMode != null ||
      _searchQuery.isNotEmpty;

  // -------------------------------------------------------------------------
  // Navigation
  // -------------------------------------------------------------------------

  Future<void> _openDetail(EventModel e) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(
          eventId: e.id!,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
    if (changed == true) _load();
  }

  Future<void> _openCreate() async {
    if (widget.currentUserId == null) return;
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(organizerId: widget.currentUserId!),
      ),
    );
    if (created == true) _load();
  }

  Future<void> _openEdit(EventModel e) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          organizerId: widget.currentUserId!,
          existingEvent: e,
        ),
      ),
    );
    if (changed == true) _load();
  }

  Future<void> _confirmDelete(EventModel e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EventTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer l\'événement',
          style: TextStyle(
            fontFamily: EventTheme.fontFamily,
            color: EventTheme.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Supprimer « ${e.title} » ? Action irréversible.',
          style: EventTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontFamily: EventTheme.fontFamily,
                color: EventTheme.textSoft,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: EventTheme.error.withValues(alpha: 0.15),
              foregroundColor: EventTheme.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(
                fontFamily: EventTheme.fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await _service.deleteEvent(
      e.id!,
      widget.currentUserId!,
      e.organizerId,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Événement supprimé.',
            style: TextStyle(fontFamily: EventTheme.fontFamily),
          ),
          backgroundColor: EventTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Erreur.',
            style: const TextStyle(fontFamily: EventTheme.fontFamily),
          ),
          backgroundColor: EventTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Barre d'actions : recherche + bouton Créer ──────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                    color: EventTheme.text,
                    fontFamily: EventTheme.fontFamily,
                  ),
                  decoration: EventTheme.inputDecoration(
                    label: 'Rechercher un événement…',
                    prefix: const Icon(
                      Icons.search,
                      color: EventTheme.textSoft,
                      size: 20,
                    ),
                    suffix: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                              _applyFilters();
                            },
                            child: const Icon(
                              Icons.close,
                              color: EventTheme.textSoft,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                  onChanged: (v) {
                    setState(() => _searchQuery = v);
                    _applyFilters();
                  },
                ),
              ),

              // Bouton Créer — toujours visible dans le header
              if (widget.currentUserId != null) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EventTheme.mint,
                    foregroundColor: EventTheme.bg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  onPressed: _openCreate,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Créer',
                    style: TextStyle(
                      fontFamily: EventTheme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Chips de filtre
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _Chip(
                label: _selectedCategory ?? 'Catégorie',
                active: _selectedCategory != null,
                onTap: () => _showSheet(
                  'Catégorie',
                  {for (var c in EventModel.categories) c: c},
                  _selectedCategory,
                  (v) => setState(() {
                    _selectedCategory = v;
                    _applyFilters();
                  }),
                ),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: _selectedLevel != null
                    ? (EventModel.levelLabels[_selectedLevel] ??
                          _selectedLevel!)
                    : 'Niveau',
                active: _selectedLevel != null,
                onTap: () => _showSheet(
                  'Niveau',
                  EventModel.levelLabels,
                  _selectedLevel,
                  (v) => setState(() {
                    _selectedLevel = v;
                    _applyFilters();
                  }),
                ),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: _selectedMode != null
                    ? (EventModel.modeLabels[_selectedMode] ?? _selectedMode!)
                    : 'Mode',
                active: _selectedMode != null,
                onTap: () => _showSheet(
                  'Mode',
                  EventModel.modeLabels,
                  _selectedMode,
                  (v) => setState(() {
                    _selectedMode = v;
                    _applyFilters();
                  }),
                ),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                _Chip(
                  label: 'Effacer',
                  active: false,
                  onTap: _clearFilters,
                  icon: Icons.filter_alt_off_outlined,
                  activeColor: EventTheme.warning,
                ),
              ],
            ],
          ),
        ),

        // Liste
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: EventTheme.mint),
                )
              : _filtered.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: EventTheme.mint,
                  backgroundColor: EventTheme.surfaceHigh,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final e = _filtered[i];
                      return EventCard(
                        event: e,
                        onTap: () => _openDetail(e),
                        onEdit: widget.currentUserId != null
                            ? () => _openEdit(e)
                            : null,
                        onDelete: widget.currentUserId != null
                            ? () => _confirmDelete(e)
                            : null,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // État vide
  // -------------------------------------------------------------------------

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_outlined,
              size: 72,
              color: EventTheme.textSoft.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilters
                  ? 'Aucun résultat pour ces filtres.'
                  : 'Aucun événement disponible.',
              style: EventTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            if (widget.currentUserId != null && !_hasActiveFilters) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EventTheme.mint,
                  foregroundColor: EventTheme.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Créer mon premier événement',
                  style: TextStyle(
                    fontFamily: EventTheme.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Bottom sheet filtre
  // -------------------------------------------------------------------------

  void _showSheet<T>(
    String title,
    Map<T, String> options,
    T? current,
    ValueChanged<T?> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EventTheme.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: EventTheme.sectionTitle),
            const SizedBox(height: 12),
            ListTile(
              title: const Text(
                'Tous',
                style: TextStyle(
                  fontFamily: EventTheme.fontFamily,
                  color: EventTheme.text,
                ),
              ),
              trailing: current == null
                  ? const Icon(Icons.check, color: EventTheme.mint)
                  : null,
              onTap: () {
                onSelected(null);
                Navigator.pop(context);
              },
            ),
            ...options.entries.map(
              (entry) => ListTile(
                title: Text(
                  entry.value,
                  style: const TextStyle(
                    fontFamily: EventTheme.fontFamily,
                    color: EventTheme.text,
                  ),
                ),
                trailing: current == entry.key
                    ? const Icon(Icons.check, color: EventTheme.mint)
                    : null,
                onTap: () {
                  onSelected(entry.key);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Chip de filtre ───────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? activeColor;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? EventTheme.mint;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.15)
              : EventTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.6)
                : EventTheme.textSoft.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: active ? color : EventTheme.textSoft),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: EventTheme.fontFamily,
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? color : EventTheme.textSoft,
              ),
            ),
            if (icon == null) ...[
              const SizedBox(width: 4),
              Icon(
                active ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 16,
                color: active ? color : EventTheme.textSoft,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
