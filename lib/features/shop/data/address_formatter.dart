/// Pure helper to build a single-line address from placemark parts and to
/// suggest a delivery zone from a governorate name.
class AddressFormatter {
  AddressFormatter._();

  /// Builds a single-line address from the given parts, skipping empty
  /// strings and duplicates, trimming, and cutting to 120 characters.
  static String buildAddress(List<String?> parts) {
    final seen = <String>{};
    final cleaned = <String>[];

    for (final part in parts) {
      if (part == null) continue;
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      if (seen.contains(trimmed.toLowerCase())) continue;
      seen.add(trimmed.toLowerCase());
      cleaned.add(trimmed);
    }

    final result = cleaned.join(', ');
    if (result.length <= 120) return result;
    return result.substring(0, 120);
  }

  /// Suggests a delivery zone based on the governorate or city name.
  /// Returns 'grand_tunis' for Tunis, Ariana, Ben Arous, Manouba
  /// (case-insensitive, handles French and Arabic names).
  /// Returns null for anything else (leave the user's zone as-is).
  static String? suggestZone(String? governorate) {
    if (governorate == null) return null;
    final g = governorate.trim().toLowerCase();

    // Grand Tunis governorates (French and Arabic)
    const grandTunisNames = {
      'tunis', 'tunis governorate', 'tunis province',
      'ariana', 'l\'ariana', 'la mannouba',
      'ben arous', 'benarous',
      'manouba', 'mannouba', 'la manouba',
      'تونس', 'أريانة', 'بن عروس', 'منوبة',
    };

    if (grandTunisNames.contains(g)) return 'grand_tunis';

    // Also check if the governorate contains one of these names
    if (g.contains('tunis') || g.contains('ariana') ||
        g.contains('ben arous') || g.contains('manouba')) {
      return 'grand_tunis';
    }

    return null;
  }
}
