import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../core/services/auth_service.dart';
import '../data/models/delivery.dart';
import '../data/models/order.dart';
import '../data/models/product.dart';
import '../data/models/cart_item.dart';
import '../data/delivery_fee_calculator.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../validators/order_validators.dart';
import '../widgets/shop_theme.dart';
import '../widgets/shop_text_field.dart';
import '../widgets/address_field_with_map.dart';
import 'order_detail_screen.dart';
import 'orders_screen.dart';

/// Checkout screen for ordering a single product or checking out a cart.
/// When [lines] is provided, performs a multi-seller cart checkout.
class CheckoutScreen extends StatefulWidget {
  final int? productId;
  final List<CartLine>? lines;
  final int? userId;

  const CheckoutScreen({
    super.key,
    this.productId,
    this.lines,
    this.userId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productRepo = ProductRepository();
  final _orderRepo = OrderRepository();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  Product? _product;
  bool _isLoading = true;
  bool _isProcessing = false;

  int _quantity = 1;
  String _selectedMode = Delivery.modeHome;
  String _selectedZone = Delivery.zoneGrandTunis;
  String _selectedPayment = Order.cashOnDelivery;

  @override
  void initState() {
    super.initState();
    if (_isCartCheckout) {
      _isLoading = false;
    } else {
      _loadProduct();
    }
  }

  bool get _isCartCheckout => widget.lines != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final data = await _productRepo.getById(widget.productId!);
    if (!mounted) return;
    setState(() {
      _product = data?.product;
      _isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Live summary
  // ---------------------------------------------------------------------------

  List<SellerGroup> get _sellerGroups =>
      CartRepository.groupBySeller(widget.lines ?? []);

  double get _subtotal {
    if (_isCartCheckout) {
      return CartRepository.subtotal(widget.lines!);
    }
    return (_product?.price ?? 0) * _quantity;
  }

  double get _totalFee {
    if (_isCartCheckout) {
      double total = 0;
      for (final g in _sellerGroups) {
        final weight =
            g.lines.fold(0.0, (s, l) => s + l.weightKg * l.item.quantity);
        total += DeliveryFeeCalculator.calculate(
            _selectedZone, weight, _selectedMode);
      }
      return total;
    }
    return DeliveryFeeCalculator.calculate(
        _selectedZone, _totalWeightKg, _selectedMode);
  }

  double get _totalWeightKg => (_product?.weightKg ?? 0) * _quantity;
  double get _fee => _totalFee;
  double get _total => _subtotal + _totalFee;

  // ---------------------------------------------------------------------------
  // Zone dropdown
  // ---------------------------------------------------------------------------

  void _showZoneSheet() {
    final zoneLabels = {
      Delivery.zoneGrandTunis: 'Grand Tunis',
      Delivery.zoneNorth: 'North',
      Delivery.zoneCenter: 'Center',
      Delivery.zoneSouth: 'South',
    };
    showModalBottomSheet(
      context: context,
      backgroundColor: ShopTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Zone',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    color: ShopTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...Delivery.zones.map((zone) {
                  final isSelected = zone == _selectedZone;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedZone = zone);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            zoneLabels[zone]!,
                            style: TextStyle(
                              fontFamily: ShopTheme.fontFamily,
                              color: isSelected
                                  ? ShopTheme.mint
                                  : ShopTheme.text,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: ShopTheme.mint),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Confirm order
  // ---------------------------------------------------------------------------

  Future<void> _confirmOrder() async {
    if (!_isCartCheckout && _product == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final buyerId =
        _isCartCheckout ? widget.userId : await _authService.getCurrentUserId();
    if (buyerId == null) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showFlushbar('You must be logged in to place an order.', isError: true);
      return;
    }

    if (_isCartCheckout) {
      await _confirmCartCheckout(buyerId);
    } else {
      await _confirmSingleOrder(buyerId);
    }
  }

  Future<void> _confirmSingleOrder(int buyerId) async {
    final qtyError =
        OrderValidators.validateQuantity(_quantity.toString(), _product!.stock);
    if (qtyError != null) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showFlushbar(qtyError, isError: true);
      return;
    }
    try {
      final orderId = await _orderRepo.createOrder(
        buyerId: buyerId,
        product: _product!,
        quantity: _quantity,
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        zone: _selectedZone,
        deliveryMode: _selectedMode,
        paymentMethod: _selectedPayment,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(orderId: orderId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showFlushbar(e.toString().replaceAll('Exception: ', ''), isError: true);
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _confirmCartCheckout(int buyerId) async {
    try {
      final result = await _orderRepo.createOrdersFromCart(
        buyerId: buyerId,
        lines: widget.lines!,
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        zone: _selectedZone,
        deliveryMode: _selectedMode,
        paymentMethod: _selectedPayment,
      );

      if (!mounted) return;

      if (result.success) {
        _showFlushbar(
          '${result.orderIds.length} order(s) placed successfully!',
          isError: false,
        );
        if (!mounted) return;
        // Navigate to OrdersScreen, removing checkout from the stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrdersScreen()),
          (route) => route.isFirst,
        );
      } else {
        _showFlushbar(
          result.failedProducts.join(', '),
          isError: true,
        );
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showFlushbar(e.toString().replaceAll('Exception: ', ''), isError: true);
      setState(() => _isProcessing = false);
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
      duration: const Duration(seconds: 3),
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
                child: CircularProgressIndicator(color: ShopTheme.mint))
            : !_isCartCheckout && _product == null
                ? _buildNotFound()
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_isCartCheckout)
                                  _buildCartSummary()
                                else ...[
                                  _buildProductInfo(),
                                  const SizedBox(height: 24),
                                  _buildQuantityStepper(),
                                ],
                                const SizedBox(height: 16),
                                ShopTextField(
                                  label: 'Recipient Name',
                                  controller: _nameController,
                                  hintText: 'Full name',
                                  icon: Icons.person_outline,
                                  validator:
                                      OrderValidators.validateRecipientName,
                                ),
                                const SizedBox(height: 16),
                                ShopTextField(
                                  label: 'Phone Number',
                                  controller: _phoneController,
                                  hintText: '8-digit number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: OrderValidators.validatePhone,
                                ),
                                const SizedBox(height: 16),
                                _buildDeliveryModeSelector(),
                                const SizedBox(height: 16),
                                _buildZoneDropdown(),
                                const SizedBox(height: 16),
                                ShopTextField(
                                  label: 'City',
                                  controller: _cityController,
                                  hintText: 'City name',
                                  icon: Icons.location_city_outlined,
                                  validator: OrderValidators.validateCity,
                                ),
                                if (_selectedMode !=
                                    Delivery.modeStorePickup) ...[
                                  const SizedBox(height: 16),
                                  AddressFieldWithMap(
                                    label: 'Address',
                                    controller: _addressController,
                                    cityController: _cityController,
                                    deliveryMode: _selectedMode,
                                    onSuggestedZone: (zone) {
                                      setState(() => _selectedZone = zone);
                                    },
                                  ),
                                ],
                                const SizedBox(height: 16),
                                _buildPaymentSelector(),
                                const SizedBox(height: 24),
                                _buildSummary(),
                                const SizedBox(height: 24),
                                _buildConfirmButton(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: ShopTheme.secondaryText),
          const SizedBox(height: 16),
          Text('Product not found', style: ShopTheme.bodyStyle),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  color: ShopTheme.violet, size: 22),
              const SizedBox(width: 8),
              Text(
                '${widget.lines!.length} item(s) from ${_sellerGroups.length} seller(s)',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ShopTheme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.lines!.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${line.productName} × ${line.item.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: ShopTheme.fontFamily,
                          fontSize: 13,
                          color: ShopTheme.secondaryText,
                        ),
                      ),
                    ),
                    Text(
                      '${line.lineTotal.toStringAsFixed(2)} TND',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ShopTheme.text,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ShopTheme.screenPadding, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: ShopTheme.text),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text('Checkout', style: ShopTheme.titleStyle),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: ShopTheme.violet, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ShopTheme.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_product!.price.toStringAsFixed(2)} TND  •  ${_product!.weightKg.toStringAsFixed(2)} kg  •  ${_product!.stock} in stock',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 12,
                    color: ShopTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text('Quantity', style: ShopTheme.labelStyle),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: ShopTheme.violet,
              disabledColor: ShopTheme.surfaceHigh,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ShopTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_quantity',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ShopTheme.text,
                ),
              ),
            ),
            IconButton(
              onPressed: _quantity < _product!.stock
                  ? () => setState(() => _quantity++)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: ShopTheme.violet,
              disabledColor: ShopTheme.surfaceHigh,
            ),
            const SizedBox(width: 8),
            Text(
              'Max: ${_product!.stock}',
              style: ShopTheme.captionStyle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryModeSelector() {
    final modes = [
      (Delivery.modeHome, 'Home Delivery', Icons.home_outlined),
      (Delivery.modeRelayPoint, 'Relay Point', Icons.store_outlined),
      (Delivery.modeStorePickup, 'Store Pickup', Icons.shopping_bag_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text('Delivery Mode', style: ShopTheme.labelStyle),
        ),
        Row(
          children: modes.map((mode) {
            final isSelected = _selectedMode == mode.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMode = mode.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ShopTheme.violet.withValues(alpha: 0.15)
                        : ShopTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? ShopTheme.violet.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(mode.$3,
                          size: 22,
                          color: isSelected
                              ? ShopTheme.mint
                              : ShopTheme.secondaryText),
                      const SizedBox(height: 4),
                      Text(
                        mode.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ShopTheme.fontFamily,
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? ShopTheme.mint
                              : ShopTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildZoneDropdown() {
    final zoneLabels = {
      Delivery.zoneGrandTunis: 'Grand Tunis',
      Delivery.zoneNorth: 'North',
      Delivery.zoneCenter: 'Center',
      Delivery.zoneSouth: 'South',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text('Zone', style: ShopTheme.labelStyle),
        ),
        GestureDetector(
          onTap: _showZoneSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ShopTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: ShopTheme.secondaryText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    zoneLabels[_selectedZone]!,
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      color: ShopTheme.text,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    color: ShopTheme.secondaryText, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSelector() {
    final methods = [
      (Order.cashOnDelivery, 'Cash on Delivery', Icons.payments_outlined, true),
      (Order.card, 'Card', Icons.credit_card_outlined, false),
      (Order.mobileWallet, 'Mobile Wallet', Icons.account_balance_wallet_outlined, false),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text('Payment Method', style: ShopTheme.labelStyle),
        ),
        ...methods.map((method) {
          final isSelected = _selectedPayment == method.$1;
          final isEnabled = method.$4;
          return GestureDetector(
            onTap: isEnabled
                ? () => setState(() => _selectedPayment = method.$1)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? ShopTheme.violet.withValues(alpha: 0.15)
                    : ShopTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? ShopTheme.violet.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method.$3,
                    size: 22,
                    color: isEnabled
                        ? (isSelected ? ShopTheme.mint : ShopTheme.secondaryText)
                        : ShopTheme.secondaryText.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method.$2,
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isEnabled
                            ? (isSelected ? ShopTheme.mint : ShopTheme.text)
                            : ShopTheme.secondaryText.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  if (!isEnabled)
                    Text(
                      'Coming soon',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 11,
                        color: ShopTheme.secondaryText.withValues(alpha: 0.4),
                      ),
                    )
                  else if (isSelected)
                    const Icon(Icons.check_circle, color: ShopTheme.mint, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShopTheme.surfaceHigh),
      ),
      child: Column(
        children: [
          if (_isCartCheckout) ...[
            ..._sellerGroups.map((g) {
              final gSubtotal = CartRepository.subtotal(g.lines);
              final gWeight =
                  g.lines.fold(0.0, (s, l) => s + l.weightKg * l.item.quantity);
              final gFee = DeliveryFeeCalculator.calculate(
                  _selectedZone, gWeight, _selectedMode);
              return Column(
                children: [
                  _summaryRow(
                    'Seller #${g.sellerId} subtotal',
                    '${gSubtotal.toStringAsFixed(2)} TND',
                  ),
                  const SizedBox(height: 4),
                  _summaryRow(
                    'Seller #${g.sellerId} delivery',
                    _selectedMode == Delivery.modeStorePickup
                        ? 'Free'
                        : '${gFee.toStringAsFixed(2)} TND',
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
            const Divider(color: ShopTheme.surfaceHigh, height: 20),
            _summaryRow(
                'Grand Total', '${_total.toStringAsFixed(2)} TND',
                isBold: true),
          ] else ...[
            _summaryRow('Subtotal', '${_subtotal.toStringAsFixed(2)} TND'),
            const SizedBox(height: 8),
            _summaryRow(
                'Delivery Fee',
                _selectedMode == Delivery.modeStorePickup
                    ? 'Free (Store Pickup)'
                    : '${_fee.toStringAsFixed(2)} TND'),
            const Divider(color: ShopTheme.surfaceHigh, height: 20),
            _summaryRow('Total', '${_total.toStringAsFixed(2)} TND',
                isBold: true),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            fontSize: 14,
            color: ShopTheme.secondaryText,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            fontSize: isBold ? 18 : 14,
            color: isBold ? ShopTheme.mint : ShopTheme.text,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
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
        onPressed: _isProcessing ? null : _confirmOrder,
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: ShopTheme.background, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_outline, size: 20),
                ],
              ),
      ),
    );
  }
}
