import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/shop/validators/order_validators.dart';
import 'package:robotto/shop/data/models/order.dart';

void main() {
  // ===========================================================================
  // nextStatus
  // ===========================================================================
  group('OrderValidators.nextStatus', () {
    test('returns the correct next status in the flow', () {
      expect(OrderValidators.nextStatus('pending'), 'preparing');
      expect(OrderValidators.nextStatus('preparing'), 'shipped');
      expect(OrderValidators.nextStatus('shipped'), 'out_for_delivery');
      expect(OrderValidators.nextStatus('out_for_delivery'), 'delivered');
    });

    test('returns null for delivered (terminal)', () {
      expect(OrderValidators.nextStatus('delivered'), isNull);
    });

    test('returns null for cancelled (terminal)', () {
      expect(OrderValidators.nextStatus('cancelled'), isNull);
    });

    test('returns null for unknown status', () {
      expect(OrderValidators.nextStatus('unknown'), isNull);
    });
  });

  // ===========================================================================
  // canAdvance
  // ===========================================================================
  group('OrderValidators.canAdvance', () {
    test('returns true for valid one-step-forward transitions', () {
      expect(OrderValidators.canAdvance('pending', 'preparing'), isTrue);
      expect(OrderValidators.canAdvance('preparing', 'shipped'), isTrue);
      expect(OrderValidators.canAdvance('shipped', 'out_for_delivery'), isTrue);
      expect(OrderValidators.canAdvance('out_for_delivery', 'delivered'), isTrue);
    });

    test('returns false for skipped steps', () {
      expect(OrderValidators.canAdvance('pending', 'shipped'), isFalse);
      expect(OrderValidators.canAdvance('pending', 'out_for_delivery'), isFalse);
      expect(OrderValidators.canAdvance('pending', 'delivered'), isFalse);
      expect(OrderValidators.canAdvance('preparing', 'out_for_delivery'), isFalse);
      expect(OrderValidators.canAdvance('preparing', 'delivered'), isFalse);
      expect(OrderValidators.canAdvance('shipped', 'delivered'), isFalse);
    });

    test('returns false for backward steps', () {
      expect(OrderValidators.canAdvance('preparing', 'pending'), isFalse);
      expect(OrderValidators.canAdvance('shipped', 'preparing'), isFalse);
      expect(OrderValidators.canAdvance('out_for_delivery', 'shipped'), isFalse);
      expect(OrderValidators.canAdvance('delivered', 'out_for_delivery'), isFalse);
    });

    test('returns false for same status', () {
      expect(OrderValidators.canAdvance('pending', 'pending'), isFalse);
      expect(OrderValidators.canAdvance('preparing', 'preparing'), isFalse);
      expect(OrderValidators.canAdvance('shipped', 'shipped'), isFalse);
    });

    test('returns false when advancing from delivered (terminal)', () {
      expect(OrderValidators.canAdvance('delivered', 'pending'), isFalse);
      expect(OrderValidators.canAdvance('delivered', 'preparing'), isFalse);
      expect(OrderValidators.canAdvance('delivered', 'shipped'), isFalse);
    });

    test('returns false when advancing from cancelled', () {
      expect(OrderValidators.canAdvance('cancelled', 'pending'), isFalse);
      expect(OrderValidators.canAdvance('cancelled', 'preparing'), isFalse);
    });

    test('returns false for unknown status', () {
      expect(OrderValidators.canAdvance('unknown', 'preparing'), isFalse);
    });
  });

  // ===========================================================================
  // canCancel
  // ===========================================================================
  group('OrderValidators.canCancel', () {
    test('returns true for pending', () {
      expect(OrderValidators.canCancel('pending'), isTrue);
    });

    test('returns true for preparing', () {
      expect(OrderValidators.canCancel('preparing'), isTrue);
    });

    test('returns false for shipped', () {
      expect(OrderValidators.canCancel('shipped'), isFalse);
    });

    test('returns false for out_for_delivery', () {
      expect(OrderValidators.canCancel('out_for_delivery'), isFalse);
    });

    test('returns false for delivered', () {
      expect(OrderValidators.canCancel('delivered'), isFalse);
    });

    test('returns false for cancelled (already cancelled)', () {
      expect(OrderValidators.canCancel('cancelled'), isFalse);
    });

    test('returns false for unknown status', () {
      expect(OrderValidators.canCancel('unknown'), isFalse);
    });
  });

  // ===========================================================================
  // canDelete
  // ===========================================================================
  group('OrderValidators.canDelete', () {
    test('returns true for cancelled', () {
      expect(OrderValidators.canDelete('cancelled'), isTrue);
    });

    test('returns true for delivered', () {
      expect(OrderValidators.canDelete('delivered'), isTrue);
    });

    test('returns false for pending', () {
      expect(OrderValidators.canDelete('pending'), isFalse);
    });

    test('returns false for preparing', () {
      expect(OrderValidators.canDelete('preparing'), isFalse);
    });

    test('returns false for shipped', () {
      expect(OrderValidators.canDelete('shipped'), isFalse);
    });

    test('returns false for out_for_delivery', () {
      expect(OrderValidators.canDelete('out_for_delivery'), isFalse);
    });

    test('returns false for unknown status', () {
      expect(OrderValidators.canDelete('unknown'), isFalse);
    });
  });

  // ===========================================================================
  // Order model constants (verify the flow is correct)
  // ===========================================================================
  group('Order.flowStatuses', () {
    test('has exactly 5 statuses in order', () {
      expect(Order.flowStatuses.length, 5);
      expect(Order.flowStatuses[0], 'pending');
      expect(Order.flowStatuses[1], 'preparing');
      expect(Order.flowStatuses[2], 'shipped');
      expect(Order.flowStatuses[3], 'out_for_delivery');
      expect(Order.flowStatuses[4], 'delivered');
    });

    test('statuses include cancelled at the end', () {
      expect(Order.statuses.length, 6);
      expect(Order.statuses.contains('cancelled'), isTrue);
    });
  });
}
