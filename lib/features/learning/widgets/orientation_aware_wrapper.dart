// ---------------------------------------------------------------------------
// OrientationAwareWrapper — unlocks device orientation for content screens.
//
// Wrap any full-screen content widget with this to allow the user to rotate
// their phone freely (portrait AND landscape). When this widget is disposed
// (user navigates back) it re-locks orientation to portrait-up only so the
// rest of the app stays upright.
//
// Usage:
//   return OrientationAwareWrapper(child: Scaffold(...));
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../learning_theme.dart';

class OrientationAwareWrapper extends StatefulWidget {
  final Widget child;
  const OrientationAwareWrapper({super.key, required this.child});

  @override
  State<OrientationAwareWrapper> createState() =>
      _OrientationAwareWrapperState();
}

class _OrientationAwareWrapperState extends State<OrientationAwareWrapper> {
  @override
  void initState() {
    super.initState();
    // Allow all four orientations when the content screen is open.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Re-lock to portrait when leaving the content screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ---------------------------------------------------------------------------
// RotateHintBadge — small floating badge that tells the user rotation is on.
// Place it anywhere in your header row.
// ---------------------------------------------------------------------------
class RotateHintBadge extends StatefulWidget {
  const RotateHintBadge({super.key});

  @override
  State<RotateHintBadge> createState() => _RotateHintBadgeState();
}

class _RotateHintBadgeState extends State<RotateHintBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _angle;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _angle = Tween<double>(begin: -0.25, end: 0.25).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angle,
      builder: (_, child) => Transform.rotate(
        angle: _angle.value,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: LearningTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: LearningTheme.mint.withValues(alpha: 0.6)),
          ),
          child: const Icon(Icons.screen_rotation_rounded,
              color: LearningTheme.mint, size: 22),
        ),
      ),
    );
  }
}
