import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../data/location_service.dart';
import '../data/address_formatter.dart';
import '../validators/order_validators.dart';
import 'shop_theme.dart';
import '../screens/address_picker_screen.dart';

/// Reusable address field with a map icon. First tap shows a GPS dialog
/// ("Turn on GPS to find your location?" with "Yes, use GPS" / "Type manually").
/// After "Type manually" the field works as a normal text field for this visit.
/// The map icon can always reopen the picker.
class AddressFieldWithMap extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? cityController;
  final ValueChanged<String>? onSuggestedZone;
  final String deliveryMode;
  final String label;

  /// Optional injection point for tests — replaces LocationServiceImpl.
  final LocationService? locationServiceOverride;

  /// Optional injection point for tests — replaces Navigator.push to AddressPickerScreen.
  /// Called with context; should return a PickedAddress or null.
  final Future<PickedAddress?> Function(BuildContext)? pickerOverride;

  const AddressFieldWithMap({
    super.key,
    required this.controller,
    required this.deliveryMode,
    this.cityController,
    this.onSuggestedZone,
    this.label = 'Address',
    this.locationServiceOverride,
    this.pickerOverride,
  });

  @override
  State<AddressFieldWithMap> createState() => _AddressFieldWithMapState();
}

class _AddressFieldWithMapState extends State<AddressFieldWithMap> {
  late final LocationService _locationService;
  bool _manualTyping = false;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationServiceOverride ?? LocationServiceImpl();
  }

  // ---------------------------------------------------------------------------
  // Map icon tap
  // ---------------------------------------------------------------------------

  void _onMapIconTap() {
    if (_manualTyping) {
      // Already chose manual — go straight to GPS flow
      _startGpsFlow();
    } else {
      _showGpsDialog();
    }
  }

  // ---------------------------------------------------------------------------
  // GPS dialog
  // ---------------------------------------------------------------------------

  void _showGpsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShopTheme.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ShopTheme.surface, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.location_on_outlined, color: ShopTheme.mint),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Turn on GPS to find your location?',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  color: ShopTheme.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Use your phone GPS to fill the address automatically, or type it manually.',
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: ShopTheme.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _manualTyping = true);
            },
            child: const Text(
              'Type manually',
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ShopTheme.mint,
              foregroundColor: ShopTheme.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _startGpsFlow();
            },
            child: const Text(
              'Yes, use GPS',
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

  // ---------------------------------------------------------------------------
  // GPS flow
  // ---------------------------------------------------------------------------

  Future<void> _startGpsFlow() async {
    // 1. Check if location services are on
    final serviceEnabled = await _locationService.isServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      _showFlushbar(
        'Location services are off. Please enable GPS in your settings.',
      );
      await _locationService.openLocationSettings();
      return;
    }

    // 2. Request permission
    final permission = await _locationService.requestPermission();
    if (!mounted) return;
    if (permission == LocationPermissionResult.denied) {
      _showFlushbar('Location permission denied. You can type the address manually.');
      setState(() => _manualTyping = true);
      return;
    }
    if (permission == LocationPermissionResult.deniedForever) {
      _showPermissionDeniedForeverDialog();
      return;
    }

    // 3. Open the map picker
    _openMapPicker();
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShopTheme.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ShopTheme.surface, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.location_off_outlined, color: ShopTheme.error),
            SizedBox(width: 12),
            Text(
              'Permission Required',
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'Location permission was permanently denied. '
          'Please enable it in app settings to use the map.',
          style: TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: ShopTheme.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  color: ShopTheme.secondaryText,
                  fontWeight: FontWeight.bold,
                )),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ShopTheme.mint,
              foregroundColor: ShopTheme.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _locationService.openAppSettings();
            },
            child: const Text('Open App Settings',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker() async {
    PickedAddress? result;
    if (widget.pickerOverride != null) {
      result = await widget.pickerOverride!(context);
    } else {
      result = await Navigator.push<PickedAddress>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddressPickerScreen(locationService: _locationService),
        ),
      );
    }
    if (!mounted) return;
    if (result == null) return;

    widget.controller.text = result.address;
    if (result.city != null && result.city!.isNotEmpty) {
      widget.cityController?.text = result.city!;
    }
    final suggestedZone = AddressFormatter.suggestZone(result.governorate);
    if (suggestedZone != null) {
      widget.onSuggestedZone?.call(suggestedZone);
    }
  }

  void _showFlushbar(String message) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: ShopTheme.violet,
      icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: ShopTheme.fontFamily,
          color: Colors.white,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(widget.label, style: ShopTheme.labelStyle),
        ),
        TextFormField(
          controller: widget.controller,
          style: ShopTheme.bodyMainStyle,
          decoration: ShopTheme.inputDecoration(
            hintText: 'Delivery address',
            suffixIcon: IconButton(
              icon: const Icon(Icons.map_outlined, color: ShopTheme.mint),
              onPressed: _onMapIconTap,
            ),
          ),
          maxLines: 2,
          validator: (value) =>
              OrderValidators.validateAddress(value, widget.deliveryMode),
        ),
      ],
    );
  }
}
