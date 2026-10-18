import 'package:flutter/material.dart';

/// Cybernetic Orbit design tokens for the Shop module.
///
/// These are **copies** of the constants used across the app's screens.
/// The shop never imports private color fields from other screens —
/// it uses these self-contained constants instead.
class ShopTheme {
  ShopTheme._();

  // ---------------------------------------------------------------------------
  // Colors
  // ---------------------------------------------------------------------------

  /// App background.
  static const Color background = Color(0xFF091422);

  /// Surface / card background.
  static const Color surface = Color(0xFF15202F);

  /// Elevated surface (dialogs, tiles).
  static const Color surfaceHigh = Color(0xFF202B3A);

  /// Low surface (used in some dialogs).
  static const Color surfaceLow = Color(0xFF111C2B);

  /// Primary mint accent.
  static const Color mint = Color(0xFF85FFDE);

  /// Mint gradient end color.
  static const Color mintContainer = Color(0xFF35E6C0);

  /// Accent purple (buttons, active indicators).
  static const Color purple = Color(0xFF5F00BE);

  /// Secondary teal / violet (active icon color).
  static const Color violet = Color(0xFF8B5CF6);

  /// Main text color.
  static const Color text = Color(0xFFD8E3F7);

  /// Secondary / hint text color.
  static const Color secondaryText = Color(0xFFBACAC3);

  /// Error color.
  static const Color error = Color(0xFFFFB4AB);

  // ---------------------------------------------------------------------------
  // Text styles
  // ---------------------------------------------------------------------------

  static const String fontFamily = 'Plus Jakarta Sans';

  static const TextStyle titleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static const TextStyle headingStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: secondaryText,
    height: 1.5,
  );

  static const TextStyle bodyMainStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: text,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: secondaryText,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: background,
  );

  // ---------------------------------------------------------------------------
  // Decorations
  // ---------------------------------------------------------------------------

  /// Card decoration matching the existing surface style.
  static BoxDecoration cardDecoration({
    Color color = surface,
    double radius = 16,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border,
    );
  }

  /// Input decoration matching the signup_screen.dart text fields.
  static InputDecoration inputDecoration({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: secondaryText, size: 20)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: mint, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
    );
  }

  /// Dialog style matching the logout dialog in drawer_screen.dart.
  static RoundedRectangleBorder dialogShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: surface, width: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Padding
  // ---------------------------------------------------------------------------

  /// Bottom padding to clear the floating nav bar (72 px + safe area).
  static const double bottomNavPadding = 110.0;

  /// Horizontal screen padding.
  static const double screenPadding = 16.0;

  /// Section spacing.
  static const double sectionSpacing = 24.0;

  /// Item spacing within a section.
  static const double itemSpacing = 16.0;
}
