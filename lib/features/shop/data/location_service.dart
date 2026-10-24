import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Result of a reverse geocode operation.
class PickedAddress {
  final String address;
  final String? city;
  final String? governorate;
  PickedAddress({required this.address, this.city, this.governorate});
}

/// Result of a getCurrentPosition call.
class PositionResult {
  final double? lat;
  final double? lng;
  final bool success;
  final String? error;
  PositionResult({this.lat, this.lng, this.success = true, this.error});
  PositionResult.failure(this.error)
      : lat = null,
        lng = null,
        success = false;
}

/// Permission status after a request.
enum LocationPermissionResult { granted, denied, deniedForever, serviceDisabled }

/// Abstract interface so tests can inject a fake.
abstract class LocationService {
  Future<bool> isServiceEnabled();
  Future<LocationPermissionResult> checkPermission();
  Future<LocationPermissionResult> requestPermission();
  Future<void> openLocationSettings();
  Future<void> openAppSettings();
  Future<PositionResult> getCurrentPosition({
    Duration timeout = const Duration(seconds: 10),
  });
  Future<PickedAddress?> reverseGeocode(double lat, double lng);
}

/// Real implementation using geolocator + geocoding.
/// Never throws — all failures return typed results.
class LocationServiceImpl implements LocationService {
  final Geocoding _geocoding = Geocoding();
  @override
  Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<LocationPermissionResult> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationPermissionResult.serviceDisabled;
      final permission = await Geolocator.checkPermission();
      return _mapPermission(permission);
    } catch (_) {
      return LocationPermissionResult.denied;
    }
  }

  @override
  Future<LocationPermissionResult> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationPermissionResult.serviceDisabled;
      final permission = await Geolocator.requestPermission();
      return _mapPermission(permission);
    } catch (_) {
      return LocationPermissionResult.denied;
    }
  }

  @override
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {}
  }

  @override
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }

  @override
  Future<PositionResult> getCurrentPosition({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      return PositionResult(lat: position.latitude, lng: position.longitude);
    } catch (e) {
      return PositionResult.failure('Could not get your location.');
    }
  }

  @override
  Future<PickedAddress?> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      return PickedAddress(
        address: _buildAddressFromPlacemark(p),
        city: p.locality ?? p.subAdministrativeArea,
        governorate: p.administrativeArea,
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------

  LocationPermissionResult _mapPermission(LocationPermission p) {
    switch (p) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionResult.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionResult.deniedForever;
      default:
        return LocationPermissionResult.denied;
    }
  }

  String _buildAddressFromPlacemark(Placemark p) {
    final parts = <String>[];
    if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
    if (p.subLocality != null && p.subLocality!.isNotEmpty) {
      if (!parts.contains(p.subLocality)) parts.add(p.subLocality!);
    }
    if (p.locality != null && p.locality!.isNotEmpty) {
      if (!parts.contains(p.locality)) parts.add(p.locality!);
    }
    return parts.join(', ');
  }
}
