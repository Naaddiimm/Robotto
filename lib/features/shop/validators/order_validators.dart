import '../data/models/delivery.dart';
import '../data/models/order.dart';

/// Static validation functions for order/checkout fields and status transitions.
/// Each field validator returns `null` if valid, or an error message string.
/// Status transition helpers return `bool`.
class OrderValidators {
  OrderValidators._();

  // ===========================================================================
  // Field validators
  // ===========================================================================

  /// Quantity: integer; 1 to current stock.
  static String? validateQuantity(String? value, int currentStock) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Quantity is required';

    final parsed = int.tryParse(trimmed);
    if (parsed == null) return 'Quantity must be a whole number';
    if (parsed < 1) return 'Quantity must be at least 1';
    if (parsed > currentStock) return 'Quantity cannot exceed available stock ($currentStock)';

    return null;
  }

  /// Recipient name: required; 3 to 60 characters.
  static String? validateRecipientName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Recipient name is required';
    if (trimmed.length < 3) return 'Name must be at least 3 characters';
    if (trimmed.length > 60) return 'Name must be at most 60 characters';
    return null;
  }

  /// Phone: required; 8 digits (Tunisian local format);
  /// optionally prefixed by +216 or 216; spaces allowed and stripped.
  static String? validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Phone number is required';

    // Strip spaces
    String cleaned = trimmed.replaceAll(' ', '');

    // Remove optional +216 or 216 prefix
    if (cleaned.startsWith('+216')) {
      cleaned = cleaned.substring(4);
    } else if (cleaned.startsWith('216')) {
      cleaned = cleaned.substring(3);
    }

    // Must be exactly 8 digits
    if (!RegExp(r'^\d{8}$').hasMatch(cleaned)) {
      return 'Enter a valid 8-digit Tunisian phone number';
    }

    return null;
  }

  /// Address: required for home and relay_point; 10 to 120 characters;
  /// not only digits. Optional for store_pickup.
  static String? validateAddress(String? value, String deliveryMode) {
    if (deliveryMode == Delivery.modeStorePickup) return null;

    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Address is required for this delivery mode';
    if (trimmed.length < 10) return 'Address must be at least 10 characters';
    if (trimmed.length > 120) return 'Address must be at most 120 characters';
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Address cannot be only digits';
    }
    return null;
  }

  /// City: required; 2 to 40 characters.
  static String? validateCity(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'City is required';
    if (trimmed.length < 2) return 'City must be at least 2 characters';
    if (trimmed.length > 40) return 'City must be at most 40 characters';
    return null;
  }

  /// Zone: required; must be in the allowed list.
  static String? validateZone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Zone is required';
    if (!Delivery.zones.contains(trimmed)) {
      return 'Select a valid zone';
    }
    return null;
  }

  /// Delivery mode: required; must be in the allowed list.
  static String? validateDeliveryMode(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Delivery mode is required';
    if (!Delivery.modes.contains(trimmed)) {
      return 'Select a valid delivery mode';
    }
    return null;
  }

  /// Payment method: required; must be in the allowed list.
  /// Only cash_on_delivery is accepted for now; card and wallet are rejected.
  static String? validatePaymentMethod(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Payment method is required';
    if (!Order.paymentMethods.contains(trimmed)) {
      return 'Select a valid payment method';
    }
    if (!Order.acceptedPaymentMethods.contains(trimmed)) {
      return 'This payment method is coming soon';
    }
    return null;
  }

  // ===========================================================================
  // Status transition helpers
  // ===========================================================================

  /// Returns the next status in the fulfillment flow, or null if the current
  /// status is terminal (delivered or cancelled).
  static String? nextStatus(String currentStatus) {
    final index = Order.flowStatuses.indexOf(currentStatus);
    if (index == -1 || index >= Order.flowStatuses.length - 1) return null;
    return Order.flowStatuses[index + 1];
  }

  /// Checks whether advancing from [currentStatus] to [newStatus] is allowed.
  /// Only one step forward in the flow is permitted (no skipping, no backward).
  static bool canAdvance(String currentStatus, String newStatus) {
    final next = nextStatus(currentStatus);
    return next != null && next == newStatus;
  }

  /// Checks whether cancelling an order is allowed.
  /// Cancel is only allowed from `pending` or `preparing`.
  static bool canCancel(String status) {
    return status == Order.statusPending || status == Order.statusPreparing;
  }

  /// Checks whether an order can be hard-deleted from history.
  /// Only `cancelled` or `delivered` orders can be deleted.
  static bool canDelete(String status) {
    return status == Order.statusCancelled || status == Order.statusDelivered;
  }
}
