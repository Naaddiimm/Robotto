// ---------------------------------------------------------------------------
// EventTheme — re-exports AppTheme tokens with event-specific aliases.
// All colors now follow the unified ROBOTTO brand palette.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EventTheme {
  EventTheme._();

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const Color bg          = AppTheme.bg;
  static const Color surface     = AppTheme.surface;
  static const Color surfaceHigh = AppTheme.surfaceHigh;
  static const Color mint        = AppTheme.accent;
  static const Color teal        = AppTheme.accentMid;
  static const Color text        = AppTheme.text;
  static const Color textSoft    = AppTheme.textSoft;
  static const Color error       = AppTheme.error;
  static const Color warning     = AppTheme.warning;
  static const Color success     = AppTheme.accent;   // brand green IS success
  static const Color info        = AppTheme.info;

  // ── Typography ─────────────────────────────────────────────────────────────
  static const String fontFamily = AppTheme.font;

  static const TextStyle titleStyle   = AppTheme.titleStyle;
  static const TextStyle sectionTitle = AppTheme.subtitleStyle;
  static const TextStyle bodyStyle    = AppTheme.bodyStyle;
  static const TextStyle labelStyle   = AppTheme.labelStyle;

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double screenPadding = AppTheme.screenPadding;
  static const double cardRadius    = AppTheme.cardRadius;
  static const double itemSpacing   = AppTheme.itemSpacing;

  // ── Decorations ────────────────────────────────────────────────────────────
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
  );

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) =>
      AppTheme.inputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        prefix: prefix,
      );

  // ── Status helpers ─────────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status) {
      case 'published':  return AppTheme.accent;
      case 'cancelled':  return AppTheme.error;
      case 'completed':  return AppTheme.info;
      default:           return AppTheme.warning; // draft
    }
  }

  static Color typeColor(String type) =>
      type == 'competition' ? AppTheme.warning : AppTheme.accent;
}
