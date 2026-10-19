import '../data/models/delivery.dart';

/// Calculates delivery fees based on zone, total weight, and delivery mode.
///
/// Fee rules (all values are constants so they are easy to change):
/// - Store pickup: 0
/// - Otherwise: base(zone) + perKg(zone) * totalWeightKg, rounded to 2 decimals
///
/// Zone table:
/// | Zone        | Base (TND) | Per kg (TND) |
/// |-------------|-----------|--------------|
/// | Grand Tunis | 5         | 1            |
/// | North       | 7         | 1.5          |
/// | Center      | 8         | 1.5          |
/// | South       | 10        | 2            |
class DeliveryFeeCalculator {
  // ---------------------------------------------------------------------------
  // Zone fee constants
  // ---------------------------------------------------------------------------

  static const double grandTunisBase = 5;
  static const double grandTunisPerKg = 1;

  static const double northBase = 7;
  static const double northPerKg = 1.5;

  static const double centerBase = 8;
  static const double centerPerKg = 1.5;

  static const double southBase = 10;
  static const double southPerKg = 2;

  /// Map of zone → (base, perKg) for easy lookup.
  static const Map<String, _ZoneFee> _zoneFees = {
    Delivery.zoneGrandTunis: _ZoneFee(grandTunisBase, grandTunisPerKg),
    Delivery.zoneNorth: _ZoneFee(northBase, northPerKg),
    Delivery.zoneCenter: _ZoneFee(centerBase, centerPerKg),
    Delivery.zoneSouth: _ZoneFee(southBase, southPerKg),
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the delivery fee rounded to 2 decimal places.
  ///
  /// - [zone] must be one of [Delivery.zones].
  /// - [totalWeightKg] is the combined weight of all items in the order.
  /// - [deliveryMode] store_pickup returns 0 regardless of zone or weight.
  static double calculate(String zone, double totalWeightKg, String deliveryMode) {
    if (deliveryMode == Delivery.modeStorePickup) return 0;

    final fee = _zoneFees[zone];
    if (fee == null) return 0;

    final raw = fee.base + (fee.perKg * totalWeightKg);
    // Round to 2 decimal places
    return double.parse(raw.toStringAsFixed(2));
  }

  /// Returns the base fee for a zone (without weight component).
  static double baseForZone(String zone) {
    return _zoneFees[zone]?.base ?? 0;
  }

  /// Returns the per-kg fee for a zone.
  static double perKgForZone(String zone) {
    return _zoneFees[zone]?.perKg ?? 0;
  }
}

/// Internal helper holding the base and perKg values for a zone.
class _ZoneFee {
  final double base;
  final double perKg;
  const _ZoneFee(this.base, this.perKg);
}
