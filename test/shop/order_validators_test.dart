import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/shop/validators/order_validators.dart';

void main() {
  // ===========================================================================
  // validateQuantity
  // ===========================================================================
  group('OrderValidators.validateQuantity', () {
    test('returns null for valid quantity within stock', () {
      expect(OrderValidators.validateQuantity('1', 10), isNull);
      expect(OrderValidators.validateQuantity('5', 10), isNull);
      expect(OrderValidators.validateQuantity('10', 10), isNull);
    });

    test('returns error for empty', () {
      expect(OrderValidators.validateQuantity('', 10), 'Quantity is required');
      expect(OrderValidators.validateQuantity(null, 10), 'Quantity is required');
    });

    test('returns error for zero or negative', () {
      expect(OrderValidators.validateQuantity('0', 10), 'Quantity must be at least 1');
      expect(OrderValidators.validateQuantity('-1', 10), 'Quantity must be at least 1');
    });

    test('returns error for quantity above stock', () {
      expect(
        OrderValidators.validateQuantity('11', 10),
        'Quantity cannot exceed available stock (10)',
      );
      expect(
        OrderValidators.validateQuantity('100', 5),
        'Quantity cannot exceed available stock (5)',
      );
    });

    test('returns null at exactly stock', () {
      expect(OrderValidators.validateQuantity('10', 10), isNull);
    });

    test('returns error for non-integer', () {
      expect(OrderValidators.validateQuantity('abc', 10), 'Quantity must be a whole number');
      expect(OrderValidators.validateQuantity('1.5', 10), 'Quantity must be a whole number');
    });
  });

  // ===========================================================================
  // validateRecipientName
  // ===========================================================================
  group('OrderValidators.validateRecipientName', () {
    test('returns null for valid name', () {
      expect(OrderValidators.validateRecipientName('Ahmed Ben Salah'), isNull);
    });

    test('returns error for empty', () {
      expect(OrderValidators.validateRecipientName(''), 'Recipient name is required');
      expect(OrderValidators.validateRecipientName(null), 'Recipient name is required');
    });

    test('returns error for too short (< 3)', () {
      expect(OrderValidators.validateRecipientName('AB'), 'Name must be at least 3 characters');
    });

    test('returns null at exactly 3 characters', () {
      expect(OrderValidators.validateRecipientName('ABC'), isNull);
    });

    test('returns error for too long (> 60)', () {
      expect(OrderValidators.validateRecipientName('A' * 61), 'Name must be at most 60 characters');
    });

    test('returns null at exactly 60 characters', () {
      expect(OrderValidators.validateRecipientName('A' * 60), isNull);
    });
  });

  // ===========================================================================
  // validatePhone
  // ===========================================================================
  group('OrderValidators.validatePhone', () {
    test('returns null for 8-digit number', () {
      expect(OrderValidators.validatePhone('12345678'), isNull);
    });

    test('returns null with +216 prefix', () {
      expect(OrderValidators.validatePhone('+21612345678'), isNull);
    });

    test('returns null with 216 prefix', () {
      expect(OrderValidators.validatePhone('21612345678'), isNull);
    });

    test('returns null with spaces', () {
      expect(OrderValidators.validatePhone('12 34 56 78'), isNull);
      expect(OrderValidators.validatePhone('+216 12 34 56 78'), isNull);
    });

    test('returns error for empty', () {
      expect(OrderValidators.validatePhone(''), 'Phone number is required');
      expect(OrderValidators.validatePhone(null), 'Phone number is required');
    });

    test('returns error for too few digits', () {
      expect(OrderValidators.validatePhone('1234567'), 'Enter a valid 8-digit Tunisian phone number');
    });

    test('returns error for too many digits', () {
      expect(OrderValidators.validatePhone('123456789'), 'Enter a valid 8-digit Tunisian phone number');
    });

    test('returns error for non-digit characters', () {
      expect(OrderValidators.validatePhone('abcdefgh'), 'Enter a valid 8-digit Tunisian phone number');
    });
  });

  // ===========================================================================
  // validateAddress
  // ===========================================================================
  group('OrderValidators.validateAddress', () {
    test('returns null for home delivery with valid address', () {
      expect(OrderValidators.validateAddress('123 Rue de la Paix, Tunis', 'home'), isNull);
    });

    test('returns null for relay_point with valid address', () {
      expect(OrderValidators.validateAddress('Relay Point 45, Ariana', 'relay_point'), isNull);
    });

    test('returns null for store_pickup regardless of address', () {
      expect(OrderValidators.validateAddress('', 'store_pickup'), isNull);
      expect(OrderValidators.validateAddress(null, 'store_pickup'), isNull);
    });

    test('returns error for empty when home', () {
      expect(OrderValidators.validateAddress('', 'home'), 'Address is required for this delivery mode');
      expect(OrderValidators.validateAddress(null, 'home'), 'Address is required for this delivery mode');
    });

    test('returns error for empty when relay_point', () {
      expect(OrderValidators.validateAddress('', 'relay_point'), 'Address is required for this delivery mode');
    });

    test('returns error for too short (< 10)', () {
      expect(OrderValidators.validateAddress('Short', 'home'), 'Address must be at least 10 characters');
    });

    test('returns null at exactly 10 characters', () {
      expect(OrderValidators.validateAddress('123456789a', 'home'), isNull);
    });

    test('returns error for too long (> 120)', () {
      expect(OrderValidators.validateAddress('A' * 121, 'home'), 'Address must be at most 120 characters');
    });

    test('returns null at exactly 120 characters', () {
      expect(OrderValidators.validateAddress('A' * 119 + 'b', 'home'), isNull);
    });

    test('returns error for only digits', () {
      expect(OrderValidators.validateAddress('1234567890', 'home'), 'Address cannot be only digits');
    });
  });

  // ===========================================================================
  // validateCity
  // ===========================================================================
  group('OrderValidators.validateCity', () {
    test('returns null for valid city', () {
      expect(OrderValidators.validateCity('Tunis'), isNull);
      expect(OrderValidators.validateCity('Sfax'), isNull);
    });

    test('returns error for empty', () {
      expect(OrderValidators.validateCity(''), 'City is required');
      expect(OrderValidators.validateCity(null), 'City is required');
    });

    test('returns error for too short (< 2)', () {
      expect(OrderValidators.validateCity('A'), 'City must be at least 2 characters');
    });

    test('returns null at exactly 2 characters', () {
      expect(OrderValidators.validateCity('AB'), isNull);
    });

    test('returns error for too long (> 40)', () {
      expect(OrderValidators.validateCity('A' * 41), 'City must be at most 40 characters');
    });

    test('returns null at exactly 40 characters', () {
      expect(OrderValidators.validateCity('A' * 40), isNull);
    });
  });

  // ===========================================================================
  // validateZone
  // ===========================================================================
  group('OrderValidators.validateZone', () {
    test('returns null for valid zones', () {
      expect(OrderValidators.validateZone('grand_tunis'), isNull);
      expect(OrderValidators.validateZone('north'), isNull);
      expect(OrderValidators.validateZone('center'), isNull);
      expect(OrderValidators.validateZone('south'), isNull);
    });

    test('returns error for empty', () {
      expect(OrderValidators.validateZone(''), 'Zone is required');
      expect(OrderValidators.validateZone(null), 'Zone is required');
    });

    test('returns error for invalid zone', () {
      expect(OrderValidators.validateZone('east'), 'Select a valid zone');
    });
  });

  // ===========================================================================
  // validateDeliveryMode
  // ===========================================================================
  group('OrderValidators.validateDeliveryMode', () {
    test('returns null for valid modes', () {
      expect(OrderValidators.validateDeliveryMode('home'), isNull);
      expect(OrderValidators.validateDeliveryMode('relay_point'), isNull);
      expect(OrderValidators.validateDeliveryMode('store_pickup'), isNull);
    });

    test('returns error for empty', () {
      expect(OrderValidators.validateDeliveryMode(''), 'Delivery mode is required');
      expect(OrderValidators.validateDeliveryMode(null), 'Delivery mode is required');
    });

    test('returns error for invalid mode', () {
      expect(OrderValidators.validateDeliveryMode('drone'), 'Select a valid delivery mode');
    });
  });

  // ===========================================================================
  // validatePaymentMethod
  // ===========================================================================
  group('OrderValidators.validatePaymentMethod', () {
    test('returns null for cash_on_delivery', () {
      expect(OrderValidators.validatePaymentMethod('cash_on_delivery'), isNull);
    });

    test('returns error for card (coming soon)', () {
      expect(OrderValidators.validatePaymentMethod('card'), 'This payment method is coming soon');
    });

    test('returns error for mobile_wallet (coming soon)', () {
      expect(OrderValidators.validatePaymentMethod('mobile_wallet'), 'This payment method is coming soon');
    });

    test('returns error for empty', () {
      expect(OrderValidators.validatePaymentMethod(''), 'Payment method is required');
      expect(OrderValidators.validatePaymentMethod(null), 'Payment method is required');
    });

    test('returns error for invalid method', () {
      expect(OrderValidators.validatePaymentMethod('bitcoin'), 'Select a valid payment method');
    });
  });
}
