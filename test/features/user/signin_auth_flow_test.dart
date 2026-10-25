import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:robotto/core/services/auth_service.dart';
import 'package:robotto/features/user/screens/signin_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService — Direct Authentication Flow (Without CAPTCHA)', () {
    final authService = AuthService();
    final testEmail = 'pilot_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
    const testPassword = 'SecurePassword123!';

    test('1. Registers a new account successfully via local SQLite', () async {
      final userId = await authService.registerUser(
        firstName: 'Robo',
        lastName: 'Pilot',
        email: testEmail,
        password: testPassword,
        educationLevel: 'Engineering Student',
      );
      expect(userId, isPositive);
    });

    test('2. Fails sign-in with non-existent email', () async {
      expect(
        () => authService.loginUser(
          email: 'nonexistent_${DateTime.now().microsecondsSinceEpoch}@robotto.internal',
          password: testPassword,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid email or password'),
        )),
      );
    });

    test('3. Fails sign-in with wrong password', () async {
      expect(
        () => authService.loginUser(
          email: testEmail,
          password: 'WrongPassword999!',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid email or password'),
        )),
      );
    });

    test('4. Signs in successfully with valid credentials and sets session', () async {
      final loggedInId = await authService.loginUser(
        email: testEmail,
        password: testPassword,
      );
      expect(loggedInId, isPositive);

      final currentUserId = await authService.getCurrentUserId();
      expect(currentUserId, equals(loggedInId));
    });
  });

  group('SignInScreen — UI & Validation Verification', () {
    testWidgets('Validates required fields and email format', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Verify UI elements are present
      expect(find.text('Welcome Back!'), findsOneWidget);
      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);

      // Tap Sign In with empty fields
      await tester.ensureVisible(signInButton);
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Form validation errors
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Enter malformed email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email address'),
        'invalid-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your password'),
        '123',
      );

      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('At least 6 characters required'), findsOneWidget);
    });

    testWidgets('Password visibility toggle operates as expected', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');
      expect(passwordField, findsOneWidget);

      // Find toggle icon button
      final toggleButton = find.byIcon(Icons.visibility_outlined);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
