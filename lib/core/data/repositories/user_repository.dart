import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../models/user.dart';
import '../models/user_interest.dart';
import '../models/user_learning_goal.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Returns the database, or throws a clear error on unsupported platforms.
  Future<Database> _db() async {
    return await _dbHelper.database;
  }

  // ── User Operations ───────────────────────────────────────────────────────

  Future<int> createUser(User user) async {
    final db = await _db();
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<User?> getUserById(int id) async {
    final db = await _db();
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _db();
    final normalizedEmail = email.trim().toLowerCase();
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await _db();
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await _db();
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updateExperienceLevel(int userId, String experienceLevel) async {
    final db = await _db();
    return await db.update(
      'users',
      {
        'experience_level': experienceLevel,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _db();
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ── Interests Operations ──────────────────────────────────────────────────

  Future<void> replaceUserInterests(
    int userId,
    Set<String> interestNames,
  ) async {
    final db = await _db();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete(
        'user_interests',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final interest in interestNames) {
        await txn.insert('user_interests', {
          'user_id': userId,
          'interest_name': interest,
          'created_at': now,
        });
      }
    });
  }

  Future<List<UserInterest>> getUserInterests(int userId) async {
    final db = await _db();
    final maps = await db.query(
      'user_interests',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => UserInterest.fromMap(map)).toList();
  }

  // ── Learning Goals Operations ─────────────────────────────────────────────

  Future<void> replaceUserLearningGoals(
    int userId,
    Set<String> goalNames,
  ) async {
    final db = await _db();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete(
        'user_learning_goals',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final goal in goalNames) {
        await txn.insert('user_learning_goals', {
          'user_id': userId,
          'goal_name': goal,
          'created_at': now,
        });
      }
    });
  }

  Future<List<UserLearningGoal>> getUserLearningGoals(int userId) async {
    final db = await _db();
    final maps = await db.query(
      'user_learning_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => UserLearningGoal.fromMap(map)).toList();
  }

  // ── Credentials Operations ────────────────────────────────────────────────

  Future<void> saveUserCredentials(
    int userId,
    String passwordHash,
    String salt,
    String algo,
  ) async {
    final db = await _db();
    await db.insert('user_credentials', {
      'user_id': userId,
      'password_hash': passwordHash,
      'salt': salt,
      'algorithm': algo,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUserCredentials(
    int userId,
    String passwordHash,
    String salt,
    String algo,
  ) async {
    final db = await _db();
    await db.update(
      'user_credentials',
      {'password_hash': passwordHash, 'salt': salt, 'algorithm': algo},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getUserCredentials(int userId) async {
    final db = await _db();
    final maps = await db.query(
      'user_credentials',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.isNotEmpty ? maps.first : null;
  }
}
