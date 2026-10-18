import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/shop/data/delivery_fee_calculator.dart';

void main() {
  group('DeliveryFeeCalculator.calculate', () {
    // -------------------------------------------------------------------------
    // Store pickup
    // -------------------------------------------------------------------------
    test('returns 0 for store pickup regardless of zone or weight', () {
      expect(DeliveryFeeCalculator.calculate('grand_tunis', 5, 'store_pickup'), 0);
      expect(DeliveryFeeCalculator.calculate('north', 10, 'store_pickup'), 0);
      expect(DeliveryFeeCalculator.calculate('south', 0, 'store_pickup'), 0);
    });

    // -------------------------------------------------------------------------
    // Grand Tunis: base 5, perKg 1
    // -------------------------------------------------------------------------
    test('calculates correctly for grand_tunis', () {
      expect(DeliveryFeeCalculator.calculate('grand_tunis', 0, 'home'), 5.0);
      expect(DeliveryFeeCalculator.calculate('grand_tunis', 1, 'home'), 6.0);
      expect(DeliveryFeeCalculator.calculate('grand_tunis', 2.5, 'home'), 7.5);
      expect(DeliveryFeeCalculator.calculate('grand_tunis', 10, 'home'), 15.0);
    });

    // -------------------------------------------------------------------------
    // North: base 7, perKg 1.5
    // -------------------------------------------------------------------------
    test('calculates correctly for north', () {
      expect(DeliveryFeeCalculator.calculate('north', 0, 'home'), 7.0);
      expect(DeliveryFeeCalculator.calculate('north', 1, 'home'), 8.5);
      expect(DeliveryFeeCalculator.calculate('north', 2, 'home'), 10.0);
      expect(DeliveryFeeCalculator.calculate('north', 10, 'home'), 22.0);
    });

    // -------------------------------------------------------------------------
    // Center: base 8, perKg 1.5
    // -------------------------------------------------------------------------
    test('calculates correctly for center', () {
      expect(DeliveryFeeCalculator.calculate('center', 0, 'home'), 8.0);
      expect(DeliveryFeeCalculator.calculate('center', 1, 'home'), 9.5);
      expect(DeliveryFeeCalculator.calculate('center', 2, 'home'), 11.0);
      expect(DeliveryFeeCalculator.calculate('center', 10, 'home'), 23.0);
    });

    // -------------------------------------------------------------------------
    // South: base 10, perKg 2
    // -------------------------------------------------------------------------
    test('calculates correctly for south', () {
      expect(DeliveryFeeCalculator.calculate('south', 0, 'home'), 10.0);
      expect(DeliveryFeeCalculator.calculate('south', 1, 'home'), 12.0);
      expect(DeliveryFeeCalculator.calculate('south', 2.5, 'home'), 15.0);
      expect(DeliveryFeeCalculator.calculate('south', 10, 'home'), 30.0);
    });

    // -------------------------------------------------------------------------
    // Rounding to 2 decimals
    // -------------------------------------------------------------------------
    test('rounds to 2 decimal places', () {
      // north: 7 + 1.5 * 1.5 = 7 + 2.25 = 9.25
      expect(DeliveryFeeCalculator.calculate('north', 1.5, 'home'), 9.25);
      // north: 7 + 1.5 * 1.333... = 7 + 2.0 = 9.0 (but let's test a case that needs rounding)
      // north: 7 + 1.5 * 0.333... = 7 + 0.5 = 7.5
      expect(DeliveryFeeCalculator.calculate('north', 0.33333, 'home'), 7.5);
      // center: 8 + 1.5 * 0.1 = 8 + 0.15 = 8.15
      expect(DeliveryFeeCalculator.calculate('center', 0.1, 'home'), 8.15);
    });

    // -------------------------------------------------------------------------
    // Relay point (same fee as home, not store_pickup)
    // -------------------------------------------------------------------------
    test('calculates same fee for relay_point as home', () {
      expect(DeliveryFeeCalculator.calculate('grand_tunis', 5, 'relay_point'),
             DeliveryFeeCalculator.calculate('grand_tunis', 5, 'home'));
      expect(DeliveryFeeCalculator.calculate('south', 3, 'relay_point'),
             DeliveryFeeCalculator.calculate('south', 3, 'home'));
    });

    // -------------------------------------------------------------------------
    // Zero weight
    // -------------------------------------------------------------------------
    test('returns base fee for zero weight', () {
      expect(DeliveryFeeCalculator.calculate('grand_tunis', 0, 'home'), 5.0);
      expect(DeliveryFeeCalculator.calculate('north', 0, 'home'), 7.0);
      expect(DeliveryFeeCalculator.calculate('center', 0, 'home'), 8.0);
      expect(DeliveryFeeCalculator.calculate('south', 0, 'home'), 10.0);
    });

    // -------------------------------------------------------------------------
    // Unknown zone
    // -------------------------------------------------------------------------
    test('returns 0 for unknown zone', () {
      expect(DeliveryFeeCalculator.calculate('unknown', 5, 'home'), 0);
    });
  });

  group('DeliveryFeeCalculator.baseForZone', () {
    test('returns correct base for each zone', () {
      expect(DeliveryFeeCalculator.baseForZone('grand_tunis'), 5);
      expect(DeliveryFeeCalculator.baseForZone('north'), 7);
      expect(DeliveryFeeCalculator.baseForZone('center'), 8);
      expect(DeliveryFeeCalculator.baseForZone('south'), 10);
    });

    test('returns 0 for unknown zone', () {
      expect(DeliveryFeeCalculator.baseForZone('unknown'), 0);
    });
  });

  group('DeliveryFeeCalculator.perKgForZone', () {
    test('returns correct per-kg for each zone', () {
      expect(DeliveryFeeCalculator.perKgForZone('grand_tunis'), 1);
      expect(DeliveryFeeCalculator.perKgForZone('north'), 1.5);
      expect(DeliveryFeeCalculator.perKgForZone('center'), 1.5);
      expect(DeliveryFeeCalculator.perKgForZone('south'), 2);
    });

    test('returns 0 for unknown zone', () {
      expect(DeliveryFeeCalculator.perKgForZone('unknown'), 0);
    });
  });
}
