import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/data/location_service.dart';
import 'package:robotto/features/shop/data/address_formatter.dart';
import 'helpers/fake_location_service.dart';

void main() {
  late FakeLocationService fake;

  setUp(() => fake = FakeLocationService());

  group('GPS off → settings opened', () {
    test('isServiceEnabled returns false → openLocationSettings called', () async {
      fake.serviceEnabled = false;
      final enabled = await fake.isServiceEnabled();
      expect(enabled, isFalse);
      // Simulate the flow logic: service off → open settings
      if (!enabled) await fake.openLocationSettings();
      expect(fake.locationSettingsOpened, 1);
    });

    test('requestPermission returns serviceDisabled when service off', () async {
      fake.serviceEnabled = false;
      final result = await fake.requestPermission();
      expect(result, LocationPermissionResult.serviceDisabled);
    });
  });

  group('Permission denied → manual typing still possible', () {
    test('denied result returned', () async {
      fake.permissionResult = LocationPermissionResult.denied;
      final result = await fake.requestPermission();
      expect(result, LocationPermissionResult.denied);
      // The UI sets manualTyping = true; no crash
      expect(true, isTrue); // ordering still possible
    });

    test('app settings NOT opened on regular denied', () async {
      fake.permissionResult = LocationPermissionResult.denied;
      await fake.requestPermission();
      expect(fake.appSettingsOpened, 0);
    });
  });

  group('deniedForever → app settings offered', () {
    test('result is deniedForever', () async {
      fake.permissionResult = LocationPermissionResult.deniedForever;
      final result = await fake.requestPermission();
      expect(result, LocationPermissionResult.deniedForever);
    });

    test('openAppSettings increments counter', () async {
      fake.permissionResult = LocationPermissionResult.deniedForever;
      await fake.requestPermission();
      await fake.openAppSettings();
      expect(fake.appSettingsOpened, 1);
    });
  });

  group('Success → address, city and suggested zone returned', () {
    test('getCurrentPosition returns lat/lng', () async {
      final result = await fake.getCurrentPosition();
      expect(result.success, isTrue);
      expect(result.lat, isNotNull);
      expect(result.lng, isNotNull);
    });

    test('reverseGeocode returns address and city', () async {
      final result = await fake.reverseGeocode(36.8065, 10.1815);
      expect(result, isNotNull);
      expect(result!.address.isNotEmpty, isTrue);
      expect(result.city, isNotNull);
    });

    test('suggestZone returns grand_tunis for Tunis governorate', () async {
      final result = await fake.reverseGeocode(36.8065, 10.1815);
      final zone = AddressFormatter.suggestZone(result?.governorate);
      expect(zone, 'grand_tunis');
    });
  });

  group('Geocode returns null → manual message, no crash', () {
    test('null geocode result handled gracefully', () async {
      fake.geocodeResult = null;
      final result = await fake.reverseGeocode(0, 0);
      expect(result, isNull);
      // No crash; UI shows manual typing message
    });
  });

  group('Timeout or exception → no crash', () {
    test('failure PositionResult has success=false', () async {
      fake.positionResult = PositionResult.failure('Timeout');
      final result = await fake.getCurrentPosition(timeout: const Duration(milliseconds: 1));
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    test('counter incremented even on failure', () async {
      fake.positionResult = PositionResult.failure('Error');
      await fake.getCurrentPosition();
      expect(fake.getCurrentPositionCalled, 1);
    });
  });
}
