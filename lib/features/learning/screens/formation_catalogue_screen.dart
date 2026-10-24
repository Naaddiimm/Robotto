import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';
import 'formation_detail_screen.dart';
import 'formation_ajout_screen.dart';

class FormationCatalogueScreen extends StatefulWidget {
  const FormationCatalogueScreen({super.key});

  @override
  State<FormationCatalogueScreen> createState() =>
      _FormationCatalogueScreenState();
}

class _FormationCatalogueScreenState extends State<FormationCatalogueScreen> {
  final List<FormationModel> _formations = List.from(kSampleFormations);

  void _openEdit(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormationAjoutScreen(
          initialFormation: _formations[index],
          onSave: (updated) => setState(() => _formations[index] = updated),
        ),
      ),
    );
  }

  void _delete(int index) {
    final removed = _formations[index];
    setState(() => _formations.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: LearningTheme.surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(children: [
        const Icon(Icons.delete_outline_rounded, color: LearningTheme.error, size: 18),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('Formation supprimée',
              style: TextStyle(fontFamily: LearningTheme.font, color: Colors.white)),
        ),
        GestureDetector(
          onTap: () {
            setState(() => _formations.insert(index, removed));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: const Text('Annuler',
              style: TextStyle(
                  fontFamily: LearningTheme.font,
                  color: LearningTheme.mint,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Action buttons ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormationAjoutScreen(
                        onSave: (f) => setState(() => _formations.add(f)),
                      ),
                    ),
                  ),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: LearningTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: LearningTheme.mint),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: LearningTheme.mint, size: 20),
                        SizedBox(width: 4),
                        Text('Ajouter',
                            style: TextStyle(
                                fontFamily: LearningTheme.font,
                                color: LearningTheme.mint,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Formation cards ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 4, 16, LearningTheme.bottomNavPadding),
              itemCount: _formations.length,
              itemBuilder: (context, i) => _FormationCard(
                formation: _formations[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FormationDetailScreen(formation: _formations[i])),
                ).then((_) => setState(() {})),
                onEdit: () => _openEdit(i),
                onDelete: () => _delete(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Catalogue card ────────────────────────────────────────────────────────────
class _FormationCard extends StatelessWidget {
  final FormationModel formation;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FormationCard({
    required this.formation,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final f = formation;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: ValueKey(f.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.redAccent, size: 26),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: LearningTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Supprimer la formation',
                  style: TextStyle(fontFamily: LearningTheme.font, color: Colors.white)),
              content: Text('Voulez-vous vraiment supprimer "${f.title}" ?',
                  style: LearningTheme.bodyStyle),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler',
                      style: TextStyle(fontFamily: LearningTheme.font,
                          color: LearningTheme.textSecond)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Supprimer',
                      style: TextStyle(fontFamily: LearningTheme.font,
                          color: Colors.redAccent, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: LearningTheme.cardDeco(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: LearningTheme.mint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: LearningTheme.mint.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.school_rounded, color: LearningTheme.mint, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.title,
                              style: const TextStyle(
                                  fontFamily: LearningTheme.font,
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(f.subtitle,
                              style: LearningTheme.captionStyle,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: LearningTheme.star, size: 14),
                      const SizedBox(width: 3),
                      Text(f.rating.toString(),
                          style: const TextStyle(
                              fontFamily: LearningTheme.font,
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [
                  _badge(Icons.signal_cellular_alt_rounded, f.level, color: LearningTheme.mint),
                  const SizedBox(width: 8),
                  _badge(Icons.access_time_rounded, f.duration),
                  const SizedBox(width: 8),
                  _badge(Icons.people_rounded, '${f.enrolled} inscrits'),
                ]),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${f.doneLessons}/${f.totalLessons} leçons terminées',
                        style: LearningTheme.captionStyle),
                    Text('${(f.progress * 100).round()}%',
                        style: const TextStyle(
                            fontFamily: LearningTheme.font,
                            color: LearningTheme.mint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: LinearProgressIndicator(
                    value: f.progress,
                    minHeight: 4,
                    backgroundColor: LearningTheme.border,
                    valueColor: const AlwaysStoppedAnimation(LearningTheme.mint),
                  ),
                ),
                // ── Edit / Delete action row ──────────────────────────────
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionBtn(Icons.edit_outlined, 'Modifier', LearningTheme.mint, onEdit),
                    const SizedBox(width: 10),
                    _actionBtn(Icons.delete_outline_rounded, 'Supprimer', Colors.redAccent, onDelete),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _badge(IconData icon, String text,
          {Color color = LearningTheme.textSecond}) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(fontFamily: LearningTheme.font, color: color, fontSize: 11)),
      ]);

  static Widget _actionBtn(
          IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontFamily: LearningTheme.font,
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}
