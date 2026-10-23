import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../data/models/order.dart';
import '../data/repositories/order_repository.dart';
import '../widgets/shop_theme.dart';
import 'order_detail_screen.dart';

/// Orders screen with two tabs: My Orders (as buyer) and Received Orders (as seller).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final _orderRepo = OrderRepository();
  final _authService = AuthService();
  late TabController _tabController;

  List<Order> _myOrders = [];
  List<Order> _receivedOrders = [];
  bool _isLoadingMy = true;
  bool _isLoadingReceived = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = await _authService.getCurrentUserId();
    if (!mounted) return;
    setState(() => _userId = userId);
    if (userId == null) {
      setState(() {
        _isLoadingMy = false;
        _isLoadingReceived = false;
      });
      return;
    }
    _loadMyOrders(userId);
    _loadReceivedOrders(userId);
  }

  Future<void> _loadMyOrders(int userId) async {
    final orders = await _orderRepo.getMyOrders(userId);
    if (!mounted) return;
    setState(() {
      _myOrders = orders;
      _isLoadingMy = false;
    });
  }

  Future<void> _loadReceivedOrders(int userId) async {
    final orders = await _orderRepo.getReceivedOrders(userId);
    if (!mounted) return;
    setState(() {
      _receivedOrders = orders;
      _isLoadingReceived = false;
    });
  }

  Future<void> _refresh() async {
    if (_userId == null) return;
    setState(() {
      _isLoadingMy = true;
      _isLoadingReceived = true;
    });
    await _loadMyOrders(_userId!);
    await _loadReceivedOrders(_userId!);
  }

  // ---------------------------------------------------------------------------
  // Status chip
  // ---------------------------------------------------------------------------

  Widget _statusChip(String status) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        config.$1,
        style: TextStyle(
          fontFamily: ShopTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: config.$2,
        ),
      ),
    );
  }

  (String, Color) _statusConfig(String status) {
    switch (status) {
      case Order.statusPending:
        return ('Pending', ShopTheme.secondaryText);
      case Order.statusPreparing:
        return ('Preparing', ShopTheme.violet);
      case Order.statusShipped:
        return ('Shipped', ShopTheme.violet);
      case Order.statusOutForDelivery:
        return ('Out for Delivery', ShopTheme.mint);
      case Order.statusDelivered:
        return ('Delivered', ShopTheme.mint);
      case Order.statusCancelled:
        return ('Cancelled', ShopTheme.error);
      default:
        return (status, ShopTheme.secondaryText);
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  // ---------------------------------------------------------------------------
  // Order list
  // ---------------------------------------------------------------------------

  Widget _buildOrderList(List<Order> orders, bool isLoading) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: ShopTheme.mint));
    }
    if (orders.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        ShopTheme.screenPadding,
        8,
        ShopTheme.screenPadding,
        ShopTheme.bottomNavPadding,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderRow(order);
      },
    );
  }

  Widget _buildOrderRow(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailScreen(orderId: order.id!),
            ),
          );
          if (!mounted) return;
          _refresh();
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ShopTheme.violet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: ShopTheme.violet,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ShopTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: ShopTheme.captionStyle,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.total.toStringAsFixed(2)} TND',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ShopTheme.mint,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _statusChip(order.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: ShopTheme.secondaryText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: ShopTheme.headingStyle.copyWith(
              color: ShopTheme.secondaryText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
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
        title: Text('Orders', style: ShopTheme.titleStyle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ShopTheme.mint,
          labelColor: ShopTheme.mint,
          unselectedLabelColor: ShopTheme.secondaryText,
          labelStyle: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'My Orders'),
            Tab(text: 'Received Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_myOrders, _isLoadingMy),
          _buildOrderList(_receivedOrders, _isLoadingReceived),
        ],
      ),
    );
  }
}
