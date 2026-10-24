import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/data/location_service.dart';
import 'package:robotto/features/shop/widgets/address_field_with_map.dart';
import 'helpers/fake_location_service.dart';

/// Builds the widget under test inside a minimal app with Material support.
Widget _buildWidget({
  required TextEditingController controller,
  TextEditingController? cityController,
  ValueChanged<String>? onSuggestedZone,
  String deliveryMode = 'home',
  required LocationService locationService,
  Future<PickedAddress?> Function(BuildContext)? pickerOverride,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(
        child: AddressFieldWithMap(
          controller: controller,
          cityController: cityController,
          onSuggestedZone: onSuggestedZone,
          deliveryMode: deliveryMode,
          locationServiceOverride: locationService,
          pickerOverride: pickerOverride,
        ),
      ),
    ),
  );
}

void main() {
  late FakeLocationService fake;
  late TextEditingController addressCtl;
  late TextEditingController cityCtl;

  setUp(() {
    fake = FakeLocationService();
    addressCtl = TextEditingController();
    cityCtl = TextEditingController();
  });

  tearDown(() {
    addressCtl.dispose();
    cityCtl.dispose();
  });

  // ---------------------------------------------------------------------------
  // Dialog appears on first tap
  // ---------------------------------------------------------------------------

  testWidgets('tapping map icon shows the GPS dialog', (tester) async {
    await tester.pumpWidget(_buildWidget(
      controller: addressCtl,
      locationService: fake,
    ));
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Yes, use GPS'), findsOneWidget);
    expect(find.text('Type manually'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // "Type manually" path
  // ---------------------------------------------------------------------------

  testWidgets('Type manually closes dialog and no second dialog on next tap', (tester) async {
    await tester.pumpWidget(_buildWidget(
      controller: addressCtl,
      locationService: fake,
    ));
    // Open dialog
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    // Choose manual
    await tester.tap(find.text('Type manually'));
    await tester.pumpAndSettle();
    expect(find.text('Yes, use GPS'), findsNothing);

    // Tapping map icon again should go directly to GPS flow, not show dialog
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    // Dialog should NOT re-appear
    expect(find.text('Type manually'), findsNothing);
  });

  testWidgets('Type manually — field is still editable', (tester) async {
    await tester.pumpWidget(_buildWidget(
      controller: addressCtl,
      locationService: fake,
    ));
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Type manually'));
    await tester.pumpAndSettle();
    // Field should accept text input
    await tester.enterText(find.byType(TextFormField), '123 Manual Street');
    expect(addressCtl.text, '123 Manual Street');
  });

  // ---------------------------------------------------------------------------
  // "Yes, use GPS" → fills address, city, zone
  // ---------------------------------------------------------------------------

  testWidgets('Yes, use GPS → fills address and city via picker', (tester) async {
    String? suggestedZone;
    final pickerResult = PickedAddress(
      address: '5 Avenue Habib Bourguiba, Tunis',
      city: 'Tunis',
      governorate: 'Tunis',
    );

    await tester.pumpWidget(_buildWidget(
      controller: addressCtl,
      cityController: cityCtl,
      onSuggestedZone: (z) => suggestedZone = z,
      locationService: fake,
      pickerOverride: (_) async => pickerResult,
    ));

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, use GPS'));
    await tester.pumpAndSettle();

    expect(addressCtl.text, '5 Avenue Habib Bourguiba, Tunis');
    expect(cityCtl.text, 'Tunis');
    expect(suggestedZone, 'grand_tunis');
  });

  // ---------------------------------------------------------------------------
  // Cancel in picker
  // ---------------------------------------------------------------------------

  testWidgets('Cancel in picker → nothing changes', (tester) async {
    addressCtl.text = 'Existing value';
    await tester.pumpWidget(_buildWidget(
      controller: addressCtl,
      locationService: fake,
      pickerOverride: (_) async => null, // Cancel
    ));

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, use GPS'));
    await tester.pumpAndSettle();

    expect(addressCtl.text, 'Existing value');
  });

  // ---------------------------------------------------------------------------
  // Hidden for store_pickup
  // ---------------------------------------------------------------------------

  testWidgets('hidden for store_pickup (validator returns null)', (tester) async {
    await tester.pumpWidget(_buildWidget(
      controller: addressCtl,
      locationService: fake,
      deliveryMode: 'store_pickup',
    ));
    // The field renders but validator accepts empty for store_pickup
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: AddressFieldWithMap(
            controller: TextEditingController(),
            deliveryMode: 'store_pickup',
            locationServiceOverride: fake,
          ),
        ),
      ),
    ));
    await tester.pump();
    // Validate: empty address for store_pickup → no error (validator returns null)
    expect(formKey.currentState?.validate(), isTrue);
  });
}
