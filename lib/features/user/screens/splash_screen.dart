// ---------------------------------------------------------------------------
// SplashScreen — Plays the animated logo video (MP4) on app launch.
// Navigates automatically to WelcomeScreen when the video ends (or on error).
//
// Asset expected: assets/videos/logo_intro.mp4
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_theme.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _hasNavigated = false;

  static const String _videoAsset = 'assets/videos/LogoVid.mp4';
  static const Color _bgColor = AppTheme.bg;

  @override
  void initState() {
    super.initState();
    // Full-screen immersive mode during splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.asset(_videoAsset)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});        // Trigger rebuild to show video
        _controller.setLooping(false);
        _controller.setVolume(1.0);
        _controller.play();

        // Navigate when video finishes
        _controller.addListener(_onVideoProgress);
      }).catchError((error) {
        debugPrint('[SplashScreen] Video init error: $error');
        _navigateToWelcome();   // Fallback: skip splash on error
      });
  }

  void _onVideoProgress() {
    if (!mounted || _hasNavigated) return;

    final pos = _controller.value.position;
    final dur = _controller.value.duration;

    // Navigate when playback reaches the end
    if (dur.inMilliseconds > 0 && pos >= dur - const Duration(milliseconds: 200)) {
      _navigateToWelcome();
    }
  }

  void _navigateToWelcome() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: GestureDetector(
        // Allow user to tap to skip the intro
        onTap: _navigateToWelcome,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video ──────────────────────────────────────────────────────
            if (_controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              // Loading indicator while video initialises
              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 2,
                ),
              ),

            // ── Skip hint ─────────────────────────────────────────────────
            if (_controller.value.isInitialized)
              Positioned(
                bottom: 32,
                right: 24,
                child: AnimatedOpacity(
                  opacity: 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Text(
                      'Tap to skip',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
