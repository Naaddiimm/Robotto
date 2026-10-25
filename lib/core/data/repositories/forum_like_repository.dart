import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';

class ForumLikeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Toggles like state for a user and post using a transaction.
  /// Returns `true` if the post is now liked, `false` if unliked.
  Future<bool> toggleLike(int postId, int userId) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> existing = await txn.query(
        'forum_likes',
        where: 'post_id = ? AND user_id = ?',
        whereArgs: [postId, userId],
      );

      if (existing.isNotEmpty) {
        // Already liked -> remove
        await txn.delete(
          'forum_likes',
          where: 'post_id = ? AND user_id = ?',
          whereArgs: [postId, userId],
        );
        return false;
      } else {
        // Not liked -> insert
        await txn.insert('forum_likes', {
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        return true;
      }
    });
  }

  /// Checks if a post is liked by a specific user.
  Future<bool> isPostLikedByUser(int postId, int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'forum_likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );
    return result.isNotEmpty;
  }

  /// Gets the total count of likes for a post.
  Future<int> getLikeCount(int postId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM forum_likes WHERE post_id = ?',
      [postId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
