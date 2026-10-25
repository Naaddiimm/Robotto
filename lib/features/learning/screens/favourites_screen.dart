import 'package:flutter/material.dart';

import '../learning_theme.dart';
import '../data/favourites_repository.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<FavouriteLesson> _favourites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final list = await FavouritesRepository.instance.getAll();
    if (mounted) setState(() => _favourites = list);
  }

  Future<void> _remove(FavouriteLesson lesson) async {
    await FavouritesRepository.instance.toggle(
      id: lesson.id,
      title: lesson.title,
      duration: lesson.duration,
      module: lesson.module,
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: LearningTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: LearningTheme.border),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes leçons', style: LearningTheme.captionStyle),
                      SizedBox(height: 2),
                      Text(
                        'Favoris',
                        style: TextStyle(
                          fontFamily: LearningTheme.font,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: LearningTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LearningTheme.border),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: LearningTheme.star,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Count badge ──────────────────────────────────────────────────
            if (_favourites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: LearningTheme.mint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: LearningTheme.mint.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${_favourites.length} leçon${_favourites.length > 1 ? 's' : ''} sauvegardée${_favourites.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontFamily: LearningTheme.font,
                        color: LearningTheme.mint,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            // ── List or empty state ──────────────────────────────────────────
            Expanded(
              child: _favourites.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _favourites.length,
                      itemBuilder: (context, index) {
                        final lesson = _favourites[index];
                        return _FavouriteCard(
                          lesson: lesson,
                          onRemove: () => _remove(lesson),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: LearningTheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: LearningTheme.border),
          ),
          child: const Icon(
            Icons.star_outline_rounded,
            color: LearningTheme.textSecond,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Aucun favori pour l\'instant',
          style: TextStyle(
            fontFamily: LearningTheme.font,
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Appuyez sur ★ dans une leçon\npour la sauvegarder ici.',
          textAlign: TextAlign.center,
          style: LearningTheme.bodyStyle,
        ),
      ],
    ),
  );
}

// ── Card ──────────────────────────────────────────────────────────────────────
class _FavouriteCard extends StatelessWidget {
  final FavouriteLesson lesson;
  final VoidCallback onRemove;

  const _FavouriteCard({required this.lesson, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: LearningTheme.cardDeco(),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LearningTheme.star.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: LearningTheme.star,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.folder_outlined,
                        color: LearningTheme.textSecond,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(lesson.module, style: LearningTheme.captionStyle),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time_rounded,
                        color: LearningTheme.textSecond,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(lesson.duration, style: LearningTheme.captionStyle),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: LearningTheme.star,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
