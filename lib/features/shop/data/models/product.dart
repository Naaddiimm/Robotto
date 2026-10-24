/// Product model for the Shop module.
///
/// Other modules must access products through ShopModule's public API
/// (getProductsByCategory) and must never open robotto_shop.db directly.
class Product {
  final int? id;
  final int sellerId;
  final String name;
  final String description;
  final String category;
  final String? brand;
  final String level;
  final double price;
  final int stock;
  final double weightKg;
  final String? manualPath;
  final String? manualName;
  final String createdAt;
  final String updatedAt;

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// Fixed list of categories shown in the catalog filter chips and product form.
  static const List<String> categories = [
    'Development boards',
    'Sensors',
    'Motors and actuators',
    'Batteries',
    'Tools',
    'Kits',
    'Electronic components',
    'Mechanical parts',
  ];

  /// Skill/expertise level options.
  static const List<String> levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  /// Statuses that indicate an active order is in progress.
  /// A product cannot be deleted while it has an order in any of these statuses.
  static const List<String> activeOrderStatuses = [
    'pending',
    'preparing',
    'shipped',
    'out_for_delivery',
  ];

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  Product({
    this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    required this.level,
    required this.price,
    required this.stock,
    required this.weightKg,
    this.manualPath,
    this.manualName,
    required this.createdAt,
    required this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'level': level,
      'price': price,
      'stock': stock,
      'weight_kg': weightKg,
      'manual_path': manualPath,
      'manual_name': manualName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      sellerId: map['seller_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String?,
      level: map['level'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      weightKg: (map['weight_kg'] as num).toDouble(),
      manualPath: map['manual_path'] as String?,
      manualName: map['manual_name'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  Product copyWith({
    int? id,
    int? sellerId,
    String? name,
    String? description,
    String? category,
    String? brand,
    String? level,
    double? price,
    int? stock,
    double? weightKg,
    String? manualPath,
    String? manualName,
    String? createdAt,
    String? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      level: level ?? this.level,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      weightKg: weightKg ?? this.weightKg,
      manualPath: manualPath ?? this.manualPath,
      manualName: manualName ?? this.manualName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
