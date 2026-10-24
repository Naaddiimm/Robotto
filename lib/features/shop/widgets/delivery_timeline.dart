import 'package:flutter/material.dart';
import '../data/models/order.dart';
import 'shop_theme.dart';

/// 4-step delivery timeline: In preparation, Shipped, Out for delivery, Delivered.
///
/// - `pending` shows as before step 1 (step 0).
/// - `preparing` shows as step 1 (In preparation) active.
/// - `shipped` shows as step 2 (Shipped) active.
/// - `out_for_delivery` shows as step 3 (Out for delivery) active.
/// - `delivered` shows as all steps completed.
/// - `cancelled` shows a red badge instead of the timeline.
class DeliveryTimeline extends StatelessWidget {
  final String status;

  const DeliveryTimeline({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == Order.statusCancelled) {
      return _cancelledBadge();
    }

    final currentStep = _stepIndex(status);
    final steps = [
      _StepData(Icons.inventory_2_outlined, 'In preparation'),
      _StepData(Icons.local_shipping_outlined, 'Shipped'),
      _StepData(Icons.delivery_dining_outlined, 'Out for delivery'),
      _StepData(Icons.check_circle_outline, 'Delivered'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                // Step circle + label
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? ShopTheme.mint.withValues(alpha: 0.15)
                            : ShopTheme.surface,
                        border: Border.all(
                          color: isCompleted || isCurrent
                              ? ShopTheme.mint
                              : ShopTheme.surfaceHigh,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        step.icon,
                        size: 18,
                        color: isCompleted || isCurrent
                            ? ShopTheme.mint
                            : ShopTheme.secondaryText.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 9,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted || isCurrent
                            ? ShopTheme.text
                            : ShopTheme.secondaryText.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                // Connector line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 22),
                      color: index < currentStep
                          ? ShopTheme.mint
                          : ShopTheme.surfaceHigh,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  int _stepIndex(String status) {
    switch (status) {
      case Order.statusPending:
        return 0;
      case Order.statusPreparing:
        return 1;
      case Order.statusShipped:
        return 2;
      case Order.statusOutForDelivery:
        return 3;
      case Order.statusDelivered:
        return 4;
      default:
        return 0;
    }
  }

  Widget _cancelledBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ShopTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShopTheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel_outlined, color: ShopTheme.error, size: 20),
          const SizedBox(width: 8),
          Text(
            'Order Cancelled',
            style: TextStyle(
              fontFamily: ShopTheme.fontFamily,
              color: ShopTheme.error,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String label;
  _StepData(this.icon, this.label);
}
