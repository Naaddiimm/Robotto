import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:robotto/features/shop/data/repositories/order_repository.dart';
import 'package:robotto/features/shop/data/models/product.dart';
import 'helpers/test_db.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late OrderRepository repo;

  setUp(() async {
    db = await setUpTestDb();
    repo = OrderRepository();
  });

  tearDown(() => tearDownTestDb(db));

  // ---------------------------------------------------------------------------
  // createOrder
  // ---------------------------------------------------------------------------

  test('inserts order, item snapshot, delivery, decreases stock', () async {
    final pid = await insertProduct(db, sellerId: 1, price: 20.0, stock: 10, weightKg: 1.0, name: 'Test');
    final product = _product(id: pid, sellerId: 1, price: 20.0, stock: 10, weight: 1.0, name: 'Test');
    final orderId = await repo.createOrder(
      buyerId: 2, product: product, quantity: 2,
      recipientName: 'Bob', phone: '12345678',
      address: '123 Test Street Tunis', city: 'Tunis',
      zone: 'grand_tunis', deliveryMode: 'home',
      paymentMethod: 'cash_on_delivery',
    );
    expect(orderId, greaterThan(0));
    final stockRow = await db.query('products', where: 'id = ?', whereArgs: [pid]);
    expect(stockRow.first['stock'], 8);
    final items = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    expect(items.first['product_name'], 'Test');
    expect(items.first['unit_price'], 20.0);
    final dels = await db.query('deliveries', where: 'order_id = ?', whereArgs: [orderId]);
    expect(dels.first['status'], 'pending');
  });

  test('refuses own product', () async {
    final pid = await insertProduct(db, sellerId: 1);
    final product = _product(id: pid, sellerId: 1);
    expect(
      () => repo.createOrder(buyerId: 1, product: product, quantity: 1,
        recipientName: 'A', phone: '12345678', address: '123 Test St', city: 'Tunis',
        zone: 'grand_tunis', deliveryMode: 'home', paymentMethod: 'cash_on_delivery'),
      throwsA(isA<Exception>()),
    );
  });

  test('refuses quantity above stock', () async {
    final pid = await insertProduct(db, sellerId: 1, stock: 3);
    final product = _product(id: pid, sellerId: 1, stock: 3);
    expect(
      () => repo.createOrder(buyerId: 2, product: product, quantity: 5,
        recipientName: 'A', phone: '12345678', address: '123 Test St', city: 'Tunis',
        zone: 'grand_tunis', deliveryMode: 'home', paymentMethod: 'cash_on_delivery'),
      throwsA(isA<Exception>()),
    );
  });

  test('store_pickup → fee 0, total = subtotal', () async {
    final pid = await insertProduct(db, sellerId: 1, price: 10.0, stock: 5, weightKg: 0.5);
    final product = _product(id: pid, sellerId: 1, price: 10.0, stock: 5);
    final orderId = await repo.createOrder(
      buyerId: 2, product: product, quantity: 1,
      recipientName: 'A', phone: '12345678', address: '',
      city: 'Tunis', zone: 'grand_tunis', deliveryMode: 'store_pickup',
      paymentMethod: 'cash_on_delivery',
    );
    final rows = await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    expect(rows.first['delivery_fee'], 0.0);
    expect(rows.first['total'], 10.0);
  });

  test('total = subtotal + fee for home delivery', () async {
    final pid = await insertProduct(db, sellerId: 1, price: 10.0, stock: 5, weightKg: 1.0);
    final product = _product(id: pid, sellerId: 1, price: 10.0, stock: 5, weight: 1.0);
    final orderId = await repo.createOrder(
      buyerId: 2, product: product, quantity: 1,
      recipientName: 'A', phone: '12345678', address: '123 Test St',
      city: 'Tunis', zone: 'grand_tunis', deliveryMode: 'home',
      paymentMethod: 'cash_on_delivery',
    );
    // grand_tunis: base 5 + 1*1 = 6 fee; total = 10 + 6 = 16
    final rows = await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    expect(rows.first['delivery_fee'], 6.0);
    expect(rows.first['total'], 16.0);
  });

  // ---------------------------------------------------------------------------
  // advanceStatus
  // ---------------------------------------------------------------------------

  test('pending → preparing updates both order and delivery', () async {
    final pid = await insertProduct(db, sellerId: 1);
    final oid = await insertOrder(db, buyerId: 2, status: 'pending');
    await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 1);
    await insertDelivery(db, orderId: oid, status: 'pending');
    await repo.advanceStatus(orderId: oid, sellerId: 1);
    final order = await db.query('orders', where: 'id = ?', whereArgs: [oid]);
    expect(order.first['status'], 'preparing');
    final del = await db.query('deliveries', where: 'order_id = ?', whereArgs: [oid]);
    expect(del.first['status'], 'preparing');
  });

  test('wrong seller throws', () async {
    final oid = await insertOrder(db, buyerId: 2, status: 'pending');
    final pid = await insertProduct(db, sellerId: 1);
    await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 1);
    await insertDelivery(db, orderId: oid);
    expect(
      () => repo.advanceStatus(orderId: oid, sellerId: 99),
      throwsA(isA<Exception>()),
    );
  });

  test('delivered is terminal — advance throws', () async {
    final oid = await insertOrder(db, buyerId: 2, status: 'delivered');
    final pid = await insertProduct(db, sellerId: 1);
    await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 1);
    await insertDelivery(db, orderId: oid, status: 'delivered');
    expect(
      () => repo.advanceStatus(orderId: oid, sellerId: 1),
      throwsA(isA<Exception>()),
    );
  });

  // ---------------------------------------------------------------------------
  // cancelOrder
  // ---------------------------------------------------------------------------

  test('cancel from pending restores stock', () async {
    final pid = await insertProduct(db, sellerId: 1, stock: 8);
    final oid = await insertOrder(db, buyerId: 2, status: 'pending');
    await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 1, quantity: 2);
    await insertDelivery(db, orderId: oid);
    await repo.cancelOrder(orderId: oid, buyerId: 2);
    final order = await db.query('orders', where: 'id = ?', whereArgs: [oid]);
    expect(order.first['status'], 'cancelled');
    final prod = await db.query('products', where: 'id = ?', whereArgs: [pid]);
    expect(prod.first['stock'], 10); // 8 + 2
  });

  test('cancel from shipped throws', () async {
    final oid = await insertOrder(db, buyerId: 2, status: 'shipped');
    await insertDelivery(db, orderId: oid, status: 'shipped');
    expect(
      () => repo.cancelOrder(orderId: oid, buyerId: 2),
      throwsA(isA<Exception>()),
    );
  });

  // ---------------------------------------------------------------------------
  // deleteOrder
  // ---------------------------------------------------------------------------

  test('delete cancelled cascades items and delivery', () async {
    final pid = await insertProduct(db, sellerId: 1);
    final oid = await insertOrder(db, buyerId: 2, status: 'cancelled');
    await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 1);
    await insertDelivery(db, orderId: oid, status: 'cancelled');
    await repo.deleteOrder(orderId: oid, buyerId: 2);
    expect(await db.query('orders', where: 'id = ?', whereArgs: [oid]), isEmpty);
    expect(await db.query('order_items', where: 'order_id = ?', whereArgs: [oid]), isEmpty);
    expect(await db.query('deliveries', where: 'order_id = ?', whereArgs: [oid]), isEmpty);
  });

  test('delete pending throws', () async {
    final oid = await insertOrder(db, buyerId: 2, status: 'pending');
    expect(
      () => repo.deleteOrder(orderId: oid, buyerId: 2),
      throwsA(isA<Exception>()),
    );
  });

  // ---------------------------------------------------------------------------
  // Visibility
  // ---------------------------------------------------------------------------

  test('getMyOrders returns only this buyer', () async {
    await insertOrder(db, buyerId: 2);
    await insertOrder(db, buyerId: 3);
    final orders = await repo.getMyOrders(2);
    expect(orders.length, 1);
  });

  test('getReceivedOrders returns only this seller', () async {
    final pid = await insertProduct(db, sellerId: 10);
    final oid = await insertOrder(db, buyerId: 2);
    await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 10);
    final pid2 = await insertProduct(db, sellerId: 20);
    final oid2 = await insertOrder(db, buyerId: 3);
    await insertOrderItem(db, orderId: oid2, productId: pid2, sellerId: 20);
    final received = await repo.getReceivedOrders(10);
    expect(received.length, 1);
    expect(received.first.id, oid);
  });

  // ---------------------------------------------------------------------------
  // updateOrderDetails (buyer, only while pending)
  // ---------------------------------------------------------------------------

  test('buyer edits address while pending', () async {
    final pid = await insertProduct(db, sellerId: 1, price: 10.0, stock: 5, weightKg: 1.0);
    final product = _product(id: pid, sellerId: 1, price: 10.0, stock: 5, weight: 1.0);
    final oid = await repo.createOrder(
      buyerId: 2, product: product, quantity: 1,
      recipientName: 'A', phone: '12345678', address: '123 Old Street',
      city: 'Tunis', zone: 'grand_tunis', deliveryMode: 'home',
      paymentMethod: 'cash_on_delivery',
    );
    await repo.updateOrderDetails(orderId: oid, buyerId: 2, address: '456 New Avenue Sfax');
    final del = await db.query('deliveries', where: 'order_id = ?', whereArgs: [oid]);
    expect(del.first['address'], '456 New Avenue Sfax');
  });

  test('buyer cannot edit after preparing', () async {
    final oid = await insertOrder(db, buyerId: 2, status: 'preparing');
    await insertDelivery(db, orderId: oid, status: 'preparing');
    expect(
      () => repo.updateOrderDetails(orderId: oid, buyerId: 2, address: '456 New Ave'),
      throwsA(isA<Exception>()),
    );
  });
}

Product _product({
  required int id,
  required int sellerId,
  double price = 10.0,
  int stock = 50,
  double weight = 0.5,
  String name = 'Product',
}) =>
    Product(
      id: id,
      sellerId: sellerId,
      name: name,
      description: 'A long enough description for test purposes',
      category: 'Sensors',
      level: 'Beginner',
      price: price,
      stock: stock,
      weightKg: weight,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
