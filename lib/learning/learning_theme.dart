// ---------------------------------------------------------------------------
// LearningTheme — design tokens for the Learning module.
// Reuses the Cybernetic Orbit palette from ShopTheme so both modules
// look consistent. Import this instead of ShopTheme to keep the module
// self-contained and avoid cross-module coupling.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

class LearningTheme {
  LearningTheme._();

  // ── Colors ─────────────────────────────────────────────────────────────────
  static const Color background  = Color(0xFF091422);
  static const Color surface     = Color(0xFF15202F);
  static const Color surfaceHigh = Color(0xFF202B3A);
  static const Color mint        = Color(0xFF85FFDE);
  static const Color mintDark    = Color(0xFF35E6C0);
  static const Color violet      = Color(0xFF8B5CF6);
  static const Color purple      = Color(0xFF5F00BE);
  static const Color text        = Color(0xFFD8E3F7);
  static const Color textSecond  = Color(0xFFBACAC3);
  static const Color star        = Color(0xFFFFD700);
  static const Color error       = Color(0xFFFFB4AB);
  static const Color border      = Color(0xFF1E2D3D);

  // ── Typography ─────────────────────────────────────────────────────────────
  static const String font = 'Plus Jakarta Sans';

  static const TextStyle titleStyle = TextStyle(
    fontFamily: font, fontSize: 18,
    fontWeight: FontWeight.bold, color: text,
  );

  static const TextStyle sectionStyle = TextStyle(
    fontFamily: font, fontSize: 20,
    fontWeight: FontWeight.w800, color: text,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: font, fontSize: 14,
    color: textSecond, height: 1.6,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: font, fontSize: 12, color: textSecond,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: font, fontSize: 13,
    fontWeight: FontWeight.w500, color: textSecond,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: font, fontSize: 15,
    fontWeight: FontWeight.w800, color: background,
  );

  // ── Decorations ────────────────────────────────────────────────────────────
  static const double screenPadding = 16.0;
  static const double bottomNavPadding = 110.0;

  static BoxDecoration cardDeco({Color? border}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: border ?? const Color(0xFF1E2D3D)),
      );

  static InputDecoration inputDeco({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: font, color: textSecond, fontSize: 14),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: mint, width: 1.5)),
      );
}
