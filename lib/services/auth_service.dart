import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user.dart';

class AuthService {
  final UserRepository _userRepository = UserRepository();

  /// Hashes a password using SHA-256 with a salt (a basic PBKDF2 substitute using crypto since pointycastle is heavy)
  /// Note: In a production app with specific requirements, use proper PBKDF2 or Argon2id package.
  /// Here we use multiple iterations of SHA-256 to simulate key stretching.
  Map<String, String> _hashPassword(String password, {String? existingSalt}) {
    final salt = existingSalt ?? _generateSalt();
    const iterations = 10000;
    
    // Initial hash
    var bytes = utf8.encode(password + salt);
    var digest = sha256.convert(bytes);
    
    // Stretch
    for (int i = 0; i < iterations - 1; i++) {
      digest = sha256.convert(digest.bytes);
    }

    return {
      'hash': digest.toString(),
      'salt': salt,
      'algorithm': 'sha256_10k',
    };
  }

  String _generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Normalizes an email address.
  String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Attempts to register a new user. Returns the created user ID or throws an Exception.
  Future<int> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String educationLevel,
  }) async {
    final normalizedEmail = normalizeEmail(email);

    // 1. Check uniqueness
    final exists = await _userRepository.emailExists(normalizedEmail);
    if (exists) {
      throw Exception('An account with this email already exists.');
    }

    // 2. Hash password
    final hashResult = _hashPassword(password);
    
    // 3. Prepare User object
    final now = DateTime.now().toIso8601String();
    final user = User(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normalizedEmail,
      educationLevel: educationLevel,
      createdAt: now,
      updatedAt: now,
    );

    // 4. Insert User
    try {
      final userId = await _userRepository.createUser(user);
      
      // 5. Insert Credentials
      await _userRepository.saveUserCredentials(
        userId, 
        hashResult['hash']!, 
        hashResult['salt']!, 
        hashResult['algorithm']!
      );
      
      return userId;
    } catch (e) {
      throw Exception('Database constraint violation or internal error.');
    }
  }

  /// Attempts to log in a user. Returns the user ID or throws an Exception.
  Future<int> loginUser({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);

    // 1. Get user by email
    final user = await _userRepository.getUserByEmail(normalizedEmail);
    if (user == null || user.id == null) {
      throw Exception('Invalid email or password.');
    }

    // 2. Get stored credentials for this user
    final credentials = await _userRepository.getUserCredentials(user.id!);
    if (credentials == null) {
      throw Exception('Invalid email or password.');
    }

    final dbHash = credentials['password_hash'] as String;
    final salt = credentials['salt'] as String;

    // 3. Hash the provided password with the DB salt
    final hashResult = _hashPassword(password, existingSalt: salt);
    
    // 4. Compare the hashes securely
    if (hashResult['hash'] != dbHash) {
      throw Exception('Invalid email or password.');
    }

    // Login successful
    await _saveSession(user.id!);
    return user.id!;
  }

  /// Changes the user's password. Throws an Exception if the old password is incorrect.
  Future<void> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    // 1. Get stored credentials for this user
    final credentials = await _userRepository.getUserCredentials(userId);
    if (credentials == null) {
      throw Exception('User credentials not found.');
    }

    final dbHash = credentials['password_hash'] as String;
    final oldSalt = credentials['salt'] as String;

    // 2. Hash the provided old password with the DB salt
    final oldHashResult = _hashPassword(oldPassword, existingSalt: oldSalt);
    
    // 3. Compare the hashes securely
    if (oldHashResult['hash'] != dbHash) {
      throw Exception('Incorrect current password.');
    }

    // 4. Hash the new password with a NEW salt
    final newHashResult = _hashPassword(newPassword);

    // 5. Update credentials in DB
    await _userRepository.updateUserCredentials(
      userId,
      newHashResult['hash']!,
      newHashResult['salt']!,
      newHashResult['algorithm']!,
    );
  }

  // --- Session Management ---

  static const String _sessionKey = 'session_user_id';

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, userId);
  }

  /// Returns the ID of the currently logged-in user, or null if not logged in.
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionKey);
  }

  /// Logs out the current user by clearing the session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
