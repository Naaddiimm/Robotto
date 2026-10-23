import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/competition_service.dart';
import '../widgets/event_card.dart';
import '../widgets/event_theme.dart';
import 'competition_detail_screen.dart';
import 'competition_form_screen.dart';

/// Liste des compétitions avec recherche, filtres et accès au CRUD.
class CompetitionListScreen extends StatefulWidget {
  final int? currentUserId;
  const CompetitionListScreen({super.key, this.currentUserId});

  @override
  State<CompetitionListScreen> createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> {
  final _service = CompetitionService();
  List<EventModel> _all      = [];
  List<EventModel> _filtered = [];
  bool _loading = true;

  String _searchQuery      = '';
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

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = widget.currentUserId != null
        ? await _service.getAllCompetitions()
        : await _service.getPublishedCompetitions();
    if (mounted) {
      setState(() { _all = list; _loading = false; });
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filtered = _all.where((e) {
        if (_selectedCategory != null && e.category != _selectedCategory) return false;
        if (_selectedLevel != null    && e.level    != _selectedLevel)    return false;
        if (_selectedMode != null     && e.mode     != _selectedMode)     return false;
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
      _selectedLevel    = null;
      _selectedMode     = null;
      _searchQuery      = '';
      _searchCtrl.clear();
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null || _selectedLevel != null ||
      _selectedMode != null || _searchQuery.isNotEmpty;

  Future<void> _openDetail(EventModel e) async {
    final changed = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => CompetitionDetailScreen(
            eventId: e.id!, currentUserId: widget.currentUserId)));
    if (changed == true) _load();
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => CompetitionFormScreen(
            organizerId: widget.currentUserId!)));
    if (created == true) _load();
  }

  Future<void> _openEdit(EventModel e) async {
    final svc    = CompetitionService();
    final detail = await svc.getDetail(e.id!);
    if (!mounted) return;
    final changed = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => CompetitionFormScreen(
            organizerId: widget.currentUserId!,
            existingEvent: e, existingDetail: detail)));
    if (changed == true) _load();
  }

  Future<void> _confirmDelete(EventModel e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EventTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la compétition',
            style: TextStyle(fontFamily: EventTheme.fontFamily,
                color: EventTheme.text, fontWeight: FontWeight.bold)),
        content: Text('Supprimer « ${e.title} » ? Action irréversible.',
            style: EventTheme.bodyStyle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, color: EventTheme.textSoft))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: EventTheme.error.withValues(alpha: 0.15),
                foregroundColor: EventTheme.error, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(
                fontFamily: EventTheme.fontFamily, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await CompetitionService().deleteCompetition(e.id!);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Compétition supprimée.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: const Text('Compétitions', style: EventTheme.titleStyle),
        actions: [
          if (_hasActiveFilters)
            TextButton(onPressed: _clearFilters,
                child: const Text('Tout', style: TextStyle(
                    fontFamily: EventTheme.fontFamily,
                    fontSize: 12, color: EventTheme.warning))),
        ],
      ),
      floatingActionButton: widget.currentUserId != null
          ? FloatingActionButton(
              backgroundColor: EventTheme.warning,
              foregroundColor: EventTheme.bg,
              onPressed: _openCreate,
              tooltip: 'Nouvelle compétition',
              child: const Icon(Icons.add))
          : null,
      body: Column(children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
            decoration: EventTheme.inputDecoration(
              label: 'Rechercher…',
              prefix: const Icon(Icons.search, color: EventTheme.textSoft, size: 20),
              suffix: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); _applyFilters(); },
                      child: const Icon(Icons.close, color: EventTheme.textSoft, size: 18))
                  : null,
            ),
            onChanged: (v) { setState(() => _searchQuery = v); _applyFilters(); },
          ),
        ),

        // Filtres
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _Chip(label: _selectedCategory ?? 'Catégorie',
                active: _selectedCategory != null,
                onTap: () => _showSheet('Catégorie',
                    {for (var c in EventModel.categories) c: c},
                    _selectedCategory,
                    (v) => setState(() { _selectedCategory = v; _applyFilters(); }))),
            const SizedBox(width: 8),
            _Chip(label: _selectedLevel != null
                    ? (EventModel.levelLabels[_selectedLevel] ?? _selectedLevel!)
                    : 'Niveau',
                active: _selectedLevel != null,
                onTap: () => _showSheet('Niveau', EventModel.levelLabels,
                    _selectedLevel,
                    (v) => setState(() { _selectedLevel = v; _applyFilters(); }))),
            const SizedBox(width: 8),
            _Chip(label: _selectedMode != null
                    ? (EventModel.modeLabels[_selectedMode] ?? _selectedMode!)
                    : 'Mode',
                active: _selectedMode != null,
                onTap: () => _showSheet('Mode', EventModel.modeLabels,
                    _selectedMode,
                    (v) => setState(() { _selectedMode = v; _applyFilters(); }))),
          ]),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: EventTheme.warning))
              : _filtered.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64,
                            color: EventTheme.textSoft.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(_hasActiveFilters
                            ? 'Aucune compétition pour ces filtres.'
                            : 'Aucune compétition disponible.',
                            style: EventTheme.bodyStyle),
                        if (widget.currentUserId != null && !_hasActiveFilters) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: EventTheme.warning,
                                  foregroundColor: EventTheme.bg),
                              onPressed: _openCreate,
                              icon: const Icon(Icons.add),
                              label: const Text('Créer une compétition',
                                  style: TextStyle(fontFamily: EventTheme.fontFamily,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ]))
                  : RefreshIndicator(
                      color: EventTheme.warning,
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
                            onEdit: widget.currentUserId != null ? () => _openEdit(e) : null,
                            onDelete: widget.currentUserId != null ? () => _confirmDelete(e) : null,
                          );
                        },
                      )),
        ),
      ]),
    );
  }

  void _showSheet<T>(String title, Map<T, String> options, T? current,
      ValueChanged<T?> onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EventTheme.surfaceHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: EventTheme.sectionTitle),
          const SizedBox(height: 12),
          ListTile(
              title: const Text('Tous', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, color: EventTheme.text)),
              trailing: current == null ? const Icon(Icons.check, color: EventTheme.mint) : null,
              onTap: () { onSelected(null); Navigator.pop(context); }),
          ...options.entries.map((entry) => ListTile(
              title: Text(entry.value, style: const TextStyle(
                  fontFamily: EventTheme.fontFamily, color: EventTheme.text)),
              trailing: current == entry.key
                  ? const Icon(Icons.check, color: EventTheme.mint) : null,
              onTap: () { onSelected(entry.key); Navigator.pop(context); })),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? EventTheme.warning.withValues(alpha: 0.15) : EventTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active
            ? EventTheme.warning.withValues(alpha: 0.6)
            : EventTheme.textSoft.withValues(alpha: 0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: TextStyle(fontFamily: EventTheme.fontFamily,
            fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? EventTheme.warning : EventTheme.textSoft)),
        const SizedBox(width: 4),
        Icon(active ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 16,
            color: active ? EventTheme.warning : EventTheme.textSoft),
      ])));
}
