import 'package:flutter/material.dart';
import '../learning_theme.dart';
import '../data/learning_models.dart';
import '../data/favourites_repository.dart';
import 'favourites_screen.dart';
import 'lesson_content_screen.dart';

class CoursDetailScreen extends StatefulWidget {
  final CoursModel cours;
  const CoursDetailScreen({super.key, required this.cours});

  @override
  State<CoursDetailScreen> createState() => _CoursDetailScreenState();
}

class _CoursDetailScreenState extends State<CoursDetailScreen> {
  CoursModel get c => widget.cours;

  Future<void> _toggleFav(LessonModel l) async {
    await FavouritesRepository.instance.toggle(
      id: l.id,
      title: l.title,
      duration: l.duration,
      module: c.module,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: LearningTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: LearningTheme.border),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: LearningTheme.captionStyle),
                        const SizedBox(height: 2),
                        Text(c.module,
                            style: const TextStyle(
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
                          builder: (_) => const FavouritesScreen()),
                    ).then((_) => setState(() {})),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: LearningTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: LearningTheme.border),
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: LearningTheme.star, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // ── Video placeholder ─────────────────────────────────────────
            Container(
              height: 180,
              width: double.infinity,
              color: const Color(0xFF050C13),
              alignment: Alignment.center,
              child: Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                    color: LearningTheme.mint, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded,
                    size: 38, color: LearningTheme.background),
              ),
            ),

            // ── Progress bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    child: LinearProgressIndicator(
                      value: 0.38,
                      minHeight: 4,
                      backgroundColor: LearningTheme.border,
                      valueColor:
                          AlwaysStoppedAnimation(LearningTheme.mint),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('03:12 / 08:40', style: LearningTheme.captionStyle),
                ],
              ),
            ),

            // ── Active lesson title ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  c.lessons
                      .firstWhere(
                        (l) => l.state == LessonState.active,
                        orElse: () => c.lessons.first,
                      )
                      .title,
                  style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),

            // ── Tab underline ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: LearningTheme.border))),
                child: Row(
                  children: [
                    _tab('Leçons', selected: true),
                    const SizedBox(width: 24),
                    _tab('Ressources'),
                    const SizedBox(width: 24),
                    _tab('Discussion'),
                  ],
                ),
              ),
            ),

            // ── Lessons list ──────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: c.lessons.length,
                itemBuilder: (ctx, i) {
                  final l = c.lessons[i];
                  final isFav =
                      FavouritesRepository.instance.isFavourite(l.id);
                  return _LessonCard(
                    lesson: l,
                    isFavourite: isFav,
                    onFavTap: () => _toggleFav(l),
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => LessonContentScreen(
                          lesson: l,
                          coursTitle: c.title,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Bottom bar ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: LearningTheme.border))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 17),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: LearningTheme.mint),
                    ),
                    child: const Text('Hors ligne',
                        style: TextStyle(
                            fontFamily: LearningTheme.font,
                            color: LearningTheme.mint,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                            colors: [
                              LearningTheme.mint,
                              LearningTheme.mintDark
                            ]),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Leçon suivante',
                          style: LearningTheme.buttonStyle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tab(String text, {bool selected = false}) => Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? LearningTheme.mint : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(text,
            style: TextStyle(
                fontFamily: LearningTheme.font,
                color: selected ? LearningTheme.mint : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      );
}

// ── Lesson card ───────────────────────────────────────────────────────────────
class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final bool isFavourite;
  final VoidCallback onFavTap;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isFavourite,
    required this.onFavTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = lesson.state == LessonState.active;
    final done = lesson.state == LessonState.done;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: LearningTheme.cardDeco(
              border: active ? LearningTheme.mint : null),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? LearningTheme.mint
                      : done
                          ? LearningTheme.mint.withValues(alpha: 0.2)
                          : Colors.transparent,
                  border: (active || done)
                      ? null
                      : Border.all(color: LearningTheme.border, width: 2),
                ),
                child: Icon(
                  active
                      ? Icons.play_arrow_rounded
                      : done
                          ? Icons.check
                          : null,
                  size: 18,
                  color: active
                      ? LearningTheme.background
                      : LearningTheme.mint,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(lesson.title,
                    style: const TextStyle(
                        fontFamily: LearningTheme.font,
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              Text(lesson.duration, style: LearningTheme.captionStyle),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onFavTap,
                child: Icon(
                  isFavourite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: isFavourite
                      ? LearningTheme.star
                      : LearningTheme.textSecond,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
