import 'package:flutter/foundation.dart';

import '../shop_database.dart';
import '../models/cart_item.dart';

/// Result of an addToCart operation.
class AddToCartResult {
  final bool added;
  final bool clamped;
  final int finalQuantity;
  const AddToCartResult({
    required this.added,
    this.clamped = false,
    required this.finalQuantity,
  });
}

/// A seller group for checkout.
class SellerGroup {
  final int sellerId;
  final List<CartLine> lines;
  SellerGroup({required this.sellerId, required this.lines});
}

/// CRUD repository for cart_items. All methods take a userId and only touch
/// that user's rows. The cart does NOT reserve stock — stock is decreased
/// only at checkout.
class CartRepository {
  final ShopDatabase _dbProvider = ShopDatabase.instance;

  /// Notifier that fires after every cart change. The current value is the
  /// total quantity of items in the current user's cart (sum of quantities).
  final ValueNotifier<int> cartCount = ValueNotifier<int>(0);

  // ---------------------------------------------------------------------------
  // Add
  // ---------------------------------------------------------------------------

  /// Adds [qty] of [productId] to the cart for [userId].
  /// Refuses own product, stock 0, qty < 1. If the line already exists,
  /// merges quantities and clamps at stock.
  Future<AddToCartResult> addToCart({
    required int userId,
    required int productId,
    required int qty,
  }) async {
    if (qty < 1) {
      throw Exception('Quantity must be at least 1.');
    }

    final db = await _dbProvider.database;

    // Get product info
    final productRows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (productRows.isEmpty) {
      throw Exception('Product not found.');
    }
    final stock = productRows.first['stock'] as int;
    final sellerId = productRows.first['seller_id'] as int;

    if (sellerId == userId) {
      throw Exception('You cannot add your own product to the cart.');
    }
    if (stock == 0) {
      throw Exception('This product is out of stock.');
    }

    final clampedQty = clampQuantity(qty, stock);

    final now = DateTime.now().toIso8601String();
    final existing = await db.query(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );

    bool clamped = false;
    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      final newQty = clampQuantity(currentQty + qty, stock);
      clamped = newQty < currentQty + qty;
      await db.update(
        'cart_items',
        {'quantity': newQty},
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
      await _refreshCount(userId);
      return AddToCartResult(
        added: true,
        clamped: clamped,
        finalQuantity: newQty,
      );
    } else {
      clamped = clampedQty < qty;
      await db.insert('cart_items', {
        'user_id': userId,
        'product_id': productId,
        'quantity': clampedQty,
        'added_at': now,
      });
      await _refreshCount(userId);
      return AddToCartResult(
        added: true,
        clamped: clamped,
        finalQuantity: clampedQty,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  /// Sets the quantity for a cart line. qty must be 1..stock; qty < 1 is
  /// rejected (use removeItem instead).
  Future<void> updateQuantity({
    required int userId,
    required int productId,
    required int qty,
  }) async {
    if (qty < 1) {
      throw Exception('Use remove to delete an item.');
    }

    final db = await _dbProvider.database;
    final productRows = await db.query(
      'products',
      columns: ['stock'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (productRows.isEmpty) {
      throw Exception('Product not found.');
    }
    final stock = productRows.first['stock'] as int;
    final clampedQty = clampQuantity(qty, stock);

    await db.update(
      'cart_items',
      {'quantity': clampedQty},
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    await _refreshCount(userId);
  }

  // ---------------------------------------------------------------------------
  // Remove / Clear
  // ---------------------------------------------------------------------------

  Future<void> removeItem({required int userId, required int productId}) async {
    final db = await _dbProvider.database;
    await db.delete(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    await _refreshCount(userId);
  }

  Future<void> clear({required int userId}) async {
    final db = await _dbProvider.database;
    await db.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);
    await _refreshCount(userId);
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns cart lines joined with product info and cover image.
  /// Lines for deleted products have `unavailable = true`.
  Future<List<CartLine>> getCartLines({required int userId}) async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery(
      '''SELECT ci.*,
                p.name AS product_name,
                p.price AS product_price,
                p.stock AS product_stock,
                p.seller_id AS seller_id,
                p.weight_kg AS weight_kg,
                (SELECT pi.path FROM product_images pi
                 WHERE pi.product_id = p.id
                 ORDER BY pi.position ASC LIMIT 1) AS cover_path
         FROM cart_items ci
         LEFT JOIN products p ON p.id = ci.product_id
         WHERE ci.user_id = ?
         ORDER BY ci.added_at DESC''',
      [userId],
    );

    return maps.map((m) {
      final item = CartItem.fromMap({
        'id': m['id'],
        'user_id': m['user_id'],
        'product_id': m['product_id'],
        'quantity': m['quantity'],
        'added_at': m['added_at'],
      });

      final productName = m['product_name'] as String?;
      final stock = m['product_stock'] as int?;
      final sellerId = m['seller_id'] as int?;

      final unavailable = productName == null;
      final outOfStock = !unavailable && (stock ?? 0) == 0;
      final quantityExceedsStock =
          !unavailable && !outOfStock && item.quantity > (stock ?? 0);

      return CartLine(
        item: item,
        productName: productName ?? 'Unknown product',
        unitPrice: (m['product_price'] as num?)?.toDouble() ?? 0,
        coverImagePath: m['cover_path'] as String?,
        stock: stock ?? 0,
        sellerId: sellerId ?? 0,
        weightKg: (m['weight_kg'] as num?)?.toDouble() ?? 0,
        unavailable: unavailable,
        outOfStock: outOfStock,
        quantityExceedsStock: quantityExceedsStock,
      );
    }).toList();
  }

  /// Total quantity of items in the cart (sum of quantities).
  Future<int> itemCount({required int userId}) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(quantity), 0) AS total FROM cart_items WHERE user_id = ?',
      [userId],
    );
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Refreshes the [cartCount] notifier from the DB.
  Future<void> refreshCount({required int userId}) async {
    await _refreshCount(userId);
  }

  Future<void> _refreshCount(int userId) async {
    final count = await itemCount(userId: userId);
    cartCount.value = count;
  }

  // ---------------------------------------------------------------------------
  // Pure helpers
  // ---------------------------------------------------------------------------

  /// Clamps a quantity to 1..stock (or 1 if stock is 0).
  static int clampQuantity(int qty, int stock) {
    if (stock <= 0) return 0;
    if (qty < 1) return 1;
    if (qty > stock) return stock;
    return qty;
  }

  /// Subtotal of all lines (sum of unit_price * quantity).
  static double subtotal(List<CartLine> lines) {
    return lines.fold(0.0, (sum, line) => sum + line.lineTotal);
  }

  /// Groups lines by seller for multi-seller checkout.
  static List<SellerGroup> groupBySeller(List<CartLine> lines) {
    final map = <int, List<CartLine>>{};
    for (final line in lines) {
      if (line.unavailable) continue;
      map.putIfAbsent(line.sellerId, () => []).add(line);
    }
    return map.entries
        .map((e) => SellerGroup(sellerId: e.key, lines: e.value))
        .toList();
  }
}
