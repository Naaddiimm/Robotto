// ---------------------------------------------------------------------------
// CoursDetailScreen — displays a cours as a self-contained leçon.
// Each cours is a single lesson: tapping a cours card opens this screen
// directly, which shows the full rich-text content of the cours.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../learning_theme.dart';
import '../data/learning_models.dart';
import '../data/favourites_repository.dart';
import '../widgets/orientation_aware_wrapper.dart';
import '../widgets/youtube_player_section.dart';
import 'favourites_screen.dart';

class CoursDetailScreen extends StatefulWidget {
  final CoursModel cours;
  const CoursDetailScreen({super.key, required this.cours});

  @override
  State<CoursDetailScreen> createState() => _CoursDetailScreenState();
}

class _CoursDetailScreenState extends State<CoursDetailScreen> {
  CoursModel get c => widget.cours;

  Future<void> _toggleFav() async {
    // Treat the cours itself as the "lesson" for favouriting purposes.
    await FavouritesRepository.instance.toggle(
      id: c.id,
      title: c.title,
      duration: c.duration,
      module: c.module,
    );
    setState(() {});
  }

  bool get _isFav => FavouritesRepository.instance.isFavourite(c.id);

  @override
  Widget build(BuildContext context) {
    final content = c.content.isNotEmpty
        ? c.content
        : "Le contenu de ce cours sera disponible prochainement.\n\n"
              "En attendant, vous pouvez :\n"
              "- Consulter la description du cours\n"
              "- Poser vos questions dans la section Discussion\n"
              "- Explorer d'autres cours disponibles";

    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: OrientationAwareWrapper(
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;
              return isLandscape
                  ? _buildLandscape(context, content)
                  : _buildPortrait(context, content);
            },
          ),
        ),
      ),
    );
  }

  // ── Portrait: pinned header + scrollable content + pinned bottom bar ──────
  Widget _buildPortrait(BuildContext context, String content) => Column(
    children: [
      _buildHeaderRow(context),
      _buildMetaCard(),
      if (c.videoId != null && c.videoId!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: YouTubePlayerSection(
            videoId: c.videoId,
            label: 'Vidéo du cours',
          ),
        ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: _buildContent(content),
        ),
      ),
      _buildBottomBar(context),
    ],
  );

  // ── Landscape: everything in one scrollable list ───────────────────────────
  Widget _buildLandscape(BuildContext context, String content) => Column(
    children: [
      _buildHeaderRow(context),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _buildMetaCard(),
            if (c.videoId != null && c.videoId!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: YouTubePlayerSection(
                  videoId: c.videoId,
                  label: 'Vidéo du cours',
                ),
              ),
            ..._buildContent(content),
            const SizedBox(height: 12),
            _buildBottomBar(context),
          ],
        ),
      ),
    ],
  );

  Widget _buildHeaderRow(BuildContext context) => Padding(
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.module,
                style: LearningTheme.captionStyle,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                c.title,
                style: const TextStyle(
                  fontFamily: LearningTheme.font,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Favourite toggle
        GestureDetector(
          onTap: _toggleFav,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LearningTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LearningTheme.border),
            ),
            child: Icon(
              _isFav ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFav ? LearningTheme.star : LearningTheme.textSecond,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Favourites list shortcut
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavouritesScreen()),
          ).then((_) => setState(() {})),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LearningTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LearningTheme.border),
            ),
            child: const Icon(
              Icons.bookmarks_rounded,
              color: LearningTheme.star,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Gyroscope rotate hint
        const RotateHintBadge(),
      ],
    ),
  );

  Widget _buildMetaCard() => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: LearningTheme.cardDeco(border: LearningTheme.mint),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(c.description, style: LearningTheme.bodyStyle),
        const SizedBox(height: 12),
        Row(
          children: [
            _meta(Icons.signal_cellular_alt_rounded, c.level),
            const SizedBox(width: 16),
            _meta(Icons.access_time_rounded, c.duration),
            const SizedBox(width: 16),
            _meta(
              Icons.star_rounded,
              c.rating.toString(),
              color: LearningTheme.star,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: LearningTheme.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: LearningTheme.mint.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                c.level,
                style: const TextStyle(
                  fontFamily: LearningTheme.font,
                  color: LearningTheme.mint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildBottomBar(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: LearningTheme.border)),
    ),
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [LearningTheme.mint, LearningTheme.mintDark],
          ),
        ),
        alignment: Alignment.center,
        child: const Text('Retour aux cours', style: LearningTheme.buttonStyle),
      ),
    ),
  );

  // ── Simple content renderer (same engine as LessonContentScreen) ─────────
  List<Widget> _buildContent(String raw) {
    final lines = raw.trim().split('\n');
    final widgets = <Widget>[];
    bool inCode = false;
    final codeBuffer = <String>[];

    for (final line in lines) {
      if (line.trimLeft().startsWith('```')) {
        if (inCode) {
          widgets.add(_CodeBlock(code: codeBuffer.join('\n')));
          codeBuffer.clear();
          inCode = false;
        } else {
          inCode = true;
        }
        continue;
      }
      if (inCode) {
        codeBuffer.add(line);
        continue;
      }

      // Bold heading
      if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontFamily: LearningTheme.font,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      // Numbered list
      if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 10, top: 1),
                  decoration: const BoxDecoration(
                    color: LearningTheme.surface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    line.trim().split('.').first,
                    style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: LearningTheme.mint,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    line.trim().replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                    style: LearningTheme.bodyStyle,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Bullet list
      if (line.trim().startsWith('- ')) {
        final text = line.trim().substring(2);
        final isBold = text.startsWith('**') && text.contains('**');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isBold
                          ? LearningTheme.mint
                          : LearningTheme.textSecond,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    text.replaceAll('**', ''),
                    style: TextStyle(
                      fontFamily: LearningTheme.font,
                      color: isBold
                          ? LearningTheme.mint
                          : LearningTheme.textSecond,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Table row
      if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
        if (line.contains('---')) continue;
        final cells = line
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: LearningTheme.surface,
              border: Border.all(color: LearningTheme.border),
            ),
            child: Row(
              children: cells
                  .map(
                    (c) => Expanded(
                      child: Text(c, style: LearningTheme.captionStyle),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
        continue;
      }

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line, style: LearningTheme.bodyStyle),
        ),
      );
    }

    return widgets;
  }

  static Widget _meta(
    IconData icon,
    String text, {
    Color color = LearningTheme.textSecond,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 3),
      Text(
        text,
        style: TextStyle(
          fontFamily: LearningTheme.font,
          color: color,
          fontSize: 12,
        ),
      ),
    ],
  );
}

// ── Code block widget ─────────────────────────────────────────────────────────
class _CodeBlock extends StatelessWidget {
  final String code;
  const _CodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF050C13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LearningTheme.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: LearningTheme.mint,
            fontSize: 12.5,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
