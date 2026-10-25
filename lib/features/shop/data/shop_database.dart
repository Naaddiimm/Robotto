import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton SQLite connection for the Shop module.
///
/// Opens its **own** database file `robotto_shop.db`, completely separate
/// from the user database (`robotto.db`). Never edits `DatabaseHelper`.
///
/// Migration policy: `onUpgrade` is non-destructive — it only uses
/// `ALTER TABLE` and `CREATE TABLE`, never drops data.
class ShopDatabase {
  static final ShopDatabase instance = ShopDatabase._init();
  static Database? _database;

  ShopDatabase._init();

  /// Override used only in tests to inject an in-memory database.
  static Database? _testDatabase;
  static void setTestDatabase(Database? db) => _testDatabase = db;

  Future<Database> get database async {
    if (_testDatabase != null) return _testDatabase!;
    if (kIsWeb) {
      throw UnsupportedError(
        'ShopDatabase is not available on web. Use a web-compatible backend instead.',
      );
    }
    if (_database != null) return _database!;
    _database = await _initDB('robotto_shop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onConfigure: _configureDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _configureDB(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // -- products -----------------------------------------------------------
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

    // -- product_images -----------------------------------------------------
    await db.execute('''
      CREATE TABLE product_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        path TEXT NOT NULL,
        position INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    // -- orders -------------------------------------------------------------
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

    // -- order_items --------------------------------------------------------
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

    // -- deliveries ---------------------------------------------------------
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

    // -- cart_items ---------------------------------------------------------
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

    // -- indexes ------------------------------------------------------------
    await db.execute(
      'CREATE INDEX idx_products_seller_id ON products (seller_id)',
    );
    await db.execute(
      'CREATE INDEX idx_products_category ON products (category)',
    );
    await db.execute('CREATE INDEX idx_orders_buyer_id ON orders (buyer_id)');
    await db.execute(
      'CREATE INDEX idx_order_items_seller_id ON order_items (seller_id)',
    );
    await db.execute(
      'CREATE INDEX idx_cart_items_user_id ON cart_items (user_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cart_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          added_at TEXT NOT NULL,
          FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
          UNIQUE(user_id, product_id)
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items (user_id)',
      );
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
