import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/location_service.dart';
import '../widgets/shop_theme.dart';

/// Google Map address picker. Shows the user's current position (fallback:
/// Tunis 36.8065, 10.1815). The user taps or drags a marker; a bottom card
/// shows the reverse-geocoded address. "Use this address" returns it.
class AddressPickerScreen extends StatefulWidget {
  final LocationService? locationService;

  const AddressPickerScreen({super.key, this.locationService});

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  late final LocationService _locationService;
  static const _tunis = LatLng(36.8065, 10.1815);

  bool _isLoading = true;
  bool _isGeocoding = false;
  LatLng _center = _tunis;
  Marker? _marker;
  String? _address;
  String? _city;
  String? _governorate;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? LocationServiceImpl();
    _loadLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;
    if (result.success && result.lat != null && result.lng != null) {
      _center = LatLng(result.lat!, result.lng!);
    }
    // Place initial marker and reverse geocode
    _updateMarker(_center);
    setState(() => _isLoading = false);
    _reverseGeocode(_center);
  }

  void _updateMarker(LatLng pos) {
    setState(() {
      _marker = Marker(
        markerId: const MarkerId('picked'),
        position: pos,
        draggable: true,
        onDragEnd: _onMarkerDragEnd,
      );
    });
  }

  void _onMarkerDragEnd(LatLng pos) {
    _reverseGeocode(pos);
  }

  void _onMapTap(LatLng pos) {
    _updateMarker(pos);
    _reverseGeocode(pos);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _isGeocoding = true);
    final result = await _locationService.reverseGeocode(
      pos.latitude,
      pos.longitude,
    );
    if (!mounted) return;
    setState(() {
      _address = result?.address;
      _city = result?.city;
      _governorate = result?.governorate;
      _isGeocoding = false;
    });
  }

  void _useAddress() {
    Navigator.pop(
      context,
      PickedAddress(
        address: _address ?? '',
        city: _city,
        governorate: _governorate,
      ),
    );
  }

  void _recenter() {
    _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: ShopTheme.mint),
                    SizedBox(height: 16),
                    Text(
                      'Finding your location...',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        color: ShopTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15,
                    ),
                    markers: _marker != null ? {_marker!} : {},
                    onTap: _onMapTap,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    compassEnabled: true,
                  ),
                  // Back button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'back',
                      backgroundColor: ShopTheme.surfaceHigh,
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: ShopTheme.text,
                      ),
                    ),
                  ),
                  // My location button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'myloc',
                      backgroundColor: ShopTheme.surfaceHigh,
                      onPressed: _recenter,
                      child: const Icon(
                        Icons.my_location,
                        color: ShopTheme.mint,
                      ),
                    ),
                  ),
                  // Bottom card
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomCard(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShopTheme.surfaceHigh),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isGeocoding)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ShopTheme.mint,
                    ),
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: ShopTheme.mint,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _address != null && _address!.isNotEmpty
                          ? _address!
                          : 'Tap the map to pick a location',
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        fontSize: 14,
                        color: ShopTheme.text,
                      ),
                    ),
                  ),
                ],
              ),
              if (_city != null && _city!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _city!,
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    fontSize: 12,
                    color: ShopTheme.secondaryText,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShopTheme.mint,
                        foregroundColor: ShopTheme.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _address != null && _address!.isNotEmpty
                          ? _useAddress
                          : null,
                      child: const Text(
                        'Use this address',
                        style: TextStyle(
                          fontFamily: ShopTheme.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
