import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:robotto/features/shop/data/repositories/cart_repository.dart';
import 'package:robotto/features/shop/data/repositories/order_repository.dart';
import 'package:robotto/features/shop/data/models/cart_item.dart';
import 'helpers/test_db.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late CartRepository repo;

  setUp(() async {
    db = await setUpTestDb();
    repo = CartRepository();
  });

  tearDown(() => tearDownTestDb(db));

  // ---------------------------------------------------------------------------
  // addToCart
  // ---------------------------------------------------------------------------

  test('add new line creates row', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    final result = await repo.addToCart(userId: 2, productId: 1, qty: 3);
    expect(result.added, isTrue);
    expect(result.finalQuantity, 3);
    expect(await repo.itemCount(userId: 2), 3);
  });

  test('add same product merges quantities', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 3);
    await repo.addToCart(userId: 2, productId: 1, qty: 4);
    expect(await repo.itemCount(userId: 2), 7);
  });

  test('add clamps at stock', () async {
    await insertProduct(db, sellerId: 1, stock: 5);
    final result = await repo.addToCart(userId: 2, productId: 1, qty: 10);
    expect(result.clamped, isTrue);
    expect(result.finalQuantity, 5);
  });

  test('add own product throws', () async {
    await insertProduct(db, sellerId: 2, stock: 10);
    expect(
      () => repo.addToCart(userId: 2, productId: 1, qty: 1),
      throwsA(isA<Exception>()),
    );
  });

  test('add stock 0 throws', () async {
    await insertProduct(db, sellerId: 1, stock: 0);
    expect(
      () => repo.addToCart(userId: 2, productId: 1, qty: 1),
      throwsA(isA<Exception>()),
    );
  });

  test('add qty < 1 throws', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    expect(
      () => repo.addToCart(userId: 2, productId: 1, qty: 0),
      throwsA(isA<Exception>()),
    );
  });

  // ---------------------------------------------------------------------------
  // updateQuantity
  // ---------------------------------------------------------------------------

  test('updateQuantity sets new value', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 3);
    await repo.updateQuantity(userId: 2, productId: 1, qty: 7);
    expect(await repo.itemCount(userId: 2), 7);
  });

  test('updateQuantity clamps at stock', () async {
    await insertProduct(db, sellerId: 1, stock: 5);
    await repo.addToCart(userId: 2, productId: 1, qty: 3);
    await repo.updateQuantity(userId: 2, productId: 1, qty: 100);
    expect(await repo.itemCount(userId: 2), 5);
  });

  test('updateQuantity qty < 1 throws', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 3);
    expect(
      () => repo.updateQuantity(userId: 2, productId: 1, qty: 0),
      throwsA(isA<Exception>()),
    );
  });

  // ---------------------------------------------------------------------------
  // remove / clear
  // ---------------------------------------------------------------------------

  test('removeItem deletes the row', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 2);
    await repo.removeItem(userId: 2, productId: 1);
    expect(await repo.itemCount(userId: 2), 0);
  });

  test('clear removes all rows for user', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await insertProduct(db, sellerId: 1, stock: 10, name: 'P2');
    final pid2 = (await db.query('products', orderBy: 'id DESC', limit: 1)).first['id'] as int;
    await repo.addToCart(userId: 2, productId: 1, qty: 1);
    await repo.addToCart(userId: 2, productId: pid2, qty: 1);
    await repo.clear(userId: 2);
    expect(await repo.itemCount(userId: 2), 0);
  });

  // ---------------------------------------------------------------------------
  // Per-user isolation
  // ---------------------------------------------------------------------------

  test('user 2 cart does not affect user 3 cart', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 3);
    await repo.addToCart(userId: 3, productId: 1, qty: 5);
    expect(await repo.itemCount(userId: 2), 3);
    expect(await repo.itemCount(userId: 3), 5);
  });

  test('clear user 2 does not affect user 3', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 2);
    await repo.addToCart(userId: 3, productId: 1, qty: 4);
    await repo.clear(userId: 2);
    expect(await repo.itemCount(userId: 3), 4);
  });

  // ---------------------------------------------------------------------------
  // cartCount notifier
  // ---------------------------------------------------------------------------

  test('cartCount notifier updates after add', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 3);
    await repo.refreshCount(userId: 2);
    expect(repo.cartCount.value, 3);
  });

  test('cartCount notifier updates after remove', () async {
    await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: 1, qty: 3);
    await repo.removeItem(userId: 2, productId: 1);
    await repo.refreshCount(userId: 2);
    expect(repo.cartCount.value, 0);
  });

  // ---------------------------------------------------------------------------
  // subtotal and groupBySeller
  // ---------------------------------------------------------------------------

  test('subtotal sums line totals', () {
    final lines = [
      _line(productId: 1, qty: 2, price: 10.0, sellerId: 1),
      _line(productId: 2, qty: 1, price: 5.0, sellerId: 2),
    ];
    expect(CartRepository.subtotal(lines), 25.0);
  });

  test('groupBySeller groups 2 sellers', () {
    final lines = [
      _line(productId: 1, qty: 1, price: 10.0, sellerId: 10),
      _line(productId: 2, qty: 2, price: 5.0, sellerId: 20),
      _line(productId: 3, qty: 1, price: 8.0, sellerId: 10),
    ];
    final groups = CartRepository.groupBySeller(lines);
    expect(groups.length, 2);
    final g10 = groups.firstWhere((g) => g.sellerId == 10);
    expect(g10.lines.length, 2);
  });

  test('groupBySeller skips unavailable lines', () {
    final lines = [
      _line(productId: 1, qty: 1, price: 10.0, sellerId: 1),
      _line(productId: 2, qty: 1, price: 5.0, sellerId: 2, unavailable: true),
    ];
    final groups = CartRepository.groupBySeller(lines);
    expect(groups.length, 1);
  });

  // ---------------------------------------------------------------------------
  // createOrdersFromCart
  // ---------------------------------------------------------------------------

  test('2 sellers → 2 orders, stock decreased, cart rows deleted', () async {
    final p1 = await insertProduct(db, sellerId: 10, price: 20.0, stock: 5, weightKg: 1.0, name: 'P1');
    final p2 = await insertProduct(db, sellerId: 20, price: 15.0, stock: 3, weightKg: 0.5, name: 'P2');
    await insertCartItem(db, userId: 99, productId: p1, quantity: 2);
    await insertCartItem(db, userId: 99, productId: p2, quantity: 1);

    final lines = await repo.getCartLines(userId: 99);
    final orderRepo = OrderRepository();
    final result = await orderRepo.createOrdersFromCart(
      buyerId: 99,
      lines: lines,
      recipientName: 'TestUser',
      phone: '12345678',
      address: '123 Test Street Tunis',
      city: 'Tunis',
      zone: 'grand_tunis',
      deliveryMode: 'home',
      paymentMethod: 'cash_on_delivery',
    );

    expect(result.success, isTrue);
    expect(result.orderIds.length, 2);

    // Stock decreased
    final s1 = await db.query('products', where: 'id = ?', whereArgs: [p1]);
    expect(s1.first['stock'], 3); // 5-2
    final s2 = await db.query('products', where: 'id = ?', whereArgs: [p2]);
    expect(s2.first['stock'], 2); // 3-1

    // Cart rows deleted
    expect(await repo.itemCount(userId: 99), 0);

    // Each order has its own delivery
    for (final oid in result.orderIds) {
      final dels = await db.query('deliveries', where: 'order_id = ?', whereArgs: [oid]);
      expect(dels.length, 1);
    }
  });

  test('rollback when one line has insufficient stock', () async {
    final p1 = await insertProduct(db, sellerId: 10, price: 20.0, stock: 5, weightKg: 1.0, name: 'OK');
    final p2 = await insertProduct(db, sellerId: 20, price: 15.0, stock: 1, weightKg: 0.5, name: 'Scarce');
    await insertCartItem(db, userId: 99, productId: p1, quantity: 2);
    await insertCartItem(db, userId: 99, productId: p2, quantity: 5); // exceeds stock

    final lines = await repo.getCartLines(userId: 99);
    final orderRepo = OrderRepository();
    final result = await orderRepo.createOrdersFromCart(
      buyerId: 99, lines: lines,
      recipientName: 'TestUser', phone: '12345678', address: '123 Test St',
      city: 'Tunis', zone: 'grand_tunis', deliveryMode: 'home',
      paymentMethod: 'cash_on_delivery',
    );

    expect(result.success, isFalse);
    // Stock unchanged for both products
    final s1 = await db.query('products', where: 'id = ?', whereArgs: [p1]);
    expect(s1.first['stock'], 5);
    final s2 = await db.query('products', where: 'id = ?', whereArgs: [p2]);
    expect(s2.first['stock'], 1);
    // No orders created
    expect(await db.query('orders'), isEmpty);
    // Cart rows still exist
    expect(await repo.itemCount(userId: 99), greaterThan(0));
  });

  test('card payment rejected', () async {
    final p1 = await insertProduct(db, sellerId: 1, stock: 5);
    await insertCartItem(db, userId: 2, productId: p1, quantity: 1);
    final lines = await repo.getCartLines(userId: 2);
    final orderRepo = OrderRepository();
    final result = await orderRepo.createOrdersFromCart(
      buyerId: 2, lines: lines,
      recipientName: 'A', phone: '12345678', address: '123 St',
      city: 'T', zone: 'grand_tunis', deliveryMode: 'home',
      paymentMethod: 'card',
    );
    expect(result.success, isFalse);
  });

  // ---------------------------------------------------------------------------
  // Cascade delete
  // ---------------------------------------------------------------------------

  test('deleting a product removes its cart_items', () async {
    final pid = await insertProduct(db, sellerId: 1, stock: 10);
    await repo.addToCart(userId: 2, productId: pid, qty: 3);
    await db.delete('products', where: 'id = ?', whereArgs: [pid]);
    expect(await repo.itemCount(userId: 2), 0);
  });
}

CartLine _line({
  required int productId,
  required int qty,
  required double price,
  required int sellerId,
  bool unavailable = false,
}) {
  return CartLine(
    item: CartItem(
      userId: 1,
      productId: productId,
      quantity: qty,
      addedAt: DateTime.now().toIso8601String(),
    ),
    productName: 'Product $productId',
    unitPrice: price,
    stock: 100,
    sellerId: sellerId,
    weightKg: 0.5,
    unavailable: unavailable,
  );
}
