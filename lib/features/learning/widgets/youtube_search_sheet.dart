// ---------------------------------------------------------------------------
// YouTubeSearchSheet — bottom sheet that searches YouTube via the Data API v3
// and returns the selected video ID to the caller.
//
// Usage:
//   final id = await showYouTubeSearchSheet(context, hint: 'Arduino capteurs');
//   if (id != null) { /* use it */ }
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/youtube_api_service.dart';
import '../learning_theme.dart';

Future<String?> showYouTubeSearchSheet(
  BuildContext context, {
  String hint = '',
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _YouTubeSearchSheet(initialQuery: hint),
  );
}

class _YouTubeSearchSheet extends StatefulWidget {
  final String initialQuery;
  const _YouTubeSearchSheet({required this.initialQuery});

  @override
  State<_YouTubeSearchSheet> createState() => _YouTubeSearchSheetState();
}

class _YouTubeSearchSheetState extends State<_YouTubeSearchSheet> {
  late final TextEditingController _queryCtrl;
  List<YouTubeVideoResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _queryCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await YouTubeApiService.search(q);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: LearningTheme.surfaceHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: LearningTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title ───────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Icon(
                  Icons.youtube_searched_for_rounded,
                  color: Color(0xFFFF4444),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Rechercher une vidéo YouTube',
                  style: TextStyle(
                    fontFamily: LearningTheme.font,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Ex: Arduino capteurs, Python bases…',
                      hintStyle: const TextStyle(
                        fontFamily: LearningTheme.font,
                        color: LearningTheme.textSecond,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: LearningTheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: LearningTheme.mint,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: LearningTheme.textSecond,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _search,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [LearningTheme.mint, LearningTheme.mintDark],
                      ),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: LearningTheme.border, height: 1),

          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: LearningTheme.mint,
                      strokeWidth: 2,
                    ),
                  )
                : _error != null
                ? _buildError()
                : _results.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _results.length,
                    itemBuilder: (_, i) => _VideoCard(
                      result: _results[i],
                      onTap: () => Navigator.pop(context, _results[i].videoId),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: LearningTheme.error,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Erreur de recherche',
            style: const TextStyle(
              fontFamily: LearningTheme.font,
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: LearningTheme.font,
              color: LearningTheme.textSecond,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmpty() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.smart_display_rounded,
          color: LearningTheme.textSecond,
          size: 48,
        ),
        SizedBox(height: 12),
        Text(
          'Tapez un mot-clé pour chercher des vidéos',
          style: TextStyle(
            fontFamily: LearningTheme.font,
            color: LearningTheme.textSecond,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

// ── Video result card ─────────────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final YouTubeVideoResult result;
  final VoidCallback onTap;
  const _VideoCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: LearningTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LearningTheme.border),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.network(
                    result.thumbnailUrl,
                    width: 120,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (context, child, err) => Container(
                      width: 120,
                      height: 68,
                      color: LearningTheme.surfaceHigh,
                      child: const Icon(
                        Icons.broken_image_rounded,
                        color: LearningTheme.textSecond,
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result.durationLabel,
                        style: const TextStyle(
                          fontFamily: LearningTheme.font,
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.channelName,
                    style: const TextStyle(
                      fontFamily: LearningTheme.font,
                      color: LearningTheme.textSecond,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Select button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: LearningTheme.mint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: LearningTheme.mint.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'Sélectionner',
                      style: TextStyle(
                        fontFamily: LearningTheme.font,
                        color: LearningTheme.mint,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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
}
