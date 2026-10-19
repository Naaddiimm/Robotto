/// Delivery info for an order. One delivery per order (order_id is UNIQUE).
/// The delivery status mirrors the order status and is updated together with it
/// in a single transaction.
class Delivery {
  final int? id;
  final int orderId;
  final String mode;
  final String recipientName;
  final String phone;
  final String address;
  final String city;
  final String zone;
  final double totalWeightKg;
  final double fee;
  final String status;
  final String statusUpdatedAt;

  // ---------------------------------------------------------------------------
  // Zone constants
  // ---------------------------------------------------------------------------

  static const String zoneGrandTunis = 'grand_tunis';
  static const String zoneNorth = 'north';
  static const String zoneCenter = 'center';
  static const String zoneSouth = 'south';

  static const List<String> zones = [
    zoneGrandTunis,
    zoneNorth,
    zoneCenter,
    zoneSouth,
  ];

  // ---------------------------------------------------------------------------
  // Delivery mode constants
  // ---------------------------------------------------------------------------

  static const String modeHome = 'home';
  static const String modeRelayPoint = 'relay_point';
  static const String modeStorePickup = 'store_pickup';

  static const List<String> modes = [
    modeHome,
    modeRelayPoint,
    modeStorePickup,
  ];

  // ---------------------------------------------------------------------------
  // Status constants (mirrors Order.statuses)
  // ---------------------------------------------------------------------------

  static const List<String> statuses = [
    'pending',
    'preparing',
    'shipped',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  Delivery({
    this.id,
    required this.orderId,
    required this.mode,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.city,
    required this.zone,
    required this.totalWeightKg,
    required this.fee,
    required this.status,
    required this.statusUpdatedAt,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'mode': mode,
      'recipient_name': recipientName,
      'phone': phone,
      'address': address,
      'city': city,
      'zone': zone,
      'total_weight_kg': totalWeightKg,
      'fee': fee,
      'status': status,
      'status_updated_at': statusUpdatedAt,
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      mode: map['mode'] as String,
      recipientName: map['recipient_name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      zone: map['zone'] as String,
      totalWeightKg: (map['total_weight_kg'] as num).toDouble(),
      fee: (map['fee'] as num).toDouble(),
      status: map['status'] as String,
      statusUpdatedAt: map['status_updated_at'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  Delivery copyWith({
    int? id,
    int? orderId,
    String? mode,
    String? recipientName,
    String? phone,
    String? address,
    String? city,
    String? zone,
    double? totalWeightKg,
    double? fee,
    String? status,
    String? statusUpdatedAt,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      mode: mode ?? this.mode,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zone: zone ?? this.zone,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
    );
  }
}
