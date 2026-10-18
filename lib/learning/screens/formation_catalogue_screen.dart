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
                      child: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 24),
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
                      Text('Mes formations',
                          style: TextStyle(
                              fontFamily: LearningTheme.font,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
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
              padding: EdgeInsets.fromLTRB(
                  16, 4, 16, LearningTheme.bottomNavPadding),
              itemCount: _formations.length,
              itemBuilder: (context, i) => _FormationCard(
                formation: _formations[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          FormationDetailScreen(formation: _formations[i])),
                ).then((_) => setState(() {})),
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

  const _FormationCard({required this.formation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final f = formation;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
                      border: Border.all(
                          color: LearningTheme.mint.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: LearningTheme.mint, size: 26),
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
                    const Icon(Icons.star_rounded,
                        color: LearningTheme.star, size: 14),
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
                _badge(Icons.signal_cellular_alt_rounded, f.level,
                    color: LearningTheme.mint),
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
                  valueColor:
                      const AlwaysStoppedAnimation(LearningTheme.mint),
                ),
              ),
            ],
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
            style: TextStyle(
                fontFamily: LearningTheme.font,
                color: color,
                fontSize: 11)),
      ]);
}
