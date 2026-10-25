// ---------------------------------------------------------------------------
// ShopTheme — re-exports AppTheme tokens with shop-specific aliases.
// All colors now follow the unified ROBOTTO brand palette.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ShopTheme {
  ShopTheme._();

  // ── Color aliases (maps to AppTheme) ───────────────────────────────────────
  static const Color background = AppTheme.bg;
  static const Color surface = AppTheme.surface;
  static const Color surfaceHigh = AppTheme.surfaceHigh;
  static const Color surfaceLow = AppTheme.surfaceTop;
  static const Color mint = AppTheme.accent;
  static const Color mintContainer = AppTheme.accentMid;
  static const Color violet = AppTheme.accent; // unified to accent
  static const Color purple = AppTheme.accentDark;
  static const Color text = AppTheme.text;
  static const Color secondaryText = AppTheme.textSoft;
  static const Color error = AppTheme.error;

  // ── Typography ─────────────────────────────────────────────────────────────
  static const String fontFamily = AppTheme.font;

  static const TextStyle titleStyle = AppTheme.titleStyle;
  static const TextStyle headingStyle = AppTheme.headingStyle;
  static const TextStyle bodyStyle = AppTheme.bodyStyle;
  static const TextStyle bodyMainStyle = AppTheme.bodyBoldStyle;
  static const TextStyle labelStyle = AppTheme.labelStyle;
  static const TextStyle captionStyle = AppTheme.captionStyle;
  static const TextStyle buttonStyle = AppTheme.buttonLargeStyle;

  // ── Decorations ────────────────────────────────────────────────────────────
  static BoxDecoration cardDecoration({
    Color color = surface,
    double radius = AppTheme.cardRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border,
    );
  }

  static InputDecoration inputDecoration({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) => AppTheme.inputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
  );

  static RoundedRectangleBorder dialogShape() => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
    side: const BorderSide(color: AppTheme.border),
  );

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double bottomNavPadding = AppTheme.bottomNavPad;
  static const double screenPadding = AppTheme.screenPadding;
  static const double sectionSpacing = AppTheme.sectionSpacing;
  static const double itemSpacing = AppTheme.itemSpacing;
}
