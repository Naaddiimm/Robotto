/// Image attached to a product. Position 0 is the cover photo.
/// Max 5 images per product. Files are stored in app storage, not the temp cache.
class ProductImage {
  final int? id;
  final int productId;
  final String path;
  final int position;

  ProductImage({
    this.id,
    required this.productId,
    required this.path,
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'path': path,
      'position': position,
    };
  }

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    return ProductImage(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      path: map['path'] as String,
      position: map['position'] as int,
    );
  }

  ProductImage copyWith({
    int? id,
    int? productId,
    String? path,
    int? position,
  }) {
    return ProductImage(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      path: path ?? this.path,
      position: position ?? this.position,
    );
  }
}
