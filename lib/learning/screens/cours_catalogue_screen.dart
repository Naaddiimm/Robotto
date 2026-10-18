import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';
import 'cours_detail_screen.dart';
import 'cours_ajout_screen.dart';
import 'favourites_screen.dart';

class CoursCatalogueScreen extends StatefulWidget {
  const CoursCatalogueScreen({super.key});

  @override
  State<CoursCatalogueScreen> createState() => _CoursCatalogueScreenState();
}

class _CoursCatalogueScreenState extends State<CoursCatalogueScreen> {
  final List<CoursModel> _cours = List.from(kSampleCours);

  void _openEdit(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoursAjoutScreen(
          initialCours: _cours[index],
          onSave: (updated) => setState(() => _cours[index] = updated),
        ),
      ),
    );
  }

  void _delete(int index) {
    final removed = _cours[index];
    setState(() => _cours.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: LearningTheme.surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(children: [
        const Icon(Icons.delete_outline_rounded, color: LearningTheme.error, size: 18),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('Cours supprimé',
              style: TextStyle(fontFamily: LearningTheme.font, color: Colors.white)),
        ),
        GestureDetector(
          onTap: () {
            setState(() => _cours.insert(index, removed));
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
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: LearningTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: LearningTheme.border),
                      ),
                      child: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ROBOTTO', style: LearningTheme.captionStyle),
                      SizedBox(height: 2),
                      Text('Mes cours',
                          style: TextStyle(
                              fontFamily: LearningTheme.font,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                // Favourites
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FavouritesScreen()))
                      .then((_) => setState(() {})),
                  child: Container(
                    width: 44, height: 44,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: LearningTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: LearningTheme.border),
                    ),
                    child: const Icon(Icons.star_rounded, color: LearningTheme.star, size: 22),
                  ),
                ),
                // Add
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoursAjoutScreen(
                        onSave: (c) => setState(() => _cours.add(c)),
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

          // ── Course cards ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 4, 16, LearningTheme.bottomNavPadding),
              itemCount: _cours.length,
              itemBuilder: (context, i) => _CoursCard(
                cours: _cours[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CoursDetailScreen(cours: _cours[i])),
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
class _CoursCard extends StatelessWidget {
  final CoursModel cours;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CoursCard({
    required this.cours,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: ValueKey(cours.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: LearningTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Supprimer le cours',
                  style: TextStyle(fontFamily: LearningTheme.font, color: Colors.white)),
              content: Text('Voulez-vous vraiment supprimer "${cours.title}" ?',
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
                      child: const Icon(Icons.play_circle_rounded,
                          color: LearningTheme.mint, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cours.title,
                              style: const TextStyle(
                                  fontFamily: LearningTheme.font,
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(cours.module, style: LearningTheme.captionStyle),
                        ],
                      ),
                    ),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: LearningTheme.star, size: 14),
                      const SizedBox(width: 3),
                      Text(cours.rating.toString(),
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
                  _badge(Icons.signal_cellular_alt_rounded, cours.level,
                      color: LearningTheme.mint),
                  const SizedBox(width: 8),
                  _badge(Icons.access_time_rounded, cours.duration),
                  const SizedBox(width: 8),
                  _badge(Icons.menu_book_rounded, '${cours.lessons.length} leçons'),
                ]),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${cours.doneCount}/${cours.lessons.length} terminées',
                        style: LearningTheme.captionStyle),
                    Text('${(cours.progress * 100).round()}%',
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
                    value: cours.progress,
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
                    _actionBtn(
                        Icons.delete_outline_rounded, 'Supprimer', Colors.redAccent, onDelete),
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
