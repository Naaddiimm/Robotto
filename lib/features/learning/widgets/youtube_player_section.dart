// ---------------------------------------------------------------------------
// YouTubePlayerSection — embeds a YouTube video using webview_flutter
// with a Chrome user-agent so YouTube allows in-app playback (no error 152).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../learning_theme.dart';

class YouTubePlayerSection extends StatefulWidget {
  final String? videoId;
  final String label;

  const YouTubePlayerSection({
    super.key,
    required this.videoId,
    this.label = 'Vidéo',
  });

  @override
  State<YouTubePlayerSection> createState() => _YouTubePlayerSectionState();
}

class _YouTubePlayerSectionState extends State<YouTubePlayerSection> {
  WebViewController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final id = widget.videoId;
    if (id == null || id.isEmpty) return;

    final html =
        '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  * { margin:0; padding:0; background:#000; }
  iframe { width:100%; height:100vh; border:none; display:block; }
</style>
</head>
<body>
<iframe
  src="https://www.youtube-nocookie.com/embed/$id?autoplay=0&rel=0&modestbranding=1&playsinline=1"
  allow="autoplay; fullscreen; picture-in-picture"
  allowfullscreen>
</iframe>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.videoId;
    if (id == null || id.isEmpty) return _Placeholder(label: widget.label);

    final screenW = MediaQuery.of(context).size.width - 32;
    final playerH = screenW * 9 / 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: LearningTheme.mint,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: LearningTheme.font,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Player
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: double.infinity,
            height: playerH,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_loading)
                  Container(
                    color: LearningTheme.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: LearningTheme.mint,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Placeholder when no videoId ───────────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  final String label;
  const _Placeholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                color: LearningTheme.textSecond,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: LearningTheme.font,
                  color: LearningTheme.textSecond,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: LearningTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LearningTheme.border),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LearningTheme.mint.withValues(alpha: 0.08),
                      LearningTheme.background.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: LearningTheme.mint.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LearningTheme.mint.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.smart_display_rounded,
                        color: LearningTheme.mint,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vidéo bientôt disponible',
                      style: TextStyle(
                        fontFamily: LearningTheme.font,
                        color: LearningTheme.textSecond,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
