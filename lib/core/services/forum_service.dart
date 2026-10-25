import 'package:flutter/foundation.dart' show debugPrint;
import '../data/models/forum_post.dart';
import '../data/models/forum_reply.dart';
import '../data/repositories/forum_post_repository.dart';
import '../data/repositories/forum_reply_repository.dart';
import '../data/repositories/forum_like_repository.dart';
import 'auth_service.dart';
import 'forum_notification_client.dart';

class ForumService {
  final ForumPostRepository _postRepo = ForumPostRepository();
  final ForumReplyRepository _replyRepo = ForumReplyRepository();
  final ForumLikeRepository _likeRepo = ForumLikeRepository();
  final AuthService _authService = AuthService();

  /// Fetches the feed with filters.
  Future<List<ForumPost>> getFeed({
    String? category,
    String? postType,
    String? searchQuery,
  }) async {
    final currentUserId = await _authService.getCurrentUserId();
    return await _postRepo.getPosts(
      category: category,
      postType: postType,
      searchQuery: searchQuery,
      currentUserId: currentUserId,
    );
  }

  /// Creates a publication for the authenticated user.
  Future<int> createPost({
    required String title,
    required String content,
    required String category,
    required String postType,
  }) async {
    final currentUserId = await _authService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('You must be logged in to create a publication.');
    }

    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception('Title cannot be empty.');
    }
    if (trimmedTitle.length > 120) {
      throw Exception('Title cannot exceed 120 characters.');
    }
    if (trimmedContent.isEmpty) {
      throw Exception('Content cannot be empty.');
    }
    if (trimmedContent.length > 10000) {
      throw Exception('Content cannot exceed 10,000 characters.');
    }

    const validTypes = ['question', 'project', 'tutorial', 'discussion'];
    final normalizedType = postType.toLowerCase();
    if (!validTypes.contains(normalizedType)) {
      throw Exception('Invalid publication type.');
    }

    final now = DateTime.now().toIso8601String();
    final post = ForumPost(
      userId: currentUserId,
      title: trimmedTitle,
      content: trimmedContent,
      category: category,
      postType: normalizedType,
      createdAt: now,
      updatedAt: now,
    );

    return await _postRepo.createPost(post);
  }

  /// Retrieves a single post with author, counts, and liked status.
  Future<ForumPost?> getPostDetails(int postId) async {
    final currentUserId = await _authService.getCurrentUserId();
    return await _postRepo.getPostById(postId, currentUserId: currentUserId);
  }

  /// Toggles like status for a post.
  Future<bool> toggleLike(int postId) async {
    final currentUserId = await _authService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('You must be logged in to like a publication.');
    }
    return await _likeRepo.toggleLike(postId, currentUserId);
  }

  /// Deletes a post if current user is author.
  Future<bool> deletePost(int postId) async {
    final currentUserId = await _authService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('You must be logged in to delete a publication.');
    }
    final deletedCount = await _postRepo.deletePost(postId, currentUserId);
    return deletedCount > 0;
  }

  /// Updates a post if the authenticated user is the author.
  Future<bool> updatePost({
    required int postId,
    required String title,
    required String content,
    required String category,
    required String postType,
  }) async {
    final currentUserId = await _authService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('You must be logged in to update a publication.');
    }

    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception('Title cannot be empty.');
    }
    if (trimmedTitle.length > 120) {
      throw Exception('Title cannot exceed 120 characters.');
    }
    if (trimmedContent.isEmpty) {
      throw Exception('Content cannot be empty.');
    }
    if (trimmedContent.length > 10000) {
      throw Exception('Content cannot exceed 10,000 characters.');
    }

    const validTypes = ['question', 'project', 'tutorial', 'discussion'];
    final normalizedType = postType.toLowerCase();
    if (!validTypes.contains(normalizedType)) {
      throw Exception('Invalid publication type.');
    }

    final now = DateTime.now().toIso8601String();
    final updatedPost = ForumPost(
      id: postId,
      userId: currentUserId,
      title: trimmedTitle,
      content: trimmedContent,
      category: category,
      postType: normalizedType,
      createdAt: now,
      updatedAt: now,
    );

    final count = await _postRepo.updatePost(updatedPost, currentUserId);
    return count > 0;
  }

  /// Gets replies for a post.
  Future<List<ForumReply>> getReplies(int postId) async {
    return await _replyRepo.getRepliesByPostId(postId);
  }

  /// Adds a reply to a post for the current user.
  Future<int> addReply({required int postId, required String content}) async {
    final currentUserId = await _authService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('You must be logged in to reply.');
    }

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw Exception('Reply cannot be empty.');
    }
    if (trimmed.length > 2000) {
      throw Exception('Reply cannot exceed 2,000 characters.');
    }

    final now = DateTime.now().toIso8601String();
    final reply = ForumReply(
      postId: postId,
      userId: currentUserId,
      content: trimmed,
      createdAt: now,
      updatedAt: now,
    );

    final replyId = await _replyRepo.createReply(reply);

    // --- NOTIFICATION LOGIC ---
    try {
      final post = await _postRepo.getPostById(postId, currentUserId: currentUserId);
      if (post != null && post.userId != currentUserId) {
        // Different user replying to the post.
        final author = await _authService.getUserById(post.userId);
        final replier = await _authService.getUserById(currentUserId);

        if (author != null && author.email.isNotEmpty && replier != null) {
          String preview = trimmed;
          if (preview.length > 200) {
            preview = '${preview.substring(0, 197)}...';
          }
          await ForumNotificationClient.sendReplyNotification(
            recipientEmail: author.email,
            recipientFirstName: author.firstName,
            postTitle: post.title,
            replyAuthorName: '${replier.firstName} ${replier.lastName}'.trim(),
            replyPreview: preview,
          );
        }
      }
    } catch (e) {
      // Do not undo the saved reply if email delivery fails.
      debugPrint('Forum notification failure: $e');
    }

    return replyId;
  }

  /// Deletes a reply if current user is author.
  Future<bool> deleteReply(int replyId) async {
    final currentUserId = await _authService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('You must be logged in to delete a reply.');
    }
    final count = await _replyRepo.deleteReply(replyId, currentUserId);
    return count > 0;
  }

  /// Helper to get current user ID for UI comparison
  Future<int?> getCurrentUserId() => _authService.getCurrentUserId();
}
