import '../shop_database.dart';
import '../file_storage_service.dart';
import '../models/product.dart';
import '../models/product_image.dart';

/// Wrapper for a product loaded with all its images.
class ProductWithImages {
  final Product product;
  final List<ProductImage> images;
  ProductWithImages({required this.product, required this.images});
}

/// Wrapper for a product with just its cover image path (for catalog cards).
class ProductWithCover {
  final Product product;
  final String? coverPath;
  ProductWithCover({required this.product, this.coverPath});
}

/// CRUD repository for products and their images.
///
/// All writes use transactions. Update and delete include `AND seller_id = ?`
/// to enforce ownership at the database level, not only in the UI.
class ProductRepository {
  final ShopDatabase _dbProvider = ShopDatabase.instance;
  final FileStorageService _fileStorage = FileStorageService();

  // ---------------------------------------------------------------------------
  // Insert
  // ---------------------------------------------------------------------------

  /// Inserts a product and its images in one transaction.
  /// Returns the new product id.
  Future<int> insert(Product product, List<ProductImage> images) async {
    final db = await _dbProvider.database;
    return await db.transaction((txn) async {
      final productId = await txn.insert('products', product.toMap());
      for (final image in images) {
        await txn.insert(
          'product_images',
          image.copyWith(productId: productId).toMap(),
        );
      }
      return productId;
    });
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  /// Updates a product and replaces all its images in one transaction.
  /// Includes `AND seller_id = ?` to enforce ownership.
  Future<void> update(Product product, List<ProductImage> images) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.update(
        'products',
        product.toMap(),
        where: 'id = ? AND seller_id = ?',
        whereArgs: [product.id, product.sellerId],
      );
      // Replace all images
      await txn.delete(
        'product_images',
        where: 'product_id = ?',
        whereArgs: [product.id],
      );
      for (final image in images) {
        await txn.insert(
          'product_images',
          image.copyWith(productId: product.id!).toMap(),
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Deletes a product if it has no active orders. Also deletes physical
  /// photo files and the manual PDF. Throws if an active order exists.
  Future<void> delete(int productId, int sellerId) async {
    // Gather file paths before the transaction (cascade removes image rows).
    final existing = await getById(productId);
    final images = existing?.images ?? [];
    final manualPath = existing?.product.manualPath;

    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      // Check for active orders.
      final rows = await txn.rawQuery(
        '''SELECT COUNT(*) AS cnt FROM order_items oi
           JOIN orders o ON oi.order_id = o.id
           WHERE oi.product_id = ?
             AND o.status IN (?, ?, ?, ?)''',
        [productId, 'pending', 'preparing', 'shipped', 'out_for_delivery'],
      );
      final count = (rows.first['cnt'] as num?)?.toInt() ?? 0;
      if (count > 0) {
        throw Exception(
          'This product has an active order and cannot be deleted.',
        );
      }

      // Delete the product (cascade removes product_images).
      await txn.delete(
        'products',
        where: 'id = ? AND seller_id = ?',
        whereArgs: [productId, sellerId],
      );
    });

    // Delete physical files after the DB write succeeds.
    for (final image in images) {
      await _fileStorage.deleteFile(image.path);
    }
    await _fileStorage.deleteFile(manualPath);
  }

  // ---------------------------------------------------------------------------
  // Read — single product
  // ---------------------------------------------------------------------------

  /// Returns a product with all its images, or null if not found.
  Future<ProductWithImages?> getById(int id) async {
    final db = await _dbProvider.database;
    final productMaps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (productMaps.isEmpty) return null;

    final product = Product.fromMap(productMaps.first);
    final imageMaps = await db.query(
      'product_images',
      where: 'product_id = ?',
      whereArgs: [id],
      orderBy: 'position ASC',
    );
    final images = imageMaps.map(ProductImage.fromMap).toList();

    return ProductWithImages(product: product, images: images);
  }

  /// Returns all images for a product (ordered by position).
  Future<List<ProductImage>> getImages(int productId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'product_images',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'position ASC',
    );
    return maps.map(ProductImage.fromMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Read — lists
  // ---------------------------------------------------------------------------

  /// Returns all products (without images) with optional filtering and sorting.
  Future<List<Product>> getAll({
    String? search,
    String? category,
    bool? inStockOnly,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? level,
    String? sort,
  }) async {
    final db = await _dbProvider.database;
    final whereParts = <String>[];
    final whereArgs = <dynamic>[];

    if (search != null && search.trim().isNotEmpty) {
      whereParts.add('(name LIKE ? OR brand LIKE ? OR description LIKE ?)');
      whereArgs.addAll(['%$search%', '%$search%', '%$search%']);
    }
    if (category != null && category.isNotEmpty) {
      whereParts.add('category = ?');
      whereArgs.add(category);
    }
    if (inStockOnly == true) {
      whereParts.add('stock > 0');
    }
    if (minPrice != null) {
      whereParts.add('price >= ?');
      whereArgs.add(minPrice);
    }
    if (maxPrice != null) {
      whereParts.add('price <= ?');
      whereArgs.add(maxPrice);
    }
    if (brand != null && brand.trim().isNotEmpty) {
      whereParts.add('brand LIKE ?');
      whereArgs.add('%$brand%');
    }
    if (level != null && level.isNotEmpty) {
      whereParts.add('level = ?');
      whereArgs.add(level);
    }

    final whereClause = whereParts.isEmpty ? null : whereParts.join(' AND ');
    final orderBy = _sortToOrderBy(sort);

    final maps = await db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
    );
    return maps.map(Product.fromMap).toList();
  }

  /// Returns all products with their cover image path, with filters and sort.
  Future<List<ProductWithCover>> getAllWithCover({
    String? search,
    String? category,
    bool? inStockOnly,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? level,
    String? sort,
  }) async {
    final db = await _dbProvider.database;
    final whereParts = <String>[];
    final whereArgs = <dynamic>[];

    if (search != null && search.trim().isNotEmpty) {
      whereParts.add(
        '(p.name LIKE ? OR p.brand LIKE ? OR p.description LIKE ?)',
      );
      whereArgs.addAll(['%$search%', '%$search%', '%$search%']);
    }
    if (category != null && category.isNotEmpty) {
      whereParts.add('p.category = ?');
      whereArgs.add(category);
    }
    if (inStockOnly == true) {
      whereParts.add('p.stock > 0');
    }
    if (minPrice != null) {
      whereParts.add('p.price >= ?');
      whereArgs.add(minPrice);
    }
    if (maxPrice != null) {
      whereParts.add('p.price <= ?');
      whereArgs.add(maxPrice);
    }
    if (brand != null && brand.trim().isNotEmpty) {
      whereParts.add('p.brand LIKE ?');
      whereArgs.add('%$brand%');
    }
    if (level != null && level.isNotEmpty) {
      whereParts.add('p.level = ?');
      whereArgs.add(level);
    }

    final whereClause = whereParts.isEmpty
        ? ''
        : 'WHERE ${whereParts.join(' AND ')}';
    final orderBy = _sortToOrderBy(sort)
        .replaceAll('created_at', 'p.created_at')
        .replaceAll('price', 'p.price')
        .replaceAll('name', 'p.name');

    final maps = await db.rawQuery('''
      SELECT p.*,
             (SELECT pi.path FROM product_images pi
              WHERE pi.product_id = p.id
              ORDER BY pi.position ASC LIMIT 1) AS cover_path
      FROM products p
      $whereClause
      ORDER BY $orderBy
    ''', whereArgs);

    return maps.map((m) {
      return ProductWithCover(
        product: Product.fromMap(m),
        coverPath: m['cover_path'] as String?,
      );
    }).toList();
  }

  /// Returns products by seller with their cover image path.
  Future<List<ProductWithCover>> getBySellerWithCover(int sellerId) async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery(
      '''
      SELECT p.*,
             (SELECT pi.path FROM product_images pi
              WHERE pi.product_id = p.id
              ORDER BY pi.position ASC LIMIT 1) AS cover_path
      FROM products p
      WHERE p.seller_id = ?
      ORDER BY p.created_at DESC
    ''',
      [sellerId],
    );

    return maps.map((m) {
      return ProductWithCover(
        product: Product.fromMap(m),
        coverPath: m['cover_path'] as String?,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Checks if a product has any active order.
  Future<bool> hasActiveOrder(int productId) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''SELECT COUNT(*) AS cnt FROM order_items oi
         JOIN orders o ON oi.order_id = o.id
         WHERE oi.product_id = ?
           AND o.status IN (?, ?, ?, ?)''',
      [productId, 'pending', 'preparing', 'shipped', 'out_for_delivery'],
    );
    return ((rows.first['cnt'] as num?)?.toInt() ?? 0) > 0;
  }

  String _sortToOrderBy(String? sort) {
    switch (sort) {
      case 'price_low_high':
        return 'price ASC';
      case 'price_high_low':
        return 'price DESC';
      case 'name_az':
        return 'name ASC';
      default: // newest
        return 'created_at DESC';
    }
  }
}
