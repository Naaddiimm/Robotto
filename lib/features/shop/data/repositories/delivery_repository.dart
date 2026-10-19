import '../shop_database.dart';
import '../models/delivery.dart';

/// Read-only repository for delivery queries.
class DeliveryRepository {
  final ShopDatabase _dbProvider = ShopDatabase.instance;

  /// Returns the delivery info for a given order, or null if not found.
  Future<Delivery?> getDeliveryByOrderId(int orderId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'deliveries',
      where: 'order_id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Delivery.fromMap(maps.first);
  }
}
