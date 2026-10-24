import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:robotto/features/shop/data/repositories/product_repository.dart';
import 'package:robotto/features/shop/data/models/product.dart';
import 'package:robotto/features/shop/data/models/product_image.dart';
import 'helpers/test_db.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late ProductRepository repo;

  setUp(() async {
    await setUpTestDb();
    repo = ProductRepository();
  });

  tearDown(() async {
    final db = await setUpTestDb(); // re-sets a fresh one if needed
    await tearDownTestDb(db);
  });

  // ---------------------------------------------------------------------------
  // Insert
  // ---------------------------------------------------------------------------

  test('insert with images — product and image rows created', () async {
    final db = await setUpTestDb();
    try {
      final product = _makeProduct(sellerId: 1);
      final images = [
        ProductImage(productId: 0, path: '/img1.jpg', position: 0),
        ProductImage(productId: 0, path: '/img2.jpg', position: 1),
      ];
      final id = await repo.insert(product, images);
      expect(id, greaterThan(0));
      final loaded = await repo.getById(id);
      expect(loaded, isNotNull);
      expect(loaded!.images.length, 2);
      expect(loaded.images.first.position, 0);
    } finally {
      await tearDownTestDb(db);
    }
  });

  // ---------------------------------------------------------------------------
  // Update — ownership enforced
  // ---------------------------------------------------------------------------

  test('update by owner succeeds', () async {
    final db = await setUpTestDb();
    try {
      final pid = await insertProduct(db, sellerId: 1, name: 'Old');
      final product = (await repo.getById(pid))!.product;
      await repo.update(product.copyWith(name: 'New'), []);
      final updated = await repo.getById(pid);
      expect(updated!.product.name, 'New');
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('update by non-owner does nothing (no rows updated)', () async {
    final db = await setUpTestDb();
    try {
      final pid = await insertProduct(db, sellerId: 1, name: 'Original');
      final product = (await repo.getById(pid))!.product;
      // Update with wrong sellerId
      await repo.update(product.copyWith(sellerId: 99, name: 'Hacked'), []);
      final check = await repo.getById(pid);
      expect(check!.product.name, 'Original'); // unchanged
    } finally {
      await tearDownTestDb(db);
    }
  });

  // ---------------------------------------------------------------------------
  // Delete — ownership and active orders
  // ---------------------------------------------------------------------------

  test('delete by owner without active order succeeds', () async {
    final db = await setUpTestDb();
    try {
      final pid = await insertProduct(db, sellerId: 1);
      await repo.delete(pid, 1);
      final check = await repo.getById(pid);
      expect(check, isNull);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('delete by non-owner — product still exists', () async {
    final db = await setUpTestDb();
    try {
      final pid = await insertProduct(db, sellerId: 1);
      // Wrong sellerId; delete ignores the row (WHERE clause)
      await repo.delete(pid, 99);
      expect(await repo.getById(pid), isNotNull);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('delete refused when active order exists', () async {
    final db = await setUpTestDb();
    try {
      final pid = await insertProduct(db, sellerId: 1);
      final oid = await insertOrder(db, buyerId: 2, status: 'pending');
      await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 1);
      expect(
        () => repo.delete(pid, 1),
        throwsA(isA<Exception>()),
      );
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('delete allowed when order is delivered', () async {
    final db = await setUpTestDb();
    try {
      final pid = await insertProduct(db, sellerId: 1);
      final oid = await insertOrder(db, buyerId: 2, status: 'delivered');
      await insertOrderItem(db, orderId: oid, productId: pid, sellerId: 1);
      await repo.delete(pid, 1);
      expect(await repo.getById(pid), isNull);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('delete cascades image rows', () async {
    final db = await setUpTestDb();
    try {
      final product = _makeProduct(sellerId: 1);
      final pid = await repo.insert(product, [
        ProductImage(productId: 0, path: '/img.jpg', position: 0),
      ]);
      await repo.delete(pid, 1);
      final rows = await db.query('product_images', where: 'product_id = ?', whereArgs: [pid]);
      expect(rows, isEmpty);
    } finally {
      await tearDownTestDb(db);
    }
  });

  // ---------------------------------------------------------------------------
  // getAll — filters and sorts
  // ---------------------------------------------------------------------------

  test('getAll returns all products', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, name: 'Alpha');
      await insertProduct(db, name: 'Beta');
      final results = await repo.getAll();
      expect(results.length, 2);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('getAll search by name', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, name: 'Arduino Sensor');
      await insertProduct(db, name: 'Motor Driver');
      final results = await repo.getAll(search: 'arduino');
      expect(results.length, 1);
      expect(results.first.name, 'Arduino Sensor');
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('getAll filter by category', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, category: 'Sensors');
      await insertProduct(db, category: 'Batteries');
      final results = await repo.getAll(category: 'Sensors');
      expect(results.length, 1);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('getAll inStockOnly filters out zero stock', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, name: 'In Stock', stock: 10);
      await insertProduct(db, name: 'Out', stock: 0);
      final results = await repo.getAll(inStockOnly: true);
      expect(results.length, 1);
      expect(results.first.name, 'In Stock');
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('getAll price range', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, price: 5.0, name: 'Cheap');
      await insertProduct(db, price: 50.0, name: 'Expensive');
      final results = await repo.getAll(minPrice: 10.0, maxPrice: 100.0);
      expect(results.length, 1);
      expect(results.first.name, 'Expensive');
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('getAll filter by brand', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, brand: 'Arduino', name: 'P1');
      await insertProduct(db, brand: 'Raspberry', name: 'P2');
      final results = await repo.getAll(brand: 'Arduino');
      expect(results.length, 1);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('getAll filter by level', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, level: 'Beginner', name: 'B');
      await insertProduct(db, level: 'Advanced', name: 'A');
      final results = await repo.getAll(level: 'Advanced');
      expect(results.length, 1);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('sort price_low_high', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, price: 30.0, name: 'High');
      await insertProduct(db, price: 5.0, name: 'Low');
      final results = await repo.getAll(sort: 'price_low_high');
      expect(results.first.price, 5.0);
    } finally {
      await tearDownTestDb(db);
    }
  });

  test('sort name_az', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, name: 'Zebra');
      await insertProduct(db, name: 'Alpha');
      final results = await repo.getAll(sort: 'name_az');
      expect(results.first.name, 'Alpha');
    } finally {
      await tearDownTestDb(db);
    }
  });

  // ---------------------------------------------------------------------------
  // getBySeller
  // ---------------------------------------------------------------------------

  test('getBySellerWithCover returns only seller products', () async {
    final db = await setUpTestDb();
    try {
      await insertProduct(db, sellerId: 1, name: 'Mine');
      await insertProduct(db, sellerId: 2, name: 'Theirs');
      final results = await repo.getBySellerWithCover(1);
      expect(results.length, 1);
      expect(results.first.product.name, 'Mine');
    } finally {
      await tearDownTestDb(db);
    }
  });
}

Product _makeProduct({int sellerId = 1}) => Product(
      sellerId: sellerId,
      name: 'Test Product',
      description: 'A description long enough to pass validation',
      category: 'Sensors',
      level: 'Beginner',
      price: 10.0,
      stock: 50,
      weightKg: 0.5,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
