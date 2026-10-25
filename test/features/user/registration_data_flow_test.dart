import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:robotto/core/services/auth_service.dart';
import 'package:robotto/core/data/repositories/user_repository.dart';
import 'package:robotto/features/user/screens/signup_screen.dart';
import 'package:robotto/features/user/screens/interests_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Registration to User Data Flow — Service & Persistence Layer', () {
    final authService = AuthService();
    final userRepository = UserRepository();

    test('1. Registration persists user in SQLite and initializes active session', () async {
      final email = 'pilot_reg_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
      final userId = await authService.registerUser(
        firstName: 'Sarah',
        lastName: 'Connor',
        email: email,
        password: 'Password123!',
        educationLevel: 'University Student',
      );

      expect(userId, isPositive);

      // Verify session was established immediately on registration
      final currentUserId = await authService.getCurrentUserId();
      expect(currentUserId, equals(userId));

      // Verify complete user object retrieval via getCurrentUser
      final currentUser = await authService.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser!.id, equals(userId));
      expect(currentUser.firstName, equals('Sarah'));
      expect(currentUser.lastName, equals('Connor'));
      expect(currentUser.email, equals(email));
      expect(currentUser.educationLevel, equals('University Student'));
      expect(currentUser.createdAt, isNotNull);
      expect(currentUser.updatedAt, isNotNull);
    });

    test('2. Reusable lookup methods retrieve identical, complete user record', () async {
      final email = 'pilot_lookup_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
      final userId = await authService.registerUser(
        firstName: 'Miles',
        lastName: 'Dyson',
        email: email,
        password: 'Password123!',
        educationLevel: 'Graduate',
      );

      final userById = await authService.getUserById(userId);
      final userByEmail = await authService.getUserByEmail(email);

      expect(userById, isNotNull);
      expect(userByEmail, isNotNull);
      expect(userById!.id, equals(userByEmail!.id));
      expect(userById.email, equals(userByEmail.email));
      expect(userById.firstName, equals('Miles'));
      expect(userById.lastName, equals('Dyson'));
      expect(userById.educationLevel, equals('Graduate'));
    });

    test('3. Onboarding updates (interests, experience & goals) survive and reflect in session', () async {
      final email = 'pilot_onboard_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
      final userId = await authService.registerUser(
        firstName: 'John',
        lastName: 'Connor',
        email: email,
        password: 'Password123!',
        educationLevel: 'Self-taught',
      );

      // Step 1: User selects interests during onboarding
      await userRepository.replaceUserInterests(userId, {'ROS 2', 'Computer Vision', 'Drones'});

      // Step 2: User selects learning goals and experience level
      await userRepository.replaceUserLearningGoals(userId, {'Autonomous Navigation'});
      await userRepository.updateExperienceLevel(userId, 'Intermediate');

      // Verify profile retrieval via getCurrentUser reflects the updated experience level
      final refreshedUser = await authService.getCurrentUser();
      expect(refreshedUser, isNotNull);
      expect(refreshedUser!.experienceLevel, equals('Intermediate'));

      // Verify interests and goals in SQLite
      final interests = await userRepository.getUserInterests(userId);
      final interestNames = interests.map((i) => i.interestName).toSet();
      expect(interestNames, containsAll({'ROS 2', 'Computer Vision', 'Drones'}));

      final goals = await userRepository.getUserLearningGoals(userId);
      final goalNames = goals.map((g) => g.goalName).toSet();
      expect(goalNames, contains('Autonomous Navigation'));
    });

    test('4. Session survival: Data survives simulated app restart', () async {
      final email = 'pilot_restart_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
      final userId = await authService.registerUser(
        firstName: 'Kyle',
        lastName: 'Reese',
        email: email,
        password: 'Password123!',
        educationLevel: 'Secondary School',
      );

      // Simulate app restart by creating brand new service instance
      final freshAuthService = AuthService();
      final freshUserId = await freshAuthService.getCurrentUserId();
      expect(freshUserId, equals(userId));

      final freshUser = await freshAuthService.getCurrentUser();
      expect(freshUser, isNotNull);
      expect(freshUser!.id, equals(userId));
      expect(freshUser.firstName, equals('Kyle'));
      expect(freshUser.email, equals(email));
    });

    test('5. Session isolation & Logout: Session clears and does not leak across accounts', () async {
      final email1 = 'pilot_iso1_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
      final user1Id = await authService.registerUser(
        firstName: 'Alpha',
        lastName: 'One',
        email: email1,
        password: 'Password123!',
        educationLevel: 'Engineering Student',
      );

      expect(await authService.getCurrentUserId(), equals(user1Id));

      // Logout clears session
      await authService.logout();
      expect(await authService.getCurrentUserId(), isNull);
      expect(await authService.getCurrentUser(), isNull);

      // Register second user
      final email2 = 'pilot_iso2_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
      final user2Id = await authService.registerUser(
        firstName: 'Beta',
        lastName: 'Two',
        email: email2,
        password: 'Password123!',
        educationLevel: 'Professional',
      );

      expect(await authService.getCurrentUserId(), equals(user2Id));
      final user2 = await authService.getCurrentUser();
      expect(user2, isNotNull);
      expect(user2!.firstName, equals('Beta'));
      expect(user2.id, equals(user2Id));

      // Sign back into first user
      final loginResult = await authService.loginUser(email: email1, password: 'Password123!');
      expect(loginResult, equals(user1Id));
      expect(await authService.getCurrentUserId(), equals(user1Id));
      final switchedUser = await authService.getCurrentUser();
      expect(switchedUser!.firstName, equals('Alpha'));
    });

    test('6. Error handling: Duplicate registration is rejected and does not corrupt session', () async {
      final email = 'pilot_dup_${DateTime.now().microsecondsSinceEpoch}@robotto.internal';
      final initialId = await authService.registerUser(
        firstName: 'Orig',
        lastName: 'User',
        email: email,
        password: 'Password123!',
        educationLevel: 'Graduate',
      );

      expect(
        () => authService.registerUser(
          firstName: 'Duplicate',
          lastName: 'User',
          email: email,
          password: 'Password123!',
          educationLevel: 'Graduate',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('An account with this email already exists'),
        )),
      );

      // Session remains anchored to initial valid account
      expect(await authService.getCurrentUserId(), equals(initialId));
    });
  });

  group('SignupScreen — UI & Validation Verification', () {
    testWidgets('Validates required fields and email/password formats', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignupScreen(),
        ),
      );

      expect(find.text('Create Your Account'), findsOneWidget);

      final createButton = find.text('Create Account');
      expect(createButton, findsOneWidget);

      // Tap Create Account with empty fields
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pump();

      // Form validation errors
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Enter invalid email and short password
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ada');
      await tester.enterText(fields.at(1), 'Lovelace');
      await tester.enterText(fields.at(2), 'invalid-email');
      await tester.enterText(fields.at(3), '123');

      await tester.tap(createButton);
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('At least 6 characters required'), findsNWidgets(2));
    });

    testWidgets('Password visibility toggle operates as expected', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignupScreen(),
        ),
      );

      final toggleButton = find.byIcon(Icons.visibility_outlined);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
