import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../data/models/delivery.dart';
import '../data/repositories/order_repository.dart';
import '../data/delivery_fee_calculator.dart';
import '../widgets/shop_theme.dart';
import '../widgets/delivery_timeline.dart';
import 'order_detail_screen.dart';

/// Delivery screen: list of the current user's deliveries (as buyer) with
/// timeline, tap-through to order detail, and an estimate fee calculator.
class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final _orderRepo = OrderRepository();
  final _authService = AuthService();

  List<Delivery> _deliveries = [];
  bool _isLoading = true;

  // Fee estimator state
  String _estimateZone = Delivery.zoneGrandTunis;
  String _estimateMode = Delivery.modeHome;
  String _weightInput = '1';

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }
    final deliveries = await _orderRepo.getDeliveriesForBuyer(userId);
    if (!mounted) return;
    setState(() {
      _deliveries = deliveries;
      _isLoading = false;
    });
  }

  double get _estimatedFee {
    final weight = double.tryParse(_weightInput.replaceAll(',', '.')) ?? 0;
    return DeliveryFeeCalculator.calculate(_estimateZone, weight, _estimateMode);
  }

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
        title: Text('Delivery', style: ShopTheme.titleStyle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ShopTheme.mint))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                ShopTheme.screenPadding, 8, ShopTheme.screenPadding, 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeeEstimator(),
                  const SizedBox(height: 24),
                  Text('My Deliveries', style: ShopTheme.labelStyle),
                  const SizedBox(height: 8),
                  if (_deliveries.isEmpty)
                    _buildEmptyState()
                  else
                    ..._deliveries.map((d) => _buildDeliveryCard(d)),
                ],
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Fee estimator
  // ---------------------------------------------------------------------------

  Widget _buildFeeEstimator() {
    final zoneLabels = {
      Delivery.zoneGrandTunis: 'Grand Tunis',
      Delivery.zoneNorth: 'North',
      Delivery.zoneCenter: 'Center',
      Delivery.zoneSouth: 'South',
    };
    final modeLabels = {
      Delivery.modeHome: 'Home',
      Delivery.modeRelayPoint: 'Relay',
      Delivery.modeStorePickup: 'Pickup',
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShopTheme.surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: ShopTheme.mint, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estimate Delivery Fee',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ShopTheme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Zone chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: Delivery.zones.map((z) {
              final isSelected = _estimateZone == z;
              return GestureDetector(
                onTap: () => setState(() => _estimateZone = z),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ShopTheme.violet.withValues(alpha: 0.2)
                        : ShopTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? ShopTheme.violet.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    zoneLabels[z]!,
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? ShopTheme.mint : ShopTheme.secondaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Mode chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: Delivery.modes.map((m) {
              final isSelected = _estimateMode == m;
              return GestureDetector(
                onTap: () => setState(() => _estimateMode = m),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ShopTheme.violet.withValues(alpha: 0.2)
                        : ShopTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? ShopTheme.violet.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    modeLabels[m]!,
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? ShopTheme.mint : ShopTheme.secondaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Weight input
          Row(
            children: [
              Text(
                'Weight (kg):',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontSize: 13,
                  color: ShopTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: ShopTheme.text,
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: ShopTheme.surfaceHigh,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  controller: TextEditingController(text: _weightInput),
                  onChanged: (v) => setState(() => _weightInput = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fee display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ShopTheme.mint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Fee',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 14,
                    color: ShopTheme.secondaryText,
                  ),
                ),
                Text(
                  _estimateMode == Delivery.modeStorePickup
                      ? 'Free (Store Pickup)'
                      : '${_estimatedFee.toStringAsFixed(2)} TND',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ShopTheme.mint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Delivery cards
  // ---------------------------------------------------------------------------

  Widget _buildDeliveryCard(Delivery delivery) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: delivery.orderId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ShopTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    color: ShopTheme.violet, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Order #${delivery.orderId}',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ShopTheme.text,
                  ),
                ),
                const Spacer(),
                Text(
                  '${delivery.fee.toStringAsFixed(2)} TND',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ShopTheme.mint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DeliveryTimeline(status: delivery.status),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.local_shipping_outlined,
            size: 56,
            color: ShopTheme.secondaryText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No deliveries yet',
            style: ShopTheme.headingStyle.copyWith(
              color: ShopTheme.secondaryText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your deliveries will appear here once you place an order.',
            style: ShopTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
