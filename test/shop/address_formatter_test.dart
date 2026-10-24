import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/data/address_formatter.dart';

void main() {
  group('AddressFormatter.buildAddress', () {
    test('normal parts', () {
      expect(
        AddressFormatter.buildAddress(['Rue de la Paix', 'Lafayette', 'Tunis']),
        'Rue de la Paix, Lafayette, Tunis',
      );
    });
    test('null parts skipped', () {
      expect(
        AddressFormatter.buildAddress([null, 'Lafayette', null, 'Tunis']),
        'Lafayette, Tunis',
      );
    });
    test('empty strings skipped', () {
      expect(
        AddressFormatter.buildAddress(['', 'Lafayette', '', 'Tunis']),
        'Lafayette, Tunis',
      );
    });
    test('duplicates removed (case-insensitive)', () {
      expect(
        AddressFormatter.buildAddress(['Tunis', 'Lafayette', 'tunis']),
        'Tunis, Lafayette',
      );
    });
    test('all empty → empty string', () {
      expect(AddressFormatter.buildAddress([null, '', '   ']), '');
    });
    test('whitespace trimmed', () {
      expect(AddressFormatter.buildAddress(['  Rue  ', ' Tunis ']), 'Rue, Tunis');
    });
    test('over 120 chars → cut at 120', () {
      final longPart = 'A' * 130;
      final result = AddressFormatter.buildAddress([longPart]);
      expect(result.length, 120);
    });
    test('exactly 120 → not cut', () {
      final part = 'A' * 120;
      expect(AddressFormatter.buildAddress([part]).length, 120);
    });
    test('two parts totaling exactly 120 → kept', () {
      // 'A'*59 + ', ' + 'B'*59 = 59+2+59 = 120
      final a = 'A' * 59;
      final b = 'B' * 59;
      expect(AddressFormatter.buildAddress([a, b]).length, 120);
    });
  });

  group('AddressFormatter.suggestZone', () {
    test('null → null', () => expect(AddressFormatter.suggestZone(null), isNull));
    test('Tunis → grand_tunis', () => expect(AddressFormatter.suggestZone('Tunis'), 'grand_tunis'));
    test('tunis (lowercase) → grand_tunis', () => expect(AddressFormatter.suggestZone('tunis'), 'grand_tunis'));
    test('TUNIS (uppercase) → grand_tunis', () => expect(AddressFormatter.suggestZone('TUNIS'), 'grand_tunis'));
    test('  Tunis  (whitespace) → grand_tunis', () => expect(AddressFormatter.suggestZone('  Tunis  '), 'grand_tunis'));
    test('Ariana → grand_tunis', () => expect(AddressFormatter.suggestZone('Ariana'), 'grand_tunis'));
    test('Ben Arous → grand_tunis', () => expect(AddressFormatter.suggestZone('Ben Arous'), 'grand_tunis'));
    test('Manouba → grand_tunis', () => expect(AddressFormatter.suggestZone('Manouba'), 'grand_tunis'));
    test('Mannouba → grand_tunis', () => expect(AddressFormatter.suggestZone('Mannouba'), 'grand_tunis'));
    test('Sfax → null', () => expect(AddressFormatter.suggestZone('Sfax'), isNull));
    test('Sousse → null', () => expect(AddressFormatter.suggestZone('Sousse'), isNull));
    test('unknown → null', () => expect(AddressFormatter.suggestZone('Outer Space'), isNull));
    test('empty string → null', () => expect(AddressFormatter.suggestZone(''), isNull));
    test('partial match "Greater Tunis" → grand_tunis', () => expect(AddressFormatter.suggestZone('Greater Tunis'), 'grand_tunis'));
  });
}
