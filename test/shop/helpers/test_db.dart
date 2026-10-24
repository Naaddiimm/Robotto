import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:robotto/features/shop/data/shop_database.dart';

/// Opens a fresh in-memory shop database, creates the full schema, and
/// registers it as the test database. Call [tearDownTestDb] in tearDown.
Future<Database> setUpTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 2,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            seller_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            brand TEXT,
            level TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            weight_kg REAL NOT NULL,
            manual_path TEXT,
            manual_name TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE product_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            path TEXT NOT NULL,
            position INTEGER NOT NULL,
            FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            buyer_id INTEGER NOT NULL,
            status TEXT NOT NULL,
            payment_method TEXT NOT NULL,
            subtotal REAL,
            delivery_fee REAL,
            total REAL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            seller_id INTEGER NOT NULL,
            product_name TEXT NOT NULL,
            unit_price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE deliveries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL UNIQUE,
            mode TEXT NOT NULL,
            recipient_name TEXT,
            phone TEXT,
            address TEXT,
            city TEXT,
            zone TEXT,
            total_weight_kg REAL,
            fee REAL,
            status TEXT,
            status_updated_at TEXT,
            FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE cart_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            added_at TEXT NOT NULL,
            FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
            UNIQUE(user_id, product_id)
          )
        ''');
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    ),
  );

  ShopDatabase.setTestDatabase(db);
  return db;
}

Future<void> tearDownTestDb(Database db) async {
  ShopDatabase.setTestDatabase(null);
  await db.close();
}

final _now = DateTime.now().toIso8601String();

/// Inserts a product and returns its id.
Future<int> insertProduct(
  Database db, {
  int sellerId = 1,
  String name = 'Test Product',
  String description = 'A test product description here',
  String category = 'Sensors',
  String level = 'Beginner',
  double price = 10.0,
  int stock = 100,
  double weightKg = 0.5,
  String? brand,
}) async {
  return await db.insert('products', {
    'seller_id': sellerId,
    'name': name,
    'description': description,
    'category': category,
    'brand': brand,
    'level': level,
    'price': price,
    'stock': stock,
    'weight_kg': weightKg,
    'created_at': _now,
    'updated_at': _now,
  });
}

/// Inserts an order and returns its id.
Future<int> insertOrder(
  Database db, {
  int buyerId = 2,
  String status = 'pending',
  String paymentMethod = 'cash_on_delivery',
  double subtotal = 10.0,
  double deliveryFee = 5.0,
  double total = 15.0,
}) async {
  return await db.insert('orders', {
    'buyer_id': buyerId,
    'status': status,
    'payment_method': paymentMethod,
    'subtotal': subtotal,
    'delivery_fee': deliveryFee,
    'total': total,
    'created_at': _now,
    'updated_at': _now,
  });
}

/// Inserts an order_item (snapshot).
Future<void> insertOrderItem(
  Database db, {
  required int orderId,
  required int productId,
  int sellerId = 1,
  String productName = 'Snapshot Name',
  double unitPrice = 10.0,
  int quantity = 1,
}) async {
  await db.insert('order_items', {
    'order_id': orderId,
    'product_id': productId,
    'seller_id': sellerId,
    'product_name': productName,
    'unit_price': unitPrice,
    'quantity': quantity,
  });
}

/// Inserts a delivery row.
Future<void> insertDelivery(
  Database db, {
  required int orderId,
  String mode = 'home',
  String zone = 'grand_tunis',
  String status = 'pending',
}) async {
  await db.insert('deliveries', {
    'order_id': orderId,
    'mode': mode,
    'recipient_name': 'Test User',
    'phone': '12345678',
    'address': '123 Test Street',
    'city': 'Tunis',
    'zone': zone,
    'total_weight_kg': 0.5,
    'fee': 5.0,
    'status': status,
    'status_updated_at': _now,
  });
}

/// Inserts a cart row.
Future<void> insertCartItem(
  Database db, {
  required int userId,
  required int productId,
  int quantity = 1,
}) async {
  await db.insert('cart_items', {
    'user_id': userId,
    'product_id': productId,
    'quantity': quantity,
    'added_at': _now,
  });
}
