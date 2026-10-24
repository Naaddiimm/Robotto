import 'package:robotto/features/shop/data/location_service.dart';

/// In-test implementation of LocationService with settable results and counters.
class FakeLocationService implements LocationService {
  // --- Settable outcomes ---
  bool serviceEnabled = true;
  LocationPermissionResult permissionResult = LocationPermissionResult.granted;
  PositionResult positionResult =
      PositionResult(lat: 36.8065, lng: 10.1815);
  PickedAddress? geocodeResult = PickedAddress(
    address: '123 Test Street, Tunis',
    city: 'Tunis',
    governorate: 'Tunis',
  );

  // --- Call counters ---
  int locationSettingsOpened = 0;
  int appSettingsOpened = 0;
  int getCurrentPositionCalled = 0;
  int reverseGeocodeCalled = 0;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermissionResult> checkPermission() async {
    if (!serviceEnabled) return LocationPermissionResult.serviceDisabled;
    return permissionResult;
  }

  @override
  Future<LocationPermissionResult> requestPermission() async {
    if (!serviceEnabled) return LocationPermissionResult.serviceDisabled;
    return permissionResult;
  }

  @override
  Future<void> openLocationSettings() async => locationSettingsOpened++;

  @override
  Future<void> openAppSettings() async => appSettingsOpened++;

  @override
  Future<PositionResult> getCurrentPosition({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    getCurrentPositionCalled++;
    return positionResult;
  }

  @override
  Future<PickedAddress?> reverseGeocode(double lat, double lng) async {
    reverseGeocodeCalled++;
    return geocodeResult;
  }
}
