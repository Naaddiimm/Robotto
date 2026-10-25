// ---------------------------------------------------------------------------
// AppTheme — Design System unifié ROBOTTO
//
// Palette extraite du logo :
//   • Fond profond  : #0D1117  (noir galaxy)
//   • Surface 1     : #161B22  (carte / panel)
//   • Surface 2     : #1C2333  (elevated)
//   • Surface 3     : #212D3F  (hover / active bg)
//   • Accent vert   : #00E5A0  (menthe du swoosh logo)
//   • Accent vert 2 : #00C47A  (gradient end)
//   • Accent vert 3 : #00A362  (pressed / dark)
//   • Blanc         : #FFFFFF
//   • Texte principal: #E8EDF2
//   • Texte secondaire: #8B9BAA
//   • Erreur        : #FF5370
//   • Warning       : #FFB830
//   • Success       : #00E5A0  (même que l'accent)
//   • Info          : #3B8EEA
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

abstract class AppTheme {
  AppTheme._();

  // ── Brand palette ──────────────────────────────────────────────────────────

  /// Fond principal de l'app (noir galaxy du logo)
  static const Color bg = Color(0xFF0D1117);

  /// Surface niveau 1 — cartes, panels
  static const Color surface = Color(0xFF161B22);

  /// Surface niveau 2 — dialogs, modals élevés
  static const Color surfaceHigh = Color(0xFF1C2333);

  /// Surface niveau 3 — hover, actif léger
  static const Color surfaceTop = Color(0xFF212D3F);

  /// Accent principal vert menthe (swoosh du logo)
  static const Color accent = Color(0xFF00E5A0);

  /// Accent vert moyen (gradient mid)
  static const Color accentMid = Color(0xFF00C47A);

  /// Accent vert foncé (pressed state)
  static const Color accentDark = Color(0xFF00A362);

  /// Blanc pur — éléments en surbrillance
  static const Color white = Color(0xFFFFFFFF);

  /// Texte principal
  static const Color text = Color(0xFFE8EDF2);

  /// Texte secondaire / hint
  static const Color textSoft = Color(0xFF8B9BAA);

  /// Texte désactivé
  static const Color textDisabled = Color(0xFF4A5568);

  /// Erreur
  static const Color error = Color(0xFFFF5370);

  /// Warning
  static const Color warning = Color(0xFFFFB830);

  /// Info
  static const Color info = Color(0xFF3B8EEA);

  /// Bordure subtile
  static const Color border = Color(0xFF21303F);

  /// Bordure accent (menthe à faible opacité → simulé via withValues)
  static const Color borderAccent = Color(
    0xFF00E5A0,
  ); // use withValues(alpha: 0.25)

  // ── Gradients ──────────────────────────────────────────────────────────────

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentMid],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradientVertical = LinearGradient(
    colors: [accent, accentMid],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF111822)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Typography ─────────────────────────────────────────────────────────────

  static const String font = 'Plus Jakarta Sans';

  static const TextStyle displayStyle = TextStyle(
    fontFamily: font,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: text,
    height: 1.2,
  );

  static const TextStyle headingStyle = TextStyle(
    fontFamily: font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: font,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: font,
    fontSize: 14,
    color: textSoft,
    height: 1.6,
  );

  static const TextStyle bodyBoldStyle = TextStyle(
    fontFamily: font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: font,
    fontSize: 12,
    color: textSoft,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: font,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSoft,
  );

  static const TextStyle buttonLargeStyle = TextStyle(
    fontFamily: font,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: bg,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: font,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: bg,
  );

  static const TextStyle accentTextStyle = TextStyle(
    fontFamily: font,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: accent,
  );

  // ── Spacing ────────────────────────────────────────────────────────────────

  static const double screenPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 14.0;
  static const double chipRadius = 24.0;
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 12.0;
  static const double bottomNavPad = 110.0;

  // ── Shadows ────────────────────────────────────────────────────────────────

  static List<BoxShadow> accentGlow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.28),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Reusable Decorations ───────────────────────────────────────────────────

  /// Carte standard
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = cardRadius,
    bool withBorder = false,
    bool accentBorder = false,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: withBorder
          ? Border.all(
              color: accentBorder ? accent.withValues(alpha: 0.3) : border,
            )
          : null,
    );
  }

  /// Chip / badge accent
  static BoxDecoration accentChipDecoration() => BoxDecoration(
    color: accent.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(chipRadius),
    border: Border.all(color: accent.withValues(alpha: 0.4)),
  );

  /// Chip / badge neutre
  static BoxDecoration neutralChipDecoration() => BoxDecoration(
    color: surfaceHigh.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(chipRadius),
    border: Border.all(color: border),
  );

  /// Bouton primaire avec gradient
  static BoxDecoration primaryButtonDecoration({
    bool disabled = false,
    double radius = buttonRadius,
  }) {
    return BoxDecoration(
      gradient: disabled ? null : accentGradient,
      color: disabled ? surfaceHigh : null,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: disabled ? null : accentGlow,
    );
  }

  /// Input field
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      labelStyle: const TextStyle(
        fontFamily: font,
        color: textSoft,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        fontFamily: font,
        color: textDisabled,
        fontSize: 14,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: textSoft, size: 20)
          : prefix,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      errorStyle: const TextStyle(fontFamily: font, color: error, fontSize: 12),
    );
  }

  // ── MaterialApp ThemeData ──────────────────────────────────────────────────

  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    canvasColor: bg,
    fontFamily: font,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: accent,
      secondary: accentMid,
      error: error,
      onPrimary: bg,
      onSurface: text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: text),
      titleTextStyle: titleStyle,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: buttonStyle,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(
          fontFamily: font,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceHigh,
      selectedColor: accent.withValues(alpha: 0.18),
      side: const BorderSide(color: border),
      labelStyle: const TextStyle(fontFamily: font, fontSize: 12, color: text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipRadius),
      ),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
