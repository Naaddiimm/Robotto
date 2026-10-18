import 'dart:io';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/auth_service.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/models/product.dart';
import '../data/models/product_image.dart';
import '../widgets/shop_theme.dart';
import 'image_viewer_screen.dart';
import 'product_form_screen.dart';
import 'checkout_screen.dart';

/// Full product detail page with gallery, info, and action buttons.
/// Pushed via Navigator.push (covers the nav bar).
class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _repo = ProductRepository();
  final CartRepository _cartRepo = CartRepository();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Product? _product;
  List<ProductImage> _images = [];
  int _currentImageIndex = 0;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await _authService.getCurrentUserId();
    final data = await _repo.getById(widget.productId);
    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
      _product = data?.product;
      _images = data?.images ?? [];
      _isLoading = false;
    });
  }

  bool get _isOwner => _currentUserId == _product?.sellerId;

  // ---------------------------------------------------------------------------
  // Gallery
  // ---------------------------------------------------------------------------

  Widget _buildGallery() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cacheWidth = screenWidth.round();

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: _images.isEmpty
                  ? Container(
                      color: ShopTheme.surfaceHigh,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: ShopTheme.secondaryText.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : PageView.builder(
                      itemCount: _images.length,
                      onPageChanged: (i) =>
                          setState(() => _currentImageIndex = i),
                      itemBuilder: (context, index) {
                        final img = _images[index];
                        final file = File(img.path);
                        final exists = file.existsSync();
                        final imageWidget = exists
                            ? Image.file(
                                file,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, _) => Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: ShopTheme.secondaryText
                                        .withValues(alpha: 0.5),
                                    size: 48,
                                  ),
                                ),
                                cacheWidth: cacheWidth,
                              )
                            : Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: ShopTheme.secondaryText
                                      .withValues(alpha: 0.5),
                                  size: 48,
                                ),
                              );

                        // Hero only on cover (index 0)
                        if (index == 0) {
                          return Hero(
                            tag: 'product_${_product!.id}',
                            child: Container(
                              color: ShopTheme.surfaceHigh,
                              child: GestureDetector(
                                onTap: () => _openImageViewer(index),
                                child: imageWidget,
                              ),
                            ),
                          );
                        }
                        return Container(
                          color: ShopTheme.surfaceHigh,
                          child: GestureDetector(
                            onTap: () => _openImageViewer(index),
                            child: imageWidget,
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Back button
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Counter + dots
          if (_images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (i) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentImageIndex
                              ? ShopTheme.mint
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${_images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: ShopTheme.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openImageViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imagePaths: _images.map((e) => e.path).toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------

  Widget _buildContent() {
    final p = _product!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShopTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + price
          Text(
            p.name,
            style: ShopTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${p.price.toStringAsFixed(2)} TND',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ShopTheme.mint,
                ),
              ),
              const SizedBox(width: 16),
              _stockBadge(p.stock),
            ],
          ),
          const SizedBox(height: ShopTheme.itemSpacing),

          // Category + Level
          _infoRow('Category', p.category),
          if (p.brand != null && p.brand!.isNotEmpty)
            _infoRow('Brand', p.brand!),
          _infoRow('Level', p.level),
          _infoRow('Weight', '${p.weightKg.toStringAsFixed(2)} kg'),

          const SizedBox(height: ShopTheme.itemSpacing),
          const Divider(color: ShopTheme.surfaceHigh, height: 1),

          // Description
          const SizedBox(height: ShopTheme.itemSpacing),
          Text('Description', style: ShopTheme.labelStyle),
          const SizedBox(height: 8),
          Text(
            p.description,
            style: ShopTheme.bodyStyle,
          ),

          // Manual tile
          if (p.manualPath != null && p.manualName != null) ...[
            const SizedBox(height: ShopTheme.itemSpacing),
            const Divider(color: ShopTheme.surfaceHigh, height: 1),
            const SizedBox(height: ShopTheme.itemSpacing),
            _manualTile(p.manualPath!, p.manualName!),
          ],

          // Actions
          const SizedBox(height: 32),
          _buildActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: ShopTheme.captionStyle,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ShopTheme.bodyMainStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockBadge(int stock) {
    final inStock = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: inStock
            ? ShopTheme.mint.withValues(alpha: 0.15)
            : ShopTheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        inStock ? '$stock in stock' : 'Out of stock',
        style: TextStyle(
          fontFamily: ShopTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: inStock ? ShopTheme.mint : ShopTheme.error,
        ),
      ),
    );
  }

  Widget _manualTile(String path, String name) {
    return GestureDetector(
      onTap: () => _openManual(path),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ShopTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ShopTheme.violet.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              color: ShopTheme.violet,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Manual (PDF)',
                    style: ShopTheme.labelStyle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ShopTheme.captionStyle,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new,
              size: 18,
              color: ShopTheme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openManual(String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (!mounted) return;
      if (result.type != ResultType.done) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: ShopTheme.error,
          icon: const Icon(Icons.error_outline, color: ShopTheme.background, size: 24),
          messageText: Text(
            'Cannot open PDF: ${result.message}',
            style: const TextStyle(
              fontFamily: ShopTheme.fontFamily,
              color: ShopTheme.background,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: const Duration(seconds: 3),
        ).show(context);
      }
    } catch (e) {
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: ShopTheme.error,
        icon: const Icon(Icons.error_outline, color: ShopTheme.background, size: 24),
        messageText: Text(
          'No PDF viewer installed: $e',
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
  // Actions
  // ---------------------------------------------------------------------------

  Widget _buildActions() {
    return Column(
      children: [
        // Order now + Add to cart — hidden for owner or out of stock
        if (!_isOwner && _product!.stock > 0) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ShopTheme.mint,
                foregroundColor: ShopTheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _openCheckout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Order now',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.shopping_bag_outlined, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: ShopTheme.violet,
                side: BorderSide(
                    color: ShopTheme.violet.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _addToCart,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_shopping_cart_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_isOwner) ...[
          // Edit
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ShopTheme.violet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      product: _product,
                      images: _images,
                    ),
                  ),
                );
                if (!mounted) return;
                if (result == true) {
                  _showFlushbar('Product updated successfully', isError: false);
                }
                _loadData(); // refresh
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Edit Product',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Delete
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ShopTheme.error.withValues(alpha: 0.1),
                foregroundColor: ShopTheme.error,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _confirmDelete,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Delete Product',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openCheckout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(productId: _product!.id!),
      ),
    );
    if (!mounted) return;
    _loadData();
  }

  void _addToCart() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      _showFlushbar('You must be logged in.', isError: true);
      return;
    }
    try {
      final result = await _cartRepo.addToCart(
        userId: userId,
        productId: _product!.id!,
        qty: 1,
      );
      if (!mounted) return;
      if (result.clamped) {
        _showFlushbar(
          'Added to cart (quantity clamped to ${result.finalQuantity})',
          isError: false,
        );
      } else {
        _showFlushbar('Added to cart!', isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showFlushbar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _showFlushbar(String message, {required bool isError}) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: isError ? ShopTheme.error : ShopTheme.mint,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle,
        color: ShopTheme.background,
        size: 24,
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: ShopTheme.fontFamily,
          color: ShopTheme.background,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  void _confirmDelete() {
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
        content: const Text(
          'Are you sure you want to delete this product? This cannot be undone.',
          style: TextStyle(
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
              await _deleteProduct();
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

  Future<void> _deleteProduct() async {
    try {
      await _repo.delete(_product!.id!, _product!.sellerId);
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: ShopTheme.mint,
        icon: const Icon(Icons.check_circle, color: ShopTheme.background, size: 24),
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
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: ShopTheme.error,
        icon: const Icon(Icons.error_outline, color: ShopTheme.background, size: 24),
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
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ShopTheme.mint))
          : _product == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: ShopTheme.secondaryText),
                      const SizedBox(height: 16),
                      Text(
                        'Product not found',
                        style: ShopTheme.bodyStyle,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go back'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildGallery(),
                    Expanded(child: _buildContent()),
                  ],
                ),
    );
  }
}
