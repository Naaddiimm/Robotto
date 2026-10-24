import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/validators/order_validators.dart';

void main() {
  group('nextStatus', () {
    test('pending → preparing', () => expect(OrderValidators.nextStatus('pending'), 'preparing'));
    test('preparing → shipped', () => expect(OrderValidators.nextStatus('preparing'), 'shipped'));
    test('shipped → out_for_delivery', () => expect(OrderValidators.nextStatus('shipped'), 'out_for_delivery'));
    test('out_for_delivery → delivered', () => expect(OrderValidators.nextStatus('out_for_delivery'), 'delivered'));
    test('delivered → null (terminal)', () => expect(OrderValidators.nextStatus('delivered'), isNull));
    test('cancelled → null (terminal)', () => expect(OrderValidators.nextStatus('cancelled'), isNull));
  });

  group('canAdvance', () {
    test('pending→preparing valid', () => expect(OrderValidators.canAdvance('pending', 'preparing'), isTrue));
    test('preparing→shipped valid', () => expect(OrderValidators.canAdvance('preparing', 'shipped'), isTrue));
    test('shipped→out_for_delivery valid', () => expect(OrderValidators.canAdvance('shipped', 'out_for_delivery'), isTrue));
    test('out_for_delivery→delivered valid', () => expect(OrderValidators.canAdvance('out_for_delivery', 'delivered'), isTrue));

    test('pending→shipped skip → false', () => expect(OrderValidators.canAdvance('pending', 'shipped'), isFalse));
    test('pending→delivered skip → false', () => expect(OrderValidators.canAdvance('pending', 'delivered'), isFalse));
    test('shipped→preparing backward → false', () => expect(OrderValidators.canAdvance('shipped', 'preparing'), isFalse));
    test('delivered→anything → false', () => expect(OrderValidators.canAdvance('delivered', 'pending'), isFalse));
    test('same status → false', () => expect(OrderValidators.canAdvance('pending', 'pending'), isFalse));
  });

  group('canCancel', () {
    test('pending → true', () => expect(OrderValidators.canCancel('pending'), isTrue));
    test('preparing → true', () => expect(OrderValidators.canCancel('preparing'), isTrue));
    test('shipped → false', () => expect(OrderValidators.canCancel('shipped'), isFalse));
    test('out_for_delivery → false', () => expect(OrderValidators.canCancel('out_for_delivery'), isFalse));
    test('delivered → false', () => expect(OrderValidators.canCancel('delivered'), isFalse));
    test('cancelled → false', () => expect(OrderValidators.canCancel('cancelled'), isFalse));
  });

  group('canDelete', () {
    test('cancelled → true', () => expect(OrderValidators.canDelete('cancelled'), isTrue));
    test('delivered → true', () => expect(OrderValidators.canDelete('delivered'), isTrue));
    test('pending → false', () => expect(OrderValidators.canDelete('pending'), isFalse));
    test('shipped → false', () => expect(OrderValidators.canDelete('shipped'), isFalse));
  });
}
