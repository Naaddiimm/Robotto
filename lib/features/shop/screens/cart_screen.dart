import 'dart:io';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../core/services/auth_service.dart';
import '../data/models/cart_item.dart';
import '../data/repositories/cart_repository.dart';
import '../widgets/shop_theme.dart';
import 'checkout_screen.dart';

/// Shopping cart screen. Lists cart lines with quantity steppers, issue
/// warnings, a bottom bar with subtotal and checkout, and an empty state.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartRepo = CartRepository();
  final _authService = AuthService();
  List<CartLine> _lines = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final userId = await _authService.getCurrentUserId();
    if (!mounted) return;
    setState(() => _userId = userId);
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final lines = await _cartRepo.getCartLines(userId: userId);
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _isLoading = false;
    });
  }

  bool get _hasBlockingIssues =>
      _lines.any((l) => l.hasIssue);

  double get _subtotal => CartRepository.subtotal(_lines);

  Future<void> _updateQuantity(CartLine line, int newQty) async {
    if (_userId == null) return;
    try {
      final clamped = CartRepository.clampQuantity(newQty, line.stock);
      await _cartRepo.updateQuantity(
        userId: _userId!,
        productId: line.item.productId,
        qty: clamped,
      );
      _loadCart();
    } catch (e) {
      if (!mounted) return;
      _showFlushbar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  Future<void> _removeItem(CartLine line) async {
    if (_userId == null) return;
    await _cartRepo.removeItem(
      userId: _userId!,
      productId: line.item.productId,
    );
    if (!mounted) return;
    _showFlushbar('Removed "${line.productName}" from cart');
    _loadCart();
  }

  void _confirmClear() {
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
            Icon(Icons.delete_sweep_outlined, color: ShopTheme.error),
            SizedBox(width: 12),
            Text(
              'Clear Cart',
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Remove all items from your cart?',
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: ShopTheme.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  color: ShopTheme.secondaryText,
                  fontWeight: FontWeight.bold,
                )),
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
              if (_userId != null) {
                await _cartRepo.clear(userId: _userId!);
                if (!mounted) return;
                _loadCart();
              }
            },
            child: const Text('Clear',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  void _showFlushbar(String message, {bool isError = false}) {
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopTheme.background,
      appBar: AppBar(
        backgroundColor: ShopTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ShopTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cart', style: ShopTheme.titleStyle),
        actions: [
          if (_lines.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined,
                  color: ShopTheme.error),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ShopTheme.mint))
          : _lines.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(child: _buildList()),
                    _buildBottomBar(),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 56,
              color: ShopTheme.secondaryText.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: ShopTheme.headingStyle.copyWith(
              color: ShopTheme.secondaryText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text('Browse the catalog to add products.', style: ShopTheme.bodyStyle),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ShopTheme.mint,
              foregroundColor: ShopTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Go to Catalog',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        ShopTheme.screenPadding, 8, ShopTheme.screenPadding, 16,
      ),
      itemCount: _lines.length,
      itemBuilder: (context, index) {
        return _buildCartLineCard(_lines[index]);
      },
    );
  }

  Widget _buildCartLineCard(CartLine line) {
    final hasCover =
        line.coverImagePath != null && File(line.coverImagePath!).existsSync();

    return Dismissible(
      key: ValueKey('${line.item.productId}_${line.item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ShopTheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: ShopTheme.error),
      ),
      confirmDismiss: (direction) async {
        await _removeItem(line);
        return false; // We handle removal ourselves
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ShopTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 70,
                height: 70,
                child: hasCover
                    ? Image.file(
                        File(line.coverImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, _) => Container(
                          color: ShopTheme.surfaceHigh,
                          child: Icon(Icons.image_outlined,
                              color: ShopTheme.secondaryText
                                  .withValues(alpha: 0.4)),
                        ),
                        cacheWidth: 140,
                      )
                    : Container(
                        color: ShopTheme.surfaceHigh,
                        child: Icon(Icons.image_outlined,
                            color: ShopTheme.secondaryText
                                .withValues(alpha: 0.4)),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info + controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.productName,
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
                    '${line.unitPrice.toStringAsFixed(2)} TND',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ShopTheme.mint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity stepper
                  Row(
                    children: [
                      IconButton(
                        onPressed: line.unavailable || line.outOfStock
                            ? null
                            : () => _updateQuantity(
                                line, line.item.quantity - 1),
                        icon: const Icon(Icons.remove_circle_outline,
                            size: 20),
                        color: ShopTheme.violet,
                        disabledColor: ShopTheme.surfaceHigh,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${line.item.quantity}',
                          style: TextStyle(
                            fontFamily: ShopTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ShopTheme.text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: line.unavailable || line.outOfStock ||
                                line.item.quantity >= line.stock
                            ? null
                            : () => _updateQuantity(
                                line, line.item.quantity + 1),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        color: ShopTheme.violet,
                        disabledColor: ShopTheme.surfaceHigh,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Text(
                        '${line.lineTotal.toStringAsFixed(2)} TND',
                        style: TextStyle(
                          fontFamily: ShopTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ShopTheme.text,
                        ),
                      ),
                    ],
                  ),
                  if (line.hasIssue) _issueLabel(line),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _issueLabel(CartLine line) {
    String message;
    if (line.unavailable) {
      message = 'Product no longer available';
    } else if (line.outOfStock) {
      message = 'Out of stock — remove to checkout';
    } else if (line.quantityExceedsStock) {
      message = 'Quantity exceeds stock (${line.stock})';
    } else {
      message = '';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: ShopTheme.error, size: 14),
          const SizedBox(width: 4),
          Text(
            message,
            style: TextStyle(
              fontFamily: ShopTheme.fontFamily,
              fontSize: 11,
              color: ShopTheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: ShopTheme.surfaceHigh, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 16,
                      color: ShopTheme.secondaryText,
                    )),
                Text(
                  '${_subtotal.toStringAsFixed(2)} TND',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ShopTheme.mint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShopTheme.mint,
                  foregroundColor: ShopTheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (_lines.isEmpty || _hasBlockingIssues || _userId == null)
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              lines: _lines,
                              userId: _userId!,
                            ),
                          ),
                        );
                        if (!mounted) return;
                        if (result == true) {
                          _loadCart();
                        }
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _hasBlockingIssues
                          ? 'Fix issues to checkout'
                          : 'Checkout',
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
        ),
      ),
    );
  }
}
