import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/validators/order_validators.dart';

void main() {
  // -- Quantity --
  group('validateQuantity', () {
    test('valid', () => expect(OrderValidators.validateQuantity('1', 10), isNull));
    test('at stock', () => expect(OrderValidators.validateQuantity('10', 10), isNull));
    test('above stock → error', () => expect(OrderValidators.validateQuantity('11', 10), isNotNull));
    test('0 → error', () => expect(OrderValidators.validateQuantity('0', 10), isNotNull));
    test('negative → error', () => expect(OrderValidators.validateQuantity('-1', 10), isNotNull));
    test('float → error', () => expect(OrderValidators.validateQuantity('1.5', 10), isNotNull));
    test('empty → error', () => expect(OrderValidators.validateQuantity('', 10), isNotNull));
  });

  // -- Recipient name --
  group('validateRecipientName', () {
    test('valid', () => expect(OrderValidators.validateRecipientName('Ahmed Ben'), isNull));
    test('3 chars → valid', () => expect(OrderValidators.validateRecipientName('Abc'), isNull));
    test('2 chars → error', () => expect(OrderValidators.validateRecipientName('AB'), isNotNull));
    test('60 chars → valid', () => expect(OrderValidators.validateRecipientName('A' * 60), isNull));
    test('61 chars → error', () => expect(OrderValidators.validateRecipientName('A' * 61), isNotNull));
    test('empty → error', () => expect(OrderValidators.validateRecipientName(''), isNotNull));
  });

  // -- Phone --
  group('validatePhone', () {
    test('8 digits', () => expect(OrderValidators.validatePhone('12345678'), isNull));
    test('+216 prefix', () => expect(OrderValidators.validatePhone('+21612345678'), isNull));
    test('216 prefix', () => expect(OrderValidators.validatePhone('21612345678'), isNull));
    test('spaces', () => expect(OrderValidators.validatePhone('12 34 56 78'), isNull));
    test('+216 with spaces', () => expect(OrderValidators.validatePhone('+216 12 34 56 78'), isNull));
    test('7 digits → error', () => expect(OrderValidators.validatePhone('1234567'), isNotNull));
    test('9 digits → error', () => expect(OrderValidators.validatePhone('123456789'), isNotNull));
    test('letters → error', () => expect(OrderValidators.validatePhone('abcdefgh'), isNotNull));
    test('empty → error', () => expect(OrderValidators.validatePhone(''), isNotNull));
  });

  // -- Address --
  group('validateAddress', () {
    test('valid home', () => expect(OrderValidators.validateAddress('123 Rue de la Paix Tunis', 'home'), isNull));
    test('valid relay', () => expect(OrderValidators.validateAddress('Relay Point 45 Ariana', 'relay_point'), isNull));
    test('store_pickup any → valid', () => expect(OrderValidators.validateAddress('', 'store_pickup'), isNull));
    test('9 chars home → error', () => expect(OrderValidators.validateAddress('123 Rd Av', 'home'), isNotNull));
    test('10 chars → valid', () => expect(OrderValidators.validateAddress('123456789a', 'home'), isNull));
    test('120 chars → valid', () => expect(OrderValidators.validateAddress('A' * 119 + 'b', 'home'), isNull));
    test('121 chars → error', () => expect(OrderValidators.validateAddress('A' * 121, 'home'), isNotNull));
    test('only digits → error', () => expect(OrderValidators.validateAddress('1234567890', 'home'), isNotNull));
    test('empty home → error', () => expect(OrderValidators.validateAddress('', 'home'), isNotNull));
  });

  // -- City --
  group('validateCity', () {
    test('valid', () => expect(OrderValidators.validateCity('Tunis'), isNull));
    test('2 chars → valid', () => expect(OrderValidators.validateCity('AB'), isNull));
    test('1 char → error', () => expect(OrderValidators.validateCity('A'), isNotNull));
    test('40 chars → valid', () => expect(OrderValidators.validateCity('A' * 40), isNull));
    test('41 chars → error', () => expect(OrderValidators.validateCity('A' * 41), isNotNull));
    test('empty → error', () => expect(OrderValidators.validateCity(''), isNotNull));
  });

  // -- Zone --
  group('validateZone', () {
    test('grand_tunis', () => expect(OrderValidators.validateZone('grand_tunis'), isNull));
    test('north', () => expect(OrderValidators.validateZone('north'), isNull));
    test('center', () => expect(OrderValidators.validateZone('center'), isNull));
    test('south', () => expect(OrderValidators.validateZone('south'), isNull));
    test('invalid → error', () => expect(OrderValidators.validateZone('east'), isNotNull));
    test('empty → error', () => expect(OrderValidators.validateZone(''), isNotNull));
  });

  // -- Delivery mode --
  group('validateDeliveryMode', () {
    test('home', () => expect(OrderValidators.validateDeliveryMode('home'), isNull));
    test('relay_point', () => expect(OrderValidators.validateDeliveryMode('relay_point'), isNull));
    test('store_pickup', () => expect(OrderValidators.validateDeliveryMode('store_pickup'), isNull));
    test('invalid → error', () => expect(OrderValidators.validateDeliveryMode('drone'), isNotNull));
  });

  // -- Payment method --
  group('validatePaymentMethod', () {
    test('cash_on_delivery', () => expect(OrderValidators.validatePaymentMethod('cash_on_delivery'), isNull));
    test('card → error (coming soon)', () => expect(OrderValidators.validatePaymentMethod('card'), isNotNull));
    test('mobile_wallet → error', () => expect(OrderValidators.validatePaymentMethod('mobile_wallet'), isNotNull));
    test('invalid → error', () => expect(OrderValidators.validatePaymentMethod('bitcoin'), isNotNull));
    test('empty → error', () => expect(OrderValidators.validatePaymentMethod(''), isNotNull));
  });
}
