class ForumPost {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final String category;
  final String postType; // 'question', 'project', 'tutorial', 'discussion'
  final String createdAt;
  final String updatedAt;

  // Joined fields for display
  final String? authorName;
  final String? authorAvatarPath;
  final int replyCount;
  final int likeCount;
  final bool isLikedByCurrentUser;

  ForumPost({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.postType = 'discussion',
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarPath,
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
      'post_type': postType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      postType: map['post_type'] as String? ?? 'discussion',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      authorName: map['author_name'] as String?,
      authorAvatarPath: map['author_avatar_path'] as String?,
      replyCount: map['reply_count'] is int
          ? map['reply_count'] as int
          : (int.tryParse(map['reply_count']?.toString() ?? '0') ?? 0),
      likeCount: map['like_count'] is int
          ? map['like_count'] as int
          : (int.tryParse(map['like_count']?.toString() ?? '0') ?? 0),
      isLikedByCurrentUser: map['is_liked'] == 1 || map['is_liked'] == true,
    );
  }

  ForumPost copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? category,
    String? postType,
    String? createdAt,
    String? updatedAt,
    String? authorName,
    String? authorAvatarPath,
    int? replyCount,
    int? likeCount,
    bool? isLikedByCurrentUser,
  }) {
    return ForumPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorAvatarPath: authorAvatarPath ?? this.authorAvatarPath,
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}
