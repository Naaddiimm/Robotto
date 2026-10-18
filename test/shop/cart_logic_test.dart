import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/shop/data/models/cart_item.dart';
import 'package:robotto/shop/data/repositories/cart_repository.dart';
import 'package:robotto/shop/data/repositories/order_repository.dart';

/// Tests for pure cart logic helpers (no DB required).
void main() {
  // ---------------------------------------------------------------------------
  // clampQuantity
  // ---------------------------------------------------------------------------

  group('CartRepository.clampQuantity', () {
    test('returns qty when within 1..stock', () {
      expect(CartRepository.clampQuantity(1, 10), 1);
      expect(CartRepository.clampQuantity(5, 10), 5);
      expect(CartRepository.clampQuantity(10, 10), 10);
    });

    test('clamps to stock when qty exceeds stock', () {
      expect(CartRepository.clampQuantity(11, 10), 10);
      expect(CartRepository.clampQuantity(100, 5), 5);
    });

    test('returns 1 when qty < 1 and stock > 0', () {
      expect(CartRepository.clampQuantity(0, 10), 1);
      expect(CartRepository.clampQuantity(-5, 10), 1);
    });

    test('returns 0 when stock is 0', () {
      expect(CartRepository.clampQuantity(1, 0), 0);
      expect(CartRepository.clampQuantity(5, 0), 0);
    });

    test('returns 0 when stock is negative', () {
      expect(CartRepository.clampQuantity(1, -1), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // subtotal
  // ---------------------------------------------------------------------------

  group('CartRepository.subtotal', () {
    test('returns 0 for empty list', () {
      expect(CartRepository.subtotal([]), 0);
    });

    test('calculates correct subtotal for single line', () {
      final line = _makeLine(productId: 1, qty: 3, price: 10.0);
      expect(CartRepository.subtotal([line]), 30.0);
    });

    test('calculates correct subtotal for multiple lines', () {
      final lines = [
        _makeLine(productId: 1, qty: 2, price: 10.0),
        _makeLine(productId: 2, qty: 3, price: 5.0),
        _makeLine(productId: 3, qty: 1, price: 100.0),
      ];
      expect(CartRepository.subtotal(lines), 20.0 + 15.0 + 100.0);
    });
  });

  // ---------------------------------------------------------------------------
  // groupBySeller
  // ---------------------------------------------------------------------------

  group('CartRepository.groupBySeller', () {
    test('groups lines by seller (2 sellers, 3 products)', () {
      final lines = [
        _makeLine(productId: 1, qty: 2, price: 10.0, sellerId: 100),
        _makeLine(productId: 2, qty: 1, price: 5.0, sellerId: 200),
        _makeLine(productId: 3, qty: 3, price: 20.0, sellerId: 100),
      ];
      final groups = CartRepository.groupBySeller(lines);
      expect(groups.length, 2);
      final seller100 =
          groups.firstWhere((g) => g.sellerId == 100);
      expect(seller100.lines.length, 2);
      expect(seller100.lines[0].item.productId, 1);
      expect(seller100.lines[1].item.productId, 3);
      final seller200 =
          groups.firstWhere((g) => g.sellerId == 200);
      expect(seller200.lines.length, 1);
      expect(seller200.lines[0].item.productId, 2);
    });

    test('skips unavailable lines', () {
      final lines = [
        _makeLine(productId: 1, qty: 2, price: 10.0, sellerId: 100),
        _makeLine(
            productId: 2, qty: 1, price: 5.0, sellerId: 200, unavailable: true),
      ];
      final groups = CartRepository.groupBySeller(lines);
      expect(groups.length, 1);
      expect(groups.first.sellerId, 100);
    });

    test('returns empty list for all unavailable', () {
      final lines = [
        _makeLine(
            productId: 1, qty: 2, price: 10.0, sellerId: 100, unavailable: true),
      ];
      expect(CartRepository.groupBySeller(lines), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // AddToCartResult
  // ---------------------------------------------------------------------------

  group('AddToCartResult', () {
    test('constructs with defaults', () {
      const result = AddToCartResult(added: true, finalQuantity: 5);
      expect(result.added, true);
      expect(result.clamped, false);
      expect(result.finalQuantity, 5);
    });

    test('constructs with clamped flag', () {
      const result = AddToCartResult(
          added: true, clamped: true, finalQuantity: 3);
      expect(result.clamped, true);
      expect(result.finalQuantity, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // CartCheckoutResult
  // ---------------------------------------------------------------------------

  group('CartCheckoutResult', () {
    test('constructs with success', () {
      const result = CartCheckoutResult(
          success: true, orderIds: [1, 2]);
      expect(result.success, true);
      expect(result.orderIds, [1, 2]);
      expect(result.failedProducts, isEmpty);
    });

    test('constructs with failure', () {
      const result = CartCheckoutResult(
          success: false, failedProducts: ['Product A']);
      expect(result.success, false);
      expect(result.failedProducts, ['Product A']);
    });
  });

  // ---------------------------------------------------------------------------
  // SellerGroup
  // ---------------------------------------------------------------------------

  group('SellerGroup', () {
    test('holds sellerId and lines', () {
      final lines = [_makeLine(productId: 1, qty: 1, price: 10, sellerId: 50)];
      final group = SellerGroup(sellerId: 50, lines: lines);
      expect(group.sellerId, 50);
      expect(group.lines.length, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // CartLine
  // ---------------------------------------------------------------------------

  group('CartLine', () {
    test('lineTotal = unitPrice * quantity', () {
      final line = _makeLine(productId: 1, qty: 4, price: 7.5);
      expect(line.lineTotal, 30.0);
    });

    test('hasIssue is false for a healthy line', () {
      final line = _makeLine(productId: 1, qty: 2, price: 10, stock: 10);
      expect(line.hasIssue, false);
    });

    test('hasIssue is true when unavailable', () {
      final line = _makeLine(
          productId: 1, qty: 1, price: 10, stock: 5, unavailable: true);
      expect(line.hasIssue, true);
    });

    test('hasIssue is true when outOfStock', () {
      final line = _makeLine(
          productId: 1, qty: 1, price: 10, stock: 0, outOfStock: true);
      expect(line.hasIssue, true);
    });

    test('hasIssue is true when quantityExceedsStock', () {
      final line = _makeLine(
          productId: 1, qty: 5, price: 10, stock: 3,
          quantityExceedsStock: true);
      expect(line.hasIssue, true);
    });
  });
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

CartLine _makeLine({
  required int productId,
  required int qty,
  required double price,
  int stock = 100,
  int sellerId = 1,
  bool unavailable = false,
  bool outOfStock = false,
  bool quantityExceedsStock = false,
}) {
  return CartLine(
    item: CartItem(
      userId: 1,
      productId: productId,
      quantity: qty,
      addedAt: '2024-01-01T00:00:00.000',
    ),
    productName: 'Product $productId',
    unitPrice: price,
    stock: stock,
    sellerId: sellerId,
    weightKg: 0.5,
    unavailable: unavailable,
    outOfStock: outOfStock,
    quantityExceedsStock: quantityExceedsStock,
  );
}
