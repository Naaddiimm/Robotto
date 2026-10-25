import 'dart:io';

import 'package:flutter/material.dart';

import '../data/repositories/product_repository.dart';
import 'shop_theme.dart';

/// Product card for the 2-column catalog grid.
/// Shows cover thumbnail (BoxFit.cover), name, price, and stock badge.
class ProductCard extends StatelessWidget {
  final ProductWithCover item;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final hasCover =
        item.coverPath != null && File(item.coverPath!).existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ShopTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Hero(
                  tag: 'product_${product.id}',
                  child: hasCover
                      ? Image.file(
                          File(item.coverPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, _) =>
                              _placeholderIcon(),
                          cacheWidth: 400,
                        )
                      : _placeholderIcon(),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 13,
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
                  const SizedBox(height: 6),
                  _stockBadge(product.stock),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: ShopTheme.surfaceHigh,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: ShopTheme.secondaryText.withValues(alpha: 0.4),
          size: 32,
        ),
      ),
    );
  }

  Widget _stockBadge(int stock) {
    final inStock = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: inStock
            ? ShopTheme.mint.withValues(alpha: 0.15)
            : ShopTheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        inStock ? '$stock in stock' : 'Out of stock',
        style: TextStyle(
          fontFamily: ShopTheme.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: inStock ? ShopTheme.mint : ShopTheme.error,
        ),
      ),
    );
  }
}
