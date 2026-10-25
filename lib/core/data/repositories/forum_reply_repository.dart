import '../database_helper.dart';
import '../models/forum_reply.dart';

class ForumReplyRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Creates a new reply for a post.
  Future<int> createReply(ForumReply reply) async {
    final db = await _dbHelper.database;
    return await db.insert('forum_replies', reply.toMap());
  }

  /// Gets all replies for a post ordered chronologically.
  Future<List<ForumReply>> getRepliesByPostId(int postId) async {
    final db = await _dbHelper.database;

    const sql = '''
      SELECT 
        r.*,
        (u.first_name || ' ' || u.last_name) AS author_name,
        u.profile_image_path AS author_avatar_path
      FROM forum_replies r
      JOIN users u ON r.user_id = u.id
      WHERE r.post_id = ?
      ORDER BY r.created_at ASC
    ''';

    final maps = await db.rawQuery(sql, [postId]);
    return maps.map((map) => ForumReply.fromMap(map)).toList();
  }

  /// Deletes a reply if the user is the author.
  Future<int> deleteReply(int replyId, int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'forum_replies',
      where: 'id = ? AND user_id = ?',
      whereArgs: [replyId, userId],
    );
  }
}
