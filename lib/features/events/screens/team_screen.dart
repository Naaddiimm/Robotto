import 'package:flutter/material.dart';
import '../models/event_team.dart';
import '../services/team_service.dart';
import '../widgets/event_theme.dart';

/// Écran de gestion des équipes d'une compétition.
class TeamScreen extends StatefulWidget {
  final int eventId;
  final int currentUserId;
  const TeamScreen({super.key, required this.eventId, required this.currentUserId});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _service = TeamService();
  List<EventTeam> _teams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.getTeams(widget.eventId);
    if (mounted) setState(() { _teams = list; _loading = false; });
  }

  // ── Créer une équipe ──────────────────────────────────────────────────────
  Future<void> _createTeam() async {
    final name = await _nameDialog(title: 'Nouvelle équipe');
    if (name == null || !mounted) return;
    final result = await _service.createTeam(
        eventId: widget.eventId,
        name: name,
        leaderId: widget.currentUserId);
    if (!mounted) return;
    if (result.isSuccess) {
      _showOk('Équipe créée.');
      _load();
    } else {
      _showErr(result.error!);
    }
  }

  // ── Renommer ──────────────────────────────────────────────────────────────
  Future<void> _renameTeam(EventTeam team) async {
    final name = await _nameDialog(title: 'Renommer l\'équipe', initial: team.name);
    if (name == null || !mounted) return;
    final result = await _service.renameTeam(team.id!, name);
    if (!mounted) return;
    if (result.isSuccess) { _showOk('Équipe renommée.'); _load(); } else { _showErr(result.error!); }
  }

  // ── Supprimer ─────────────────────────────────────────────────────────────
  Future<void> _deleteTeam(EventTeam team) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EventTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer l\'équipe',
            style: TextStyle(fontFamily: EventTheme.fontFamily,
                color: EventTheme.text, fontWeight: FontWeight.bold)),
        content: Text('Supprimer « ${team.name} » ? Tous les membres seront retirés.',
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
    ) ?? false;
    if (!ok || !mounted) return;
    final result = await _service.deleteTeam(team.id!);
    if (!mounted) return;
    if (result.isSuccess) { _showOk('Équipe supprimée.'); _load(); } else { _showErr(result.error!); }
  }

  // ── Gérer les membres ────────────────────────────────────────────────────
  Future<void> _manageMembers(EventTeam team) async {
    await Navigator.push(context, MaterialPageRoute(
        builder: (_) => _TeamMembersScreen(
            team: team, currentUserId: widget.currentUserId)));
    _load();
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────
  Future<String?> _nameDialog({required String title, String? initial}) async {
    final ctrl = TextEditingController(text: initial ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EventTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontFamily: EventTheme.fontFamily,
            color: EventTheme.text, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
          decoration: EventTheme.inputDecoration(label: 'Nom de l\'équipe'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, color: EventTheme.textSoft))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: EventTheme.mint,
                  foregroundColor: EventTheme.bg, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Valider', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    ctrl.dispose();
    return (result?.trim().isEmpty ?? true) ? null : result?.trim();
  }

  void _showOk(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: EventTheme.fontFamily)),
      backgroundColor: EventTheme.success, behavior: SnackBarBehavior.floating));

  void _showErr(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: EventTheme.fontFamily)),
      backgroundColor: EventTheme.error, behavior: SnackBarBehavior.floating));

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: const Text('Équipes', style: EventTheme.titleStyle),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: EventTheme.mint,
        foregroundColor: EventTheme.bg,
        onPressed: _createTeam,
        tooltip: 'Créer une équipe',
        child: const Icon(Icons.group_add_outlined),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: EventTheme.mint))
          : _teams.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.group_outlined, size: 64,
                      color: EventTheme.textSoft.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('Aucune équipe.', style: EventTheme.bodyStyle),
                ]))
              : RefreshIndicator(
                  color: EventTheme.mint,
                  backgroundColor: EventTheme.surfaceHigh,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(EventTheme.screenPadding),
                    itemCount: _teams.length,
                    itemBuilder: (_, i) => _TeamCard(
                      team: _teams[i],
                      currentUserId: widget.currentUserId,
                      onManage: () => _manageMembers(_teams[i]),
                      onRename: () => _renameTeam(_teams[i]),
                      onDelete: () => _deleteTeam(_teams[i]),
                    ),
                  ),
                ),
    );
  }
}

// ─── Carte équipe ─────────────────────────────────────────────────────────
class _TeamCard extends StatelessWidget {
  final EventTeam team;
  final int currentUserId;
  final VoidCallback onManage, onRename, onDelete;
  const _TeamCard({required this.team, required this.currentUserId,
      required this.onManage, required this.onRename, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: EventTheme.itemSpacing),
      decoration: EventTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.group_outlined, color: EventTheme.mint, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(team.name,
                style: EventTheme.sectionTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (team.memberCount != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: EventTheme.mint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${team.memberCount} membre(s)',
                    style: const TextStyle(fontFamily: EventTheme.fontFamily,
                        fontSize: 11, color: EventTheme.mint))),
          ]),
          const SizedBox(height: 4),
          Text('Leader ID : ${team.leaderId}',
              style: EventTheme.labelStyle.copyWith(fontSize: 11)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: EventTheme.mint,
                  side: const BorderSide(color: EventTheme.mint),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8)),
              onPressed: onManage,
              icon: const Icon(Icons.people_outline, size: 16),
              label: const Text('Membres', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, fontSize: 12)))),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18),
                color: EventTheme.mint, onPressed: onRename, tooltip: 'Renommer'),
            IconButton(icon: const Icon(Icons.delete_outline, size: 18),
                color: EventTheme.error, onPressed: onDelete, tooltip: 'Supprimer'),
          ]),
        ]),
      ),
    );
  }
}

// ─── Écran membres d'une équipe ───────────────────────────────────────────
class _TeamMembersScreen extends StatefulWidget {
  final EventTeam team;
  final int currentUserId;
  const _TeamMembersScreen({required this.team, required this.currentUserId});

  @override
  State<_TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<_TeamMembersScreen> {
  final _service = TeamService();
  List<EventTeamMember> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.getMembers(widget.team.id!);
    if (mounted) setState(() { _members = list; _loading = false; });
  }

  Future<void> _addMember() async {
    final ctrl = TextEditingController();
    final userIdStr = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EventTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ajouter un membre',
            style: TextStyle(fontFamily: EventTheme.fontFamily,
                color: EventTheme.text, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: EventTheme.text, fontFamily: EventTheme.fontFamily),
          decoration: EventTheme.inputDecoration(label: 'ID utilisateur'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, color: EventTheme.textSoft))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: EventTheme.mint, foregroundColor: EventTheme.bg,
                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Ajouter', style: TextStyle(
                  fontFamily: EventTheme.fontFamily, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    ctrl.dispose();
    if (userIdStr == null || userIdStr.trim().isEmpty || !mounted) return;
    final userId = int.tryParse(userIdStr.trim());
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('ID invalide.', style: TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.error, behavior: SnackBarBehavior.floating));
      return;
    }
    final result = await _service.addMember(widget.team.id!, userId);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Membre ajouté.', style: TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.success, behavior: SnackBarBehavior.floating));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.error ?? 'Erreur.',
              style: const TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.error, behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _removeMember(EventTeamMember m) async {
    if (m.userId == widget.team.leaderId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible de retirer le leader.',
              style: TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.error, behavior: SnackBarBehavior.floating));
      return;
    }
    final result = await _service.removeMember(widget.team.id!, m.userId);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Membre retiré.', style: TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.success, behavior: SnackBarBehavior.floating));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.error ?? 'Erreur.',
              style: const TextStyle(fontFamily: EventTheme.fontFamily)),
          backgroundColor: EventTheme.error, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: Text('Équipe : ${widget.team.name}', style: EventTheme.titleStyle),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: EventTheme.mint,
        foregroundColor: EventTheme.bg,
        onPressed: _addMember,
        tooltip: 'Ajouter un membre',
        child: const Icon(Icons.person_add_outlined),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: EventTheme.mint))
          : _members.isEmpty
              ? const Center(child: Text('Aucun membre.', style: EventTheme.bodyStyle))
              : ListView.builder(
                  padding: const EdgeInsets.all(EventTheme.screenPadding),
                  itemCount: _members.length,
                  itemBuilder: (_, i) {
                    final m = _members[i];
                    final isLeader = m.userId == widget.team.leaderId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: EventTheme.cardDecoration,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLeader
                              ? EventTheme.mint.withValues(alpha: 0.2)
                              : EventTheme.surfaceHigh,
                          child: Icon(
                              isLeader ? Icons.star_outline : Icons.person_outline,
                              color: isLeader ? EventTheme.mint : EventTheme.textSoft,
                              size: 20)),
                        title: Text('Utilisateur #${m.userId}',
                            style: const TextStyle(fontFamily: EventTheme.fontFamily,
                                color: EventTheme.text, fontSize: 14)),
                        subtitle: Text(isLeader ? 'Leader' : 'Membre',
                            style: TextStyle(fontFamily: EventTheme.fontFamily,
                                fontSize: 12,
                                color: isLeader ? EventTheme.mint : EventTheme.textSoft)),
                        trailing: !isLeader
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: EventTheme.error, size: 20),
                                onPressed: () => _removeMember(m),
                                tooltip: 'Retirer')
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
