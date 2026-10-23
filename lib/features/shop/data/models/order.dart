/// Order (commande) placed by a buyer. One order can contain multiple
/// order_items (structured for a future cart), though the current flow
/// creates single-product orders.
class Order {
  final int? id;
  final int buyerId;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String createdAt;
  final String updatedAt;

  // ---------------------------------------------------------------------------
  // Status constants
  // ---------------------------------------------------------------------------

  static const String statusPending = 'pending';
  static const String statusPreparing = 'preparing';
  static const String statusShipped = 'shipped';
  static const String statusOutForDelivery = 'out_for_delivery';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  /// All valid statuses in the order they appear in the fulfillment flow.
  /// `cancelled` is a terminal state reachable only from `pending` or `preparing`.
  static const List<String> statuses = [
    statusPending,
    statusPreparing,
    statusShipped,
    statusOutForDelivery,
    statusDelivered,
    statusCancelled,
  ];

  /// Ordered statuses that a seller advances through one step at a time.
  static const List<String> flowStatuses = [
    statusPending,
    statusPreparing,
    statusShipped,
    statusOutForDelivery,
    statusDelivered,
  ];

  // ---------------------------------------------------------------------------
  // Payment method constants
  // ---------------------------------------------------------------------------

  static const String cashOnDelivery = 'cash_on_delivery';
  static const String card = 'card';
  static const String mobileWallet = 'mobile_wallet';

  static const List<String> paymentMethods = [
    cashOnDelivery,
    card,
    mobileWallet,
  ];

  /// Payment methods currently accepted. Card and wallet are reserved for later.
  static const List<String> acceptedPaymentMethods = [cashOnDelivery];

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  Order({
    this.id,
    required this.buyerId,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'status': status,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      buyerId: map['buyer_id'] as int,
      status: map['status'] as String,
      paymentMethod: map['payment_method'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      deliveryFee: (map['delivery_fee'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  Order copyWith({
    int? id,
    int? buyerId,
    String? status,
    String? paymentMethod,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? createdAt,
    String? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
