import 'package:flutter/material.dart';

/// Constantes visuelles du module Événements — palette "Cybernetic Orbit"
/// alignée sur le cahier des charges Robotto.
class EventTheme {
  EventTheme._();

  // Couleurs principales
  static const Color bg          = Color(0xFF091422);
  static const Color surface     = Color(0xFF121C22);
  static const Color surfaceHigh = Color(0xFF1A2535);
  static const Color mint        = Color(0xFF1DE9A6);
  static const Color teal        = Color(0xFF14B8A6);
  static const Color text        = Color(0xFFFFFFFF);
  static const Color textSoft    = Color(0xFF9FB0B8);
  static const Color error       = Color(0xFFEF4444);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color success     = Color(0xFF22C55E);
  static const Color info        = Color(0xFF3B82F6);

  // Typographie
  static const String fontFamily = 'Plus Jakarta Sans';

  static const TextStyle titleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: textSoft,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSoft,
  );

  // Espacements
  static const double screenPadding = 16.0;
  static const double cardRadius    = 16.0;
  static const double itemSpacing   = 12.0;

  // Décoration de carte
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: mint.withValues(alpha: 0.18)),
  );

  // InputDecoration commune pour tous les champs de saisie
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      prefixIcon: prefix,
      labelStyle: const TextStyle(
        fontFamily: fontFamily,
        color: textSoft,
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: textSoft.withValues(alpha: 0.5),
        fontSize: 13,
      ),
      filled: true,
      fillColor: surfaceHigh,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textSoft.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: mint, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      errorStyle: const TextStyle(
        fontFamily: fontFamily,
        color: error,
        fontSize: 12,
      ),
    );
  }

  /// Couleur de badge selon le statut d'un événement.
  static Color statusColor(String status) {
    switch (status) {
      case 'published':  return success;
      case 'cancelled':  return error;
      case 'completed':  return info;
      default:           return warning; // draft
    }
  }

  /// Couleur de badge selon le type.
  static Color typeColor(String type) {
    return type == 'competition' ? warning : mint;
  }
}
