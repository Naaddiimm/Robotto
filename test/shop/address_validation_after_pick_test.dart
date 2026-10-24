import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/validators/order_validators.dart';

/// Verifies that OrderValidators.validateAddress still enforces rules
/// on values that could come from the address picker.
void main() {
  group('address validation after pick', () {
    test('normal picked address → valid', () {
      const addr = '5 Avenue Habib Bourguiba, Tunis Centre';
      expect(OrderValidators.validateAddress(addr, 'home'), isNull);
    });

    test('under 10 characters → error', () {
      expect(OrderValidators.validateAddress('12 St', 'home'), isNotNull);
    });

    test('only digits → error', () {
      expect(OrderValidators.validateAddress('1234567890', 'home'), isNotNull);
    });

    test('over 120 characters → error', () {
      final long = 'A' * 121;
      expect(OrderValidators.validateAddress(long, 'home'), isNotNull);
    });

    test('exactly 120 characters → valid', () {
      final ok = 'A' * 119 + 'b';
      expect(OrderValidators.validateAddress(ok, 'home'), isNull);
    });

    test('store_pickup → always valid regardless of content', () {
      expect(OrderValidators.validateAddress('', 'store_pickup'), isNull);
      expect(OrderValidators.validateAddress('1234567890', 'store_pickup'), isNull);
    });

    test('relay_point requires address', () {
      expect(OrderValidators.validateAddress('', 'relay_point'), isNotNull);
      expect(OrderValidators.validateAddress('45 Relay Point Ariana', 'relay_point'), isNull);
    });
  });
}
