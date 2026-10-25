import '../shop_database.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/delivery.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../repositories/cart_repository.dart';
import '../delivery_fee_calculator.dart';
import '../../validators/order_validators.dart';

/// Result of a cart checkout attempt.
class CartCheckoutResult {
  final bool success;
  final List<int> orderIds;
  final List<String> failedProducts;
  const CartCheckoutResult({
    required this.success,
    this.orderIds = const [],
    this.failedProducts = const [],
  });
}

/// Wrapper for an order loaded with its items and delivery info.
class OrderDetail {
  final Order order;
  final List<OrderItem> items;
  final Delivery? delivery;
  OrderDetail({required this.order, required this.items, this.delivery});
}

/// CRUD repository for orders, order_items, and deliveries.
///
/// All writes use transactions. Ownership and status-transition rules are
/// enforced here, not only in the UI.
class OrderRepository {
  final ShopDatabase _dbProvider = ShopDatabase.instance;

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  /// Creates an order in one transaction: re-checks stock, inserts orders +
  /// order_items (name and price snapshot) + deliveries (status pending),
  /// and decreases product stock.
  ///
  /// Throws if the buyer is the seller or stock is insufficient.
  Future<int> createOrder({
    required int buyerId,
    required Product product,
    required int quantity,
    required String recipientName,
    required String phone,
    required String address,
    required String city,
    required String zone,
    required String deliveryMode,
    required String paymentMethod,
  }) async {
    if (buyerId == product.sellerId) {
      throw Exception('You cannot order your own product.');
    }

    final subtotal = product.price * quantity;
    final totalWeightKg = product.weightKg * quantity;
    final fee = DeliveryFeeCalculator.calculate(
      zone,
      totalWeightKg,
      deliveryMode,
    );
    final total = subtotal + fee;
    final now = DateTime.now().toIso8601String();

    final db = await _dbProvider.database;
    return await db.transaction((txn) async {
      // Re-check stock inside the transaction
      final productRows = await txn.rawQuery(
        'SELECT stock FROM products WHERE id = ?',
        [product.id],
      );
      if (productRows.isEmpty) {
        throw Exception('Product not found.');
      }
      final currentStock = productRows.first['stock'] as int;
      if (currentStock < quantity) {
        throw Exception('Insufficient stock. Only $currentStock available.');
      }

      // Insert order
      final orderId = await txn.insert('orders', {
        'buyer_id': buyerId,
        'status': Order.statusPending,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'delivery_fee': fee,
        'total': total,
        'created_at': now,
        'updated_at': now,
      });

      // Insert order_item (snapshot name and price)
      await txn.insert('order_items', {
        'order_id': orderId,
        'product_id': product.id!,
        'seller_id': product.sellerId,
        'product_name': product.name,
        'unit_price': product.price,
        'quantity': quantity,
      });

      // Insert delivery (status pending)
      await txn.insert('deliveries', {
        'order_id': orderId,
        'mode': deliveryMode,
        'recipient_name': recipientName,
        'phone': phone,
        'address': deliveryMode == Delivery.modeStorePickup ? '' : address,
        'city': city,
        'zone': zone,
        'total_weight_kg': totalWeightKg,
        'fee': fee,
        'status': Order.statusPending,
        'status_updated_at': now,
      });

      // Decrease stock
      await txn.rawUpdate(
        'UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?',
        [quantity, product.id, quantity],
      );

      return orderId;
    });
  }

  // ---------------------------------------------------------------------------
  // Update — buyer edits (only while pending)
  // ---------------------------------------------------------------------------

  /// Buyer can edit delivery details and quantity while the order is pending.
  /// Stock is adjusted, fee and total recalculated in the same transaction.
  Future<void> updateOrderDetails({
    required int orderId,
    required int buyerId,
    String? recipientName,
    String? phone,
    String? address,
    String? city,
    String? deliveryMode,
    String? zone,
    int? quantity,
  }) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      // Check ownership and status
      final orderRows = await txn.query(
        'orders',
        where: 'id = ? AND buyer_id = ?',
        whereArgs: [orderId, buyerId],
        limit: 1,
      );
      if (orderRows.isEmpty) {
        throw Exception('Order not found.');
      }
      final order = Order.fromMap(orderRows.first);
      if (order.status != Order.statusPending) {
        throw Exception('You can only edit a pending order.');
      }

      // Get current order_item
      final itemRows = await txn.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      if (itemRows.isEmpty) {
        throw Exception('Order items not found.');
      }
      final item = OrderItem.fromMap(itemRows.first);
      final productId = item.productId;
      final oldQuantity = item.quantity;

      // Handle quantity change — adjust stock
      int newQuantity = oldQuantity;
      if (quantity != null && quantity != oldQuantity) {
        newQuantity = quantity;
        final diff = quantity - oldQuantity;
        if (diff > 0) {
          // Increasing — check and decrease stock
          final productRows = await txn.rawQuery(
            'SELECT stock, price, weight_kg FROM products WHERE id = ?',
            [productId],
          );
          if (productRows.isEmpty) {
            throw Exception('Product not found.');
          }
          final stock = productRows.first['stock'] as int;
          if (stock < diff) {
            throw Exception('Insufficient stock for the new quantity.');
          }
          await txn.rawUpdate(
            'UPDATE products SET stock = stock - ? WHERE id = ?',
            [diff, productId],
          );
        } else if (diff < 0) {
          // Decreasing — restore stock
          await txn.rawUpdate(
            'UPDATE products SET stock = stock + ? WHERE id = ?',
            [-diff, productId],
          );
        }
        // Update order_item quantity
        await txn.update(
          'order_items',
          {'quantity': newQuantity},
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }

      // Determine delivery info for fee recalculation
      final deliveryRows = await txn.query(
        'deliveries',
        where: 'order_id = ?',
        whereArgs: [orderId],
        limit: 1,
      );
      final currentDelivery = deliveryRows.isNotEmpty
          ? Delivery.fromMap(deliveryRows.first)
          : null;

      final effectiveMode =
          deliveryMode ?? currentDelivery?.mode ?? Delivery.modeHome;
      final effectiveZone =
          zone ?? currentDelivery?.zone ?? Delivery.zoneGrandTunis;

      // Get product weight for fee
      final productRows = await txn.rawQuery(
        'SELECT price, weight_kg FROM products WHERE id = ?',
        [productId],
      );
      double unitPrice = item.unitPrice;
      double weightKg = 0.01;
      if (productRows.isNotEmpty) {
        unitPrice = (productRows.first['price'] as num).toDouble();
        weightKg = (productRows.first['weight_kg'] as num).toDouble();
      }

      final subtotal = unitPrice * newQuantity;
      final totalWeightKg = weightKg * newQuantity;
      final fee = DeliveryFeeCalculator.calculate(
        effectiveZone,
        totalWeightKg,
        effectiveMode,
      );
      final total = subtotal + fee;
      final now = DateTime.now().toIso8601String();

      // Update order
      await txn.update(
        'orders',
        {
          'subtotal': subtotal,
          'delivery_fee': fee,
          'total': total,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      // Update delivery
      final deliveryUpdate = <String, dynamic>{'status_updated_at': now};
      if (recipientName != null)
        deliveryUpdate['recipient_name'] = recipientName;
      if (phone != null) deliveryUpdate['phone'] = phone;
      if (city != null) deliveryUpdate['city'] = city;
      if (deliveryMode != null) {
        deliveryUpdate['mode'] = deliveryMode;
        if (deliveryMode == Delivery.modeStorePickup) {
          deliveryUpdate['address'] = '';
        } else if (address != null) {
          deliveryUpdate['address'] = address;
        }
      } else if (address != null) {
        deliveryUpdate['address'] = address;
      }
      if (zone != null) deliveryUpdate['zone'] = zone;
      deliveryUpdate['total_weight_kg'] = totalWeightKg;
      deliveryUpdate['fee'] = fee;

      await txn.update(
        'deliveries',
        deliveryUpdate,
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Update — seller advances status (one step forward only)
  // ---------------------------------------------------------------------------

  /// Seller of the items advances the status one step forward.
  /// Updates orders.status, deliveries.status, and status_updated_at together.
  Future<void> advanceStatus({
    required int orderId,
    required int sellerId,
  }) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      // Check seller owns items in this order
      final sellerCheck = await txn.rawQuery(
        'SELECT COUNT(*) AS cnt FROM order_items WHERE order_id = ? AND seller_id = ?',
        [orderId, sellerId],
      );
      if ((sellerCheck.first['cnt'] as int) == 0) {
        throw Exception('You can only advance orders for your products.');
      }

      // Get current status
      final orderRows = await txn.query(
        'orders',
        where: 'id = ?',
        whereArgs: [orderId],
        limit: 1,
      );
      if (orderRows.isEmpty) {
        throw Exception('Order not found.');
      }
      final currentStatus = orderRows.first['status'] as String;

      // Check valid transition
      final next = OrderValidators.nextStatus(currentStatus);
      if (next == null) {
        throw Exception('This order cannot be advanced further.');
      }

      final now = DateTime.now().toIso8601String();

      await txn.update(
        'orders',
        {'status': next, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      await txn.update(
        'deliveries',
        {'status': next, 'status_updated_at': now},
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Cancel (buyer, only from pending or preparing)
  // ---------------------------------------------------------------------------

  /// Buyer cancels the order. Stock is restored in the same transaction.
  /// Only allowed from pending or preparing status.
  Future<void> cancelOrder({required int orderId, required int buyerId}) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      final orderRows = await txn.query(
        'orders',
        where: 'id = ? AND buyer_id = ?',
        whereArgs: [orderId, buyerId],
        limit: 1,
      );
      if (orderRows.isEmpty) {
        throw Exception('Order not found.');
      }
      final status = orderRows.first['status'] as String;
      if (!OrderValidators.canCancel(status)) {
        throw Exception(
          'This order can only be cancelled while pending or preparing.',
        );
      }

      // Restore stock
      final items = await txn.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      for (final itemMap in items) {
        final item = OrderItem.fromMap(itemMap);
        await txn.rawUpdate(
          'UPDATE products SET stock = stock + ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }

      final now = DateTime.now().toIso8601String();
      await txn.update(
        'orders',
        {'status': Order.statusCancelled, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      await txn.update(
        'deliveries',
        {'status': Order.statusCancelled, 'status_updated_at': now},
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Delete (buyer, only if cancelled or delivered)
  // ---------------------------------------------------------------------------

  /// Buyer deletes an order from history. Hard delete (cascade removes
  /// items and delivery). Only allowed for cancelled or delivered orders.
  Future<void> deleteOrder({required int orderId, required int buyerId}) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      final orderRows = await txn.query(
        'orders',
        where: 'id = ? AND buyer_id = ?',
        whereArgs: [orderId, buyerId],
        limit: 1,
      );
      if (orderRows.isEmpty) {
        throw Exception('Order not found.');
      }
      final status = orderRows.first['status'] as String;
      if (!OrderValidators.canDelete(status)) {
        throw Exception('Only cancelled or delivered orders can be deleted.');
      }

      await txn.delete('orders', where: 'id = ?', whereArgs: [orderId]);
    });
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns orders placed by a buyer, newest first.
  Future<List<Order>> getMyOrders(int buyerId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'orders',
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'created_at DESC',
    );
    return maps.map(Order.fromMap).toList();
  }

  /// Returns orders containing items sold by a seller, newest first.
  Future<List<Order>> getReceivedOrders(int sellerId) async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery(
      '''SELECT DISTINCT o.* FROM orders o
         INNER JOIN order_items oi ON oi.order_id = o.id
         WHERE oi.seller_id = ?
         ORDER BY o.created_at DESC''',
      [sellerId],
    );
    return maps.map(Order.fromMap).toList();
  }

  /// Returns an order with its items and delivery, or null if not found.
  Future<OrderDetail?> getOrderById(int orderId) async {
    final db = await _dbProvider.database;

    final orderRows = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    if (orderRows.isEmpty) return null;

    final order = Order.fromMap(orderRows.first);

    final itemRows = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    final items = itemRows.map(OrderItem.fromMap).toList();

    final deliveryRows = await db.query(
      'deliveries',
      where: 'order_id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    final delivery = deliveryRows.isNotEmpty
        ? Delivery.fromMap(deliveryRows.first)
        : null;

    return OrderDetail(order: order, items: items, delivery: delivery);
  }

  /// Returns deliveries for a buyer's orders, newest status update first.
  Future<List<Delivery>> getDeliveriesForBuyer(int buyerId) async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery(
      '''SELECT d.* FROM deliveries d
         INNER JOIN orders o ON d.order_id = o.id
         WHERE o.buyer_id = ?
         ORDER BY d.status_updated_at DESC''',
      [buyerId],
    );
    return maps.map(Delivery.fromMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Cart checkout — create one order per seller in one transaction
  // ---------------------------------------------------------------------------

  /// Creates one order per seller from cart [lines] in a single transaction.
  /// Re-checks every line against current stock and ownership; if any line
  /// fails, rolls back everything and returns which products failed.
  /// Decreases stock and deletes purchased cart rows on success.
  Future<CartCheckoutResult> createOrdersFromCart({
    required int buyerId,
    required List<CartLine> lines,
    required String recipientName,
    required String phone,
    required String address,
    required String city,
    required String zone,
    required String deliveryMode,
    required String paymentMethod,
  }) async {
    if (paymentMethod != Order.cashOnDelivery) {
      return const CartCheckoutResult(
        success: false,
        failedProducts: ['Only cash on delivery is accepted.'],
      );
    }

    final groups = CartRepository.groupBySeller(lines);
    if (groups.isEmpty) {
      return const CartCheckoutResult(
        success: false,
        failedProducts: ['No valid items to checkout.'],
      );
    }

    final db = await _dbProvider.database;
    final failedProducts = <String>[];

    try {
      final orderIds = await db.transaction((txn) async {
        final createdOrderIds = <int>[];
        final now = DateTime.now().toIso8601String();

        for (final group in groups) {
          // Re-check every line in this group
          double groupSubtotal = 0;
          double groupWeight = 0;
          final snapshotItems = <Map<String, dynamic>>[];

          for (final line in group.lines) {
            final productRows = await txn.query(
              'products',
              where: 'id = ?',
              whereArgs: [line.item.productId],
              limit: 1,
            );
            if (productRows.isEmpty) {
              failedProducts.add(line.productName);
              throw Exception(
                'Product "${line.productName}" is no longer available.',
              );
            }
            final stock = productRows.first['stock'] as int;
            final sellerId = productRows.first['seller_id'] as int;
            if (sellerId == buyerId) {
              failedProducts.add(line.productName);
              throw Exception(
                'You cannot order your own product "${line.productName}".',
              );
            }
            if (stock < line.item.quantity) {
              failedProducts.add(line.productName);
              throw Exception(
                'Insufficient stock for "${line.productName}" '
                '(only $stock left).',
              );
            }

            final unitPrice = (productRows.first['price'] as num).toDouble();
            final weightKg = (productRows.first['weight_kg'] as num).toDouble();
            final qty = line.item.quantity;

            groupSubtotal += unitPrice * qty;
            groupWeight += weightKg * qty;

            snapshotItems.add({
              'product_id': line.item.productId,
              'seller_id': sellerId,
              'product_name': productRows.first['name'] as String,
              'unit_price': unitPrice,
              'quantity': qty,
            });
          }

          final fee = DeliveryFeeCalculator.calculate(
            zone,
            groupWeight,
            deliveryMode,
          );
          final total = groupSubtotal + fee;

          // Insert order
          final orderId = await txn.insert('orders', {
            'buyer_id': buyerId,
            'status': Order.statusPending,
            'payment_method': paymentMethod,
            'subtotal': groupSubtotal,
            'delivery_fee': fee,
            'total': total,
            'created_at': now,
            'updated_at': now,
          });
          createdOrderIds.add(orderId);

          // Insert order_items (snapshot)
          for (final item in snapshotItems) {
            await txn.insert('order_items', {'order_id': orderId, ...item});
          }

          // Insert delivery (status pending)
          await txn.insert('deliveries', {
            'order_id': orderId,
            'mode': deliveryMode,
            'recipient_name': recipientName,
            'phone': phone,
            'address': deliveryMode == Delivery.modeStorePickup ? '' : address,
            'city': city,
            'zone': zone,
            'total_weight_kg': groupWeight,
            'fee': fee,
            'status': Order.statusPending,
            'status_updated_at': now,
          });

          // Decrease stock for each product
          for (final item in snapshotItems) {
            await txn.rawUpdate(
              'UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?',
              [
                item['quantity'] as int,
                item['product_id'] as int,
                item['quantity'] as int,
              ],
            );
          }
        }

        // Delete purchased cart rows
        for (final line in lines) {
          if (!line.unavailable) {
            await txn.delete(
              'cart_items',
              where: 'user_id = ? AND product_id = ?',
              whereArgs: [buyerId, line.item.productId],
            );
          }
        }

        return createdOrderIds;
      });

      return CartCheckoutResult(success: true, orderIds: orderIds);
    } catch (e) {
      return CartCheckoutResult(
        success: false,
        failedProducts: failedProducts.isNotEmpty
            ? failedProducts
            : [e.toString()],
      );
    }
  }
}
