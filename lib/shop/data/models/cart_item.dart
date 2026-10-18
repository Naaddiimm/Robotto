/// A row in the cart_items table.
class CartItem {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final String addedAt;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'added_at': addedAt,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      addedAt: map['added_at'] as String,
    );
  }

  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    int? quantity,
    String? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

/// A cart line joined with product info for display.
/// Flags indicate issues that should block or warn during checkout.
class CartLine {
  final CartItem item;
  final String productName;
  final double unitPrice;
  final String? coverImagePath;
  final int stock;
  final int sellerId;
  final double weightKg;

  /// Product row is missing (deleted).
  final bool unavailable;

  /// Product exists but stock is 0.
  final bool outOfStock;

  /// Quantity in cart exceeds current stock.
  final bool quantityExceedsStock;

  CartLine({
    required this.item,
    required this.productName,
    required this.unitPrice,
    this.coverImagePath,
    required this.stock,
    required this.sellerId,
    required this.weightKg,
    this.unavailable = false,
    this.outOfStock = false,
    this.quantityExceedsStock = false,
  });

  double get lineTotal => unitPrice * item.quantity;
  bool get hasIssue => unavailable || outOfStock || quantityExceedsStock;
}
