import '../database_helper.dart';
import '../models/forum_post.dart';

class ForumPostRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Creates a new post and returns the generated post ID.
  Future<int> createPost(ForumPost post) async {
    final db = await _dbHelper.database;
    return await db.insert('forum_posts', post.toMap());
  }

  /// Retrieves posts with author info, reply count, like count, and whether current user liked it.
  Future<List<ForumPost>> getPosts({
    String? category,
    String? postType,
    String? searchQuery,
    int? currentUserId,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _dbHelper.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    // Placeholder parameter for currentUserId in is_liked subquery
    final currentUserIdArg = currentUserId ?? -1;

    if (category != null && category.isNotEmpty && category != 'All') {
      whereClauses.add('p.category = ?');
      whereArgs.add(category);
    }

    if (postType != null && postType.isNotEmpty && postType != 'all') {
      whereClauses.add('p.post_type = ?');
      whereArgs.add(postType.toLowerCase());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(p.title LIKE ? OR p.content LIKE ?)');
      final term = '%${searchQuery.trim()}%';
      whereArgs.add(term);
      whereArgs.add(term);
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final sql =
        '''
      SELECT 
        p.*,
        (u.first_name || ' ' || u.last_name) AS author_name,
        u.profile_image_path AS author_avatar_path,
        (SELECT COUNT(*) FROM forum_replies r WHERE r.post_id = p.id) AS reply_count,
        (SELECT COUNT(*) FROM forum_likes l WHERE l.post_id = p.id) AS like_count,
        (CASE WHEN EXISTS(SELECT 1 FROM forum_likes l2 WHERE l2.post_id = p.id AND l2.user_id = ?) THEN 1 ELSE 0 END) AS is_liked
      FROM forum_posts p
      JOIN users u ON p.user_id = u.id
      $whereString
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    ''';

    final queryArgs = [currentUserIdArg, ...whereArgs, limit, offset];
    final maps = await db.rawQuery(sql, queryArgs);

    return maps.map((map) => ForumPost.fromMap(map)).toList();
  }

  /// Retrieves a single post by ID with full author and metadata.
  Future<ForumPost?> getPostById(int postId, {int? currentUserId}) async {
    final db = await _dbHelper.database;
    final currentUserIdArg = currentUserId ?? -1;

    final sql = '''
      SELECT 
        p.*,
        (u.first_name || ' ' || u.last_name) AS author_name,
        u.profile_image_path AS author_avatar_path,
        (SELECT COUNT(*) FROM forum_replies r WHERE r.post_id = p.id) AS reply_count,
        (SELECT COUNT(*) FROM forum_likes l WHERE l.post_id = p.id) AS like_count,
        (CASE WHEN EXISTS(SELECT 1 FROM forum_likes l2 WHERE l2.post_id = p.id AND l2.user_id = ?) THEN 1 ELSE 0 END) AS is_liked
      FROM forum_posts p
      JOIN users u ON p.user_id = u.id
      WHERE p.id = ?
    ''';

    final maps = await db.rawQuery(sql, [currentUserIdArg, postId]);
    if (maps.isNotEmpty) {
      return ForumPost.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing post if the user is the author.
  Future<int> updatePost(ForumPost post, int userId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'forum_posts',
      {
        'title': post.title,
        'content': post.content,
        'category': post.category,
        'post_type': post.postType,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [post.id, userId],
    );
  }

  /// Deletes a post if the user is the author.
  Future<int> deletePost(int postId, int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'forum_posts',
      where: 'id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );
  }
}
