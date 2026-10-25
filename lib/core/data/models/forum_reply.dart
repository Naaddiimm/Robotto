class ForumReply {
  final int? id;
  final int postId;
  final int userId;
  final String content;
  final String createdAt;
  final String updatedAt;

  // Joined fields
  final String? authorName;
  final String? authorAvatarPath;

  ForumReply({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarPath,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ForumReply.fromMap(Map<String, dynamic> map) {
    return ForumReply(
      id: map['id'] as int?,
      postId: map['post_id'] as int,
      userId: map['user_id'] as int,
      content: map['content'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      authorName: map['author_name'] as String?,
      authorAvatarPath: map['author_avatar_path'] as String?,
    );
  }
}
