import 'dart:io';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../core/services/auth_service.dart';
import '../data/repositories/product_repository.dart';
import '../widgets/shop_theme.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

/// The "My Products" view of ShopModule. Lists only the current user's
/// products with edit and delete actions.
class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final _repo = ProductRepository();
  final _authService = AuthService();
  List<ProductWithCover> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }
    final products = await _repo.getBySellerWithCover(userId);
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadProducts();
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  void _confirmDelete(int productId, int sellerId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShopTheme.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ShopTheme.surface, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: ShopTheme.error),
            SizedBox(width: 12),
            Text(
              'Delete Product',
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This cannot be undone.',
          style: const TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: ShopTheme.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ShopTheme.error.withValues(alpha: 0.1),
              foregroundColor: ShopTheme.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(productId, sellerId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int productId, int sellerId) async {
    try {
      await _repo.delete(productId, sellerId);
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: ShopTheme.mint,
        icon: const Icon(Icons.check_circle,
            color: ShopTheme.background, size: 24),
        messageText: const Text(
          'Product deleted successfully',
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: ShopTheme.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 2),
      ).show(context);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: ShopTheme.error,
        icon: const Icon(Icons.error_outline,
            color: ShopTheme.background, size: 24),
        messageText: Text(
          e.toString().replaceAll('Exception: ', ''),
          style: const TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: ShopTheme.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Success Flushbar (for add/edit from ProductFormScreen)
  // ---------------------------------------------------------------------------

  void _showSuccessFlushbar(String message) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: ShopTheme.mint,
      icon: const Icon(Icons.check_circle,
          color: ShopTheme.background, size: 24),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: ShopTheme.fontFamily,
          color: ShopTheme.background,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopTheme.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductFormScreen(),
              ),
            );
            if (!mounted) return;
            if (result == true) {
              _showSuccessFlushbar('Product created successfully');
            }
            _refresh();
          },
          backgroundColor: ShopTheme.mint,
          child: const Icon(Icons.add, color: ShopTheme.background),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ShopTheme.mint))
          : _products.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    ShopTheme.screenPadding,
                    8,
                    ShopTheme.screenPadding,
                    ShopTheme.bottomNavPadding,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return _buildProductItem(_products[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sell_outlined,
            size: 56,
            color: ShopTheme.secondaryText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No products yet',
            style: ShopTheme.headingStyle.copyWith(
              color: ShopTheme.secondaryText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first product.',
            style: ShopTheme.bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductWithCover item) {
    final product = item.product;
    final hasCover =
        item.coverPath != null && File(item.coverPath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(productId: product.id!),
            ),
          );
          if (!mounted) return;
          _refresh();
        },
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 80,
              height: 80,
              child: hasCover
                  ? Image.file(
                      File(item.coverPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => Container(
                        color: ShopTheme.surfaceHigh,
                        child: Icon(Icons.image_outlined,
                            color:
                                ShopTheme.secondaryText.withValues(alpha: 0.4)),
                      ),
                      cacheWidth: 160,
                    )
                  : Container(
                      color: ShopTheme.surfaceHigh,
                      child: Icon(Icons.image_outlined,
                          color: ShopTheme.secondaryText
                              .withValues(alpha: 0.4)),
                    ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ShopTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)} TND',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ShopTheme.mint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.stock > 0
                          ? '${product.stock} in stock'
                          : 'Out of stock',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 12,
                        color: product.stock > 0
                            ? ShopTheme.secondaryText
                            : ShopTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: ShopTheme.violet, size: 22),
              onPressed: () async {
                final images = await _repo.getImages(product.id!);
                if (!mounted) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      product: product,
                      images: images,
                    ),
                  ),
                );
                if (!mounted) return;
                if (result == true) {
                  _showSuccessFlushbar('Product updated successfully');
                }
                _refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: ShopTheme.error, size: 22),
              onPressed: () =>
                  _confirmDelete(product.id!, product.sellerId, product.name),
            ),
          ],
        ),
      ),
    );
  }
}
