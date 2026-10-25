import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/auth_service.dart';
import '../data/models/order.dart';
import '../data/models/order_item.dart';
import '../data/models/delivery.dart';
import '../data/repositories/order_repository.dart';
import '../validators/order_validators.dart';
import '../widgets/shop_theme.dart';
import '../widgets/delivery_timeline.dart';
import '../widgets/address_field_with_map.dart';

/// Order detail: items, price breakdown, delivery info, timeline, and
/// role-based actions (edit, cancel, advance, delete).
class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderRepo = OrderRepository();
  final _authService = AuthService();

  OrderDetail? _detail;
  bool _isLoading = true;
  int? _currentUserId;
  bool _isBuyer = false;
  bool _isSeller = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final userId = await _authService.getCurrentUserId();
    final detail = await _orderRepo.getOrderById(widget.orderId);
    if (!mounted) return;

    setState(() {
      _currentUserId = userId;
      _detail = detail;
      _isLoading = false;
      if (detail != null && userId != null) {
        _isBuyer = detail.order.buyerId == userId;
        _isSeller = detail.items.any((item) => item.sellerId == userId);
      }
    });

    // Check for status change
    if (detail != null && _isBuyer) {
      _checkStatusChange(detail.order);
    }
  }

  // ---------------------------------------------------------------------------
  // Status change Flushbar
  // ---------------------------------------------------------------------------

  Future<void> _checkStatusChange(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'shop_order_${order.id}_status';
    final lastSeen = prefs.getString(key);

    if (lastSeen != null && lastSeen != order.status) {
      if (!mounted) return;
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: ShopTheme.violet,
        icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
        messageText: Text(
          'Order status changed to ${_statusLabel(order.status)}',
          style: const TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
      ).show(context);
    }

    await prefs.setString(key, order.status);
  }

  String _statusLabel(String status) {
    switch (status) {
      case Order.statusPending:
        return 'Pending';
      case Order.statusPreparing:
        return 'Preparing';
      case Order.statusShipped:
        return 'Shipped';
      case Order.statusOutForDelivery:
        return 'Out for Delivery';
      case Order.statusDelivered:
        return 'Delivered';
      case Order.statusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _advanceStatus() async {
    if (_detail == null || _currentUserId == null) return;
    final next = OrderValidators.nextStatus(_detail!.order.status);
    if (next == null) return;

    _showConfirmDialog(
      title: 'Advance Order',
      icon: Icons.arrow_forward,
      iconColor: ShopTheme.violet,
      message: 'Advance this order to "${_statusLabel(next)}"?',
      confirmText: 'Advance',
      confirmColor: ShopTheme.violet,
      onConfirm: () async {
        try {
          await _orderRepo.advanceStatus(
            orderId: widget.orderId,
            sellerId: _currentUserId!,
          );
          if (!mounted) return;
          _showFlushbar('Order advanced successfully', isError: false);
          _loadOrder();
        } catch (e) {
          if (!mounted) return;
          _showFlushbar(
            e.toString().replaceAll('Exception: ', ''),
            isError: true,
          );
        }
      },
    );
  }

  Future<void> _cancelOrder() async {
    if (_detail == null || _currentUserId == null) return;
    _showConfirmDialog(
      title: 'Cancel Order',
      icon: Icons.cancel_outlined,
      iconColor: ShopTheme.error,
      message:
          'Are you sure you want to cancel this order? Stock will be restored.',
      confirmText: 'Cancel Order',
      confirmColor: ShopTheme.error,
      onConfirm: () async {
        try {
          await _orderRepo.cancelOrder(
            orderId: widget.orderId,
            buyerId: _currentUserId!,
          );
          if (!mounted) return;
          _showFlushbar('Order cancelled successfully', isError: false);
          _loadOrder();
        } catch (e) {
          if (!mounted) return;
          _showFlushbar(
            e.toString().replaceAll('Exception: ', ''),
            isError: true,
          );
        }
      },
    );
  }

  Future<void> _deleteOrder() async {
    if (_detail == null || _currentUserId == null) return;
    _showConfirmDialog(
      title: 'Delete Order',
      icon: Icons.delete_outline,
      iconColor: ShopTheme.error,
      message: 'Delete this order from your history? This cannot be undone.',
      confirmText: 'Delete',
      confirmColor: ShopTheme.error,
      onConfirm: () async {
        try {
          await _orderRepo.deleteOrder(
            orderId: widget.orderId,
            buyerId: _currentUserId!,
          );
          if (!mounted) return;
          _showFlushbar('Order deleted', isError: false);
          if (!mounted) return;
          Navigator.pop(context, true);
        } catch (e) {
          if (!mounted) return;
          _showFlushbar(
            e.toString().replaceAll('Exception: ', ''),
            isError: true,
          );
        }
      },
    );
  }

  void _showEditSheet() {
    if (_detail == null || _detail!.delivery == null) return;
    final delivery = _detail!.delivery!;
    final item = _detail!.items.first;

    final nameCtl = TextEditingController(text: delivery.recipientName);
    final phoneCtl = TextEditingController(text: delivery.phone);
    final cityCtl = TextEditingController(text: delivery.city);
    final addressCtl = TextEditingController(text: delivery.address);
    String mode = delivery.mode;
    String zone = delivery.zone;
    int quantity = item.quantity;

    showModalBottomSheet(
      context: context,
      backgroundColor: ShopTheme.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Order Details',
                        style: TextStyle(
                          fontFamily: ShopTheme.fontFamily,
                          color: ShopTheme.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sheetField(nameCtl, 'Recipient Name'),
                      const SizedBox(height: 12),
                      _sheetField(phoneCtl, 'Phone'),
                      const SizedBox(height: 12),
                      _sheetField(cityCtl, 'City'),
                      const SizedBox(height: 12),
                      // Mode
                      Text('Delivery Mode', style: ShopTheme.labelStyle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: Delivery.modes.map((m) {
                          final labels = {
                            Delivery.modeHome: 'Home',
                            Delivery.modeRelayPoint: 'Relay Point',
                            Delivery.modeStorePickup: 'Store Pickup',
                          };
                          final isSelected = mode == m;
                          return ChoiceChip(
                            label: Text(labels[m]!),
                            selected: isSelected,
                            onSelected: (v) =>
                                setSheet(() => mode = v ? m : mode),
                            selectedColor: ShopTheme.violet.withValues(
                              alpha: 0.25,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? ShopTheme.mint
                                  : ShopTheme.secondaryText,
                              fontFamily: ShopTheme.fontFamily,
                            ),
                            backgroundColor: ShopTheme.surface,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      // Zone
                      Text('Zone', style: ShopTheme.labelStyle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: Delivery.zones.map((z) {
                          final labels = {
                            Delivery.zoneGrandTunis: 'Grand Tunis',
                            Delivery.zoneNorth: 'North',
                            Delivery.zoneCenter: 'Center',
                            Delivery.zoneSouth: 'South',
                          };
                          final isSelected = zone == z;
                          return ChoiceChip(
                            label: Text(labels[z]!),
                            selected: isSelected,
                            onSelected: (v) =>
                                setSheet(() => zone = v ? z : zone),
                            selectedColor: ShopTheme.violet.withValues(
                              alpha: 0.25,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? ShopTheme.mint
                                  : ShopTheme.secondaryText,
                              fontFamily: ShopTheme.fontFamily,
                            ),
                            backgroundColor: ShopTheme.surface,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      if (mode != Delivery.modeStorePickup)
                        AddressFieldWithMap(
                          label: 'Address',
                          controller: addressCtl,
                          cityController: cityCtl,
                          deliveryMode: mode,
                          onSuggestedZone: (suggested) {
                            setSheet(() => zone = suggested);
                          },
                        ),
                      if (mode != Delivery.modeStorePickup)
                        const SizedBox(height: 12),
                      // Quantity
                      Text('Quantity', style: ShopTheme.labelStyle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () => setSheet(() => quantity--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: ShopTheme.violet,
                          ),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              fontFamily: ShopTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShopTheme.text,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setSheet(() => quantity++),
                            icon: const Icon(Icons.add_circle_outline),
                            color: ShopTheme.violet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ShopTheme.mint,
                            foregroundColor: ShopTheme.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _saveEdits(
                              recipientName: nameCtl.text.trim(),
                              phone: phoneCtl.text.trim(),
                              city: cityCtl.text.trim(),
                              address: addressCtl.text.trim(),
                              mode: mode,
                              zone: zone,
                              quantity: quantity,
                            );
                          },
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontFamily: ShopTheme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: ShopTheme.text,
        fontFamily: ShopTheme.fontFamily,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ShopTheme.secondaryText),
        filled: true,
        fillColor: ShopTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _saveEdits({
    required String recipientName,
    required String phone,
    required String city,
    required String address,
    required String mode,
    required String zone,
    required int quantity,
  }) async {
    if (_currentUserId == null) return;
    try {
      await _orderRepo.updateOrderDetails(
        orderId: widget.orderId,
        buyerId: _currentUserId!,
        recipientName: recipientName,
        phone: phone,
        city: city,
        address: address,
        deliveryMode: mode,
        zone: zone,
        quantity: quantity,
      );
      if (!mounted) return;
      _showFlushbar('Order updated successfully', isError: false);
      _loadOrder();
    } catch (e) {
      if (!mounted) return;
      _showFlushbar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _showConfirmDialog({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShopTheme.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ShopTheme.surface, width: 1),
        ),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
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
              backgroundColor: confirmColor.withValues(alpha: 0.1),
              foregroundColor: confirmColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              confirmText,
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: ShopTheme.mint),
              )
            : _detail == null
            ? _buildNotFound()
            : _buildContent(),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: ShopTheme.secondaryText,
          ),
          const SizedBox(height: 16),
          Text('Order not found', style: ShopTheme.bodyStyle),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final order = _detail!.order;
    final items = _detail!.items;
    final delivery = _detail!.delivery;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ShopTheme.screenPadding,
            vertical: 12,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: ShopTheme.text),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text('Order #${order.id}', style: ShopTheme.titleStyle),
              const Spacer(),
              _statusChip(order.status),
            ],
          ),
        ),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline
                if (order.status != Order.statusCancelled)
                  DeliveryTimeline(status: order.status)
                else
                  Center(child: DeliveryTimeline(status: order.status)),
                const SizedBox(height: 24),

                // Items
                Text('Items', style: ShopTheme.labelStyle),
                const SizedBox(height: 8),
                ...items.map((item) => _buildItemRow(item)),
                const SizedBox(height: 16),

                // Price breakdown
                _buildBreakdown(order),
                const SizedBox(height: 16),

                // Delivery info
                if (delivery != null) ...[
                  Text('Delivery Info', style: ShopTheme.labelStyle),
                  const SizedBox(height: 8),
                  _buildDeliveryInfo(delivery),
                ],

                // Actions
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final (label, color) = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: ShopTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
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

  Widget _buildItemRow(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ShopTheme.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.unitPrice.toStringAsFixed(2)} TND × ${item.quantity}',
                  style: ShopTheme.captionStyle,
                ),
              ],
            ),
          ),
          Text(
            '${(item.unitPrice * item.quantity).toStringAsFixed(2)} TND',
            style: TextStyle(
              fontFamily: ShopTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ShopTheme.mint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShopTheme.surfaceHigh),
      ),
      child: Column(
        children: [
          _row('Subtotal', '${order.subtotal.toStringAsFixed(2)} TND'),
          const SizedBox(height: 8),
          _row('Delivery Fee', '${order.deliveryFee.toStringAsFixed(2)} TND'),
          const Divider(color: ShopTheme.surfaceHigh, height: 20),
          _row('Total', '${order.total.toStringAsFixed(2)} TND', bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            fontSize: 14,
            color: ShopTheme.secondaryText,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            fontSize: bold ? 18 : 14,
            color: bold ? ShopTheme.mint : ShopTheme.text,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(Delivery delivery) {
    final modeLabels = {
      Delivery.modeHome: 'Home Delivery',
      Delivery.modeRelayPoint: 'Relay Point',
      Delivery.modeStorePickup: 'Store Pickup',
    };
    final zoneLabels = {
      Delivery.zoneGrandTunis: 'Grand Tunis',
      Delivery.zoneNorth: 'North',
      Delivery.zoneCenter: 'Center',
      Delivery.zoneSouth: 'South',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Recipient', delivery.recipientName),
          _infoRow('Phone', delivery.phone),
          _infoRow('City', delivery.city),
          if (delivery.mode != Delivery.modeStorePickup &&
              delivery.address.isNotEmpty)
            _infoRow('Address', delivery.address),
          _infoRow('Mode', modeLabels[delivery.mode] ?? delivery.mode),
          _infoRow('Zone', zoneLabels[delivery.zone] ?? delivery.zone),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: ShopTheme.captionStyle),
          ),
          Expanded(child: Text(value, style: ShopTheme.bodyMainStyle)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final order = _detail!.order;
    final nextStatus = OrderValidators.nextStatus(order.status);
    final canCancel = OrderValidators.canCancel(order.status);
    final canDelete = OrderValidators.canDelete(order.status);

    return Column(
      children: [
        // Buyer actions
        if (_isBuyer) ...[
          if (order.status == Order.statusPending)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ShopTheme.violet,
                  side: BorderSide(
                    color: ShopTheme.violet.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showEditSheet,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Edit Details',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (canCancel) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShopTheme.error.withValues(alpha: 0.1),
                  foregroundColor: ShopTheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _cancelOrder,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Cancel Order',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (canDelete) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShopTheme.error.withValues(alpha: 0.1),
                  foregroundColor: ShopTheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _deleteOrder,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Delete from History',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
        // Seller actions
        if (_isSeller && nextStatus != null) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ShopTheme.violet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _advanceStatus,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Advance to ${_statusLabel(nextStatus)}',
                    style: const TextStyle(
                      fontFamily: ShopTheme.fontFamily,
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
}
