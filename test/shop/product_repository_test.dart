import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/shop/data/repositories/product_repository.dart';
import 'package:robotto/shop/data/models/product.dart';
import 'package:robotto/shop/data/models/product_image.dart';

/// Tests for ProductRepository pure logic (no DB required).
///
/// Full repository tests (insert, update, delete, getAll) require
/// sqflite_common_ffi for in-memory database testing, which is not
/// in the project's dependencies. To enable those tests, add
/// `sqflite_common_ffi` to dev_dependencies in pubspec.yaml and
/// initialize it with `sqfliteFfiInit()` + `databaseFactory = databaseFactoryFfi`.
void main() {
  group('ProductWithImages', () {
    test('holds product and images', () {
      final product = Product(
        sellerId: 1,
        name: 'Arduino',
        description: 'A development board',
        category: 'Development boards',
        level: 'Beginner',
        price: 25.0,
        stock: 10,
        weightKg: 0.1,
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-01-01T00:00:00.000',
      );
      final images = [
        ProductImage(productId: 0, path: '/data/img1.jpg', position: 0),
        ProductImage(productId: 0, path: '/data/img2.jpg', position: 1),
      ];
      final pwi = ProductWithImages(product: product, images: images);
      expect(pwi.product.name, 'Arduino');
      expect(pwi.images.length, 2);
      expect(pwi.images.first.position, 0);
    });
  });

  group('ProductWithCover', () {
    test('holds product and cover path', () {
      final product = Product(
        id: 1,
        sellerId: 1,
        name: 'Sensor',
        description: 'A temperature sensor',
        category: 'Sensors',
        level: 'Intermediate',
        price: 15.0,
        stock: 5,
        weightKg: 0.05,
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-01-01T00:00:00.000',
      );
      final pwc = ProductWithCover(product: product, coverPath: '/data/cover.jpg');
      expect(pwc.product.id, 1);
      expect(pwc.coverPath, '/data/cover.jpg');
    });

    test('coverPath can be null', () {
      final product = Product(
        id: 1,
        sellerId: 1,
        name: 'Sensor',
        description: 'A temperature sensor',
        category: 'Sensors',
        level: 'Intermediate',
        price: 15.0,
        stock: 5,
        weightKg: 0.05,
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-01-01T00:00:00.000',
      );
      final pwc = ProductWithCover(product: product);
      expect(pwc.coverPath, isNull);
    });
  });

  group('ProductRepository instantiation', () {
    test('can be instantiated', () {
      expect(ProductRepository(), isNotNull);
    });
  });

  group('Product model round-trip (used by repository)', () {
    test('toMap and fromMap round-trip preserves all fields', () {
      final product = Product(
        id: 42,
        sellerId: 7,
        name: 'Test Product',
        description: 'A test description here',
        category: 'Tools',
        brand: 'TestBrand',
        level: 'Advanced',
        price: 99.99,
        stock: 50,
        weightKg: 1.5,
        manualPath: '/data/manual.pdf',
        manualName: 'manual.pdf',
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-06-01T00:00:00.000',
      );
      final map = product.toMap();
      final restored = Product.fromMap(map);

      expect(restored.id, 42);
      expect(restored.sellerId, 7);
      expect(restored.name, 'Test Product');
      expect(restored.description, 'A test description here');
      expect(restored.category, 'Tools');
      expect(restored.brand, 'TestBrand');
      expect(restored.level, 'Advanced');
      expect(restored.price, 99.99);
      expect(restored.stock, 50);
      expect(restored.weightKg, 1.5);
      expect(restored.manualPath, '/data/manual.pdf');
      expect(restored.manualName, 'manual.pdf');
      expect(restored.createdAt, '2024-01-01T00:00:00.000');
      expect(restored.updatedAt, '2024-06-01T00:00:00.000');
    });

    test('nullable fields are null when not set', () {
      final map = {
        'id': 1,
        'seller_id': 1,
        'name': 'Test',
        'description': 'Description',
        'category': 'Tools',
        'brand': null,
        'level': 'Beginner',
        'price': 10.0,
        'stock': 5,
        'weight_kg': 0.5,
        'manual_path': null,
        'manual_name': null,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };
      final product = Product.fromMap(map);
      expect(product.brand, isNull);
      expect(product.manualPath, isNull);
      expect(product.manualName, isNull);
    });
  });

  group('ProductImage model round-trip (used by repository)', () {
    test('toMap and fromMap preserves fields', () {
      final image = ProductImage(
        id: 1,
        productId: 42,
        path: '/data/img.jpg',
        position: 0,
      );
      final map = image.toMap();
      final restored = ProductImage.fromMap(map);
      expect(restored.id, 1);
      expect(restored.productId, 42);
      expect(restored.path, '/data/img.jpg');
      expect(restored.position, 0);
    });
  });
}
