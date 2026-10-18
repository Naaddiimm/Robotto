/// A line item in an order. The product name and unit price are **snapshotted**
/// at order time so history stays correct even if the product is later changed
/// or deleted. `product_id` has no foreign key for the same reason.
class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final int sellerId;
  final String productName;
  final double unitPrice;
  final int quantity;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'seller_id': sellerId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      productId: map['product_id'] as int,
      sellerId: map['seller_id'] as int,
      productName: map['product_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? sellerId,
    String? productName,
    double? unitPrice,
    int? quantity,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
