// ---------------------------------------------------------------------------
// LearningTheme — re-exports AppTheme tokens with learning-specific aliases.
// All colors now follow the unified ROBOTTO brand palette.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LearningTheme {
  LearningTheme._();

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const Color background  = AppTheme.bg;
  static const Color surface     = AppTheme.surface;
  static const Color surfaceHigh = AppTheme.surfaceHigh;
  static const Color mint        = AppTheme.accent;
  static const Color mintDark    = AppTheme.accentMid;
  static const Color violet      = AppTheme.accent;       // unified
  static const Color purple      = AppTheme.accentDark;
  static const Color text        = AppTheme.text;
  static const Color textSecond  = AppTheme.textSoft;
  static const Color star        = AppTheme.warning;
  static const Color error       = AppTheme.error;
  static const Color border      = AppTheme.border;

  // ── Typography ─────────────────────────────────────────────────────────────
  static const String font = AppTheme.font;

  static const TextStyle titleStyle   = AppTheme.titleStyle;
  static const TextStyle sectionStyle = AppTheme.headingStyle;
  static const TextStyle bodyStyle    = AppTheme.bodyStyle;
  static const TextStyle captionStyle = AppTheme.captionStyle;
  static const TextStyle labelStyle   = AppTheme.labelStyle;
  static const TextStyle buttonStyle  = AppTheme.buttonLargeStyle;

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double screenPadding   = AppTheme.screenPadding;
  static const double bottomNavPadding = AppTheme.bottomNavPad;

  // ── Decorations ────────────────────────────────────────────────────────────
  static BoxDecoration cardDeco({Color? border}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
            color: border ?? AppTheme.border),
      );

  static InputDecoration inputDeco({required String hint}) =>
      AppTheme.inputDecoration(hintText: hint);
}
