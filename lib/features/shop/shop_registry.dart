import 'package:flutter/material.dart';

import 'screens/coming_soon_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/delivery_screen.dart';
import 'screens/cart_screen.dart';

/// A shop section shown as a quick-access tile in the Marketplace tab.
///
/// To enable a future section:
/// 1. Create its screen in `lib/shop/screens/`.
/// 2. Flip `enabled` to `true` in the [shopSections] list below.
/// 3. Change the `builder` to the new screen.
/// No other file changes are needed — [ShopModule] loops over [shopSections].
class ShopSection {
  final String id;
  final String title;
  final IconData icon;
  final bool enabled;
  final WidgetBuilder builder;

  const ShopSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.enabled,
    required this.builder,
  });
}

/// The list of shop sections shown as quick-access tiles.
///
/// All sections are `enabled: false` for now. When a real screen is built,
/// flip `enabled` to `true` and change the `builder` to that screen.
final List<ShopSection> shopSections = [
  ShopSection(
    id: 'orders',
    title: 'Orders',
    icon: Icons.receipt_long_outlined,
    enabled: true,
    builder: (context) => const OrdersScreen(),
  ),
  ShopSection(
    id: 'delivery',
    title: 'Delivery',
    icon: Icons.local_shipping_outlined,
    enabled: true,
    builder: (context) => const DeliveryScreen(),
  ),
  ShopSection(
    id: 'cart',
    title: 'Cart',
    icon: Icons.shopping_cart_outlined,
    enabled: true,
    builder: (context) => const CartScreen(),
  ),
  ShopSection(
    id: 'wishlist',
    title: 'Wishlist',
    icon: Icons.favorite_outline,
    enabled: false,
    builder: (context) => const ComingSoonScreen(title: 'Wishlist'),
  ),
  ShopSection(
    id: 'backoffice',
    title: 'Back-office',
    icon: Icons.admin_panel_settings_outlined,
    enabled: false,
    builder: (context) => const ComingSoonScreen(title: 'Back-office'),
  ),
];
