import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/data/delivery_fee_calculator.dart';

void main() {
  group('DeliveryFeeCalculator', () {
    test('store_pickup → 0', () => expect(DeliveryFeeCalculator.calculate('grand_tunis', 5, 'store_pickup'), 0.0));
    test('store_pickup any zone → 0', () => expect(DeliveryFeeCalculator.calculate('south', 10, 'store_pickup'), 0.0));

    test('grand_tunis 0 kg → base 5', () => expect(DeliveryFeeCalculator.calculate('grand_tunis', 0, 'home'), 5.0));
    test('grand_tunis 2 kg → 7', () => expect(DeliveryFeeCalculator.calculate('grand_tunis', 2, 'home'), 7.0));
    test('grand_tunis 1.5 kg → 6.50', () => expect(DeliveryFeeCalculator.calculate('grand_tunis', 1.5, 'home'), 6.5));

    test('north 0 kg → base 7', () => expect(DeliveryFeeCalculator.calculate('north', 0, 'home'), 7.0));
    test('north 2 kg → 10', () => expect(DeliveryFeeCalculator.calculate('north', 2, 'home'), 10.0));

    test('center 0 kg → base 8', () => expect(DeliveryFeeCalculator.calculate('center', 0, 'home'), 8.0));
    test('center 2 kg → 11', () => expect(DeliveryFeeCalculator.calculate('center', 2, 'home'), 11.0));

    test('south 0 kg → base 10', () => expect(DeliveryFeeCalculator.calculate('south', 0, 'home'), 10.0));
    test('south 2 kg → 14', () => expect(DeliveryFeeCalculator.calculate('south', 2, 'home'), 14.0));

    test('rounding: north 0.333... kg', () {
      // 7 + 1.5 * 0.333 = 7.4995 → rounds to 7.5
      final result = DeliveryFeeCalculator.calculate('north', 1.0 / 3.0, 'home');
      expect(result, closeTo(7.5, 0.01));
    });

    test('unknown zone → 0', () => expect(DeliveryFeeCalculator.calculate('unknown', 5, 'home'), 0.0));

    test('relay_point same as home', () {
      expect(
        DeliveryFeeCalculator.calculate('south', 3, 'relay_point'),
        DeliveryFeeCalculator.calculate('south', 3, 'home'),
      );
    });

    test('baseForZone grand_tunis', () => expect(DeliveryFeeCalculator.baseForZone('grand_tunis'), 5.0));
    test('perKgForZone south', () => expect(DeliveryFeeCalculator.perKgForZone('south'), 2.0));
  });
}
