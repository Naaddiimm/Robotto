// ---------------------------------------------------------------------------
// ShopModule — entry widget for the Marketplace tab.
//
// PUBLIC READ-ONLY API for other modules:
//   ShopModule.getProductsByCategory(String category)
//
// Other modules MUST use only this API and must NEVER open robotto_shop.db
// directly. If you need more queries, add them here as static methods.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/shop_theme.dart';
import 'shop_registry.dart';
import 'data/models/product.dart';
import 'data/shop_database.dart';
import 'data/repositories/cart_repository.dart';
import 'screens/catalog_screen.dart';
import 'screens/my_products_screen.dart';
import 'screens/cart_screen.dart';

class ShopModule extends StatefulWidget {
  const ShopModule({super.key});

  // -------------------------------------------------------------------------
  // Public read-only API for other modules
  // -------------------------------------------------------------------------

  /// Returns all products in the given [category], newest first.
  ///
  /// Other modules must use this method instead of opening robotto_shop.db.
  static Future<List<Product>> getProductsByCategory(String category) async {
    final db = await ShopDatabase.instance.database;
    final maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return maps.map(Product.fromMap).toList();
  }

  @override
  State<ShopModule> createState() => _ShopModuleState();
}

class _ShopModuleState extends State<ShopModule> {
  int _selectedTab = 0; // 0 = Catalog, 1 = My Products
  final CartRepository _cartRepo = CartRepository();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final userId = await AuthService().getCurrentUserId();
    if (!mounted) return;
    _userId = userId;
    if (userId != null) {
      _cartRepo.refreshCount(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          _buildSegmentedSwitch(),
          const SizedBox(height: ShopTheme.itemSpacing),
          _buildQuickAccessTiles(),
          const SizedBox(height: ShopTheme.itemSpacing),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [CatalogScreen(), MyProductsScreen()],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Robotto branding
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ROBOTT',
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(left: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Right: cart icon with badge
          ValueListenableBuilder<int>(
            valueListenable: _cartRepo.cartCount,
            builder: (context, count, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      ).then((_) {
                        if (_userId != null) {
                          _cartRepo.refreshCount(userId: _userId!);
                        }
                      });
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: ShopTheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: ShopTheme.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Segmented switch: Catalog / My Products
  // -------------------------------------------------------------------------

  Widget _buildSegmentedSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShopTheme.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ShopTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildSegment('Catalog', 0),
            _buildSegment('My Products', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? ShopTheme.violet.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: ShopTheme.violet.withValues(alpha: 0.5))
                : Border.all(color: Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ShopTheme.fontFamily,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? ShopTheme.mint : ShopTheme.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Quick-access tiles (from shopSections)
  // -------------------------------------------------------------------------

  Widget _buildQuickAccessTiles() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: ShopTheme.screenPadding,
        ),
        itemCount: shopSections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final section = shopSections[index];
          return _buildTile(section);
        },
      ),
    );
  }

  Widget _buildTile(ShopSection section) {
    final isDimmed = !section.enabled;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: section.builder));
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ShopTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDimmed
                ? ShopTheme.surfaceHigh.withValues(alpha: 0.3)
                : ShopTheme.violet.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              section.icon,
              size: 28,
              color: isDimmed
                  ? ShopTheme.secondaryText.withValues(alpha: 0.4)
                  : ShopTheme.violet,
            ),
            const SizedBox(height: 8),
            Text(
              section.title,
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDimmed
                    ? ShopTheme.secondaryText.withValues(alpha: 0.4)
                    : ShopTheme.text,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
