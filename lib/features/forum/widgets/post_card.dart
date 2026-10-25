import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/models/forum_post.dart';

class PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLikeToggle,
  });

  String _formatRelativeTime(String isoDateStr) {
    try {
      final dateTime = DateTime.parse(isoDateStr);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return isoDateStr;
    }
  }

  Color _getPostTypeColor(String postType) {
    switch (postType.toLowerCase()) {
      case 'question':
        return const Color(0xFFFFB830); // Warning / Yellow
      case 'project':
        return AppTheme.accent; // Mint
      case 'tutorial':
        return const Color(0xFF3B8EEA); // Info / Blue
      case 'discussion':
      default:
        return const Color(0xFFA855F7); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final postTypeColor = _getPostTypeColor(post.postType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(withBorder: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author & Time Header
            Row(
              children: [
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceHigh,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: ClipOval(
                    child:
                        post.authorAvatarPath != null &&
                            post.authorAvatarPath!.isNotEmpty &&
                            File(post.authorAvatarPath!).existsSync()
                        ? Image.file(
                            File(post.authorAvatarPath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person_outline,
                            color: AppTheme.textSoft,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName ?? 'Robotics Member',
                        style: AppTheme.bodyBoldStyle.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatRelativeTime(post.createdAt),
                        style: AppTheme.captionStyle.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Post Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: postTypeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: postTypeColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    post.postType.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTheme.font,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: postTypeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              post.title,
              style: AppTheme.subtitleStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Content Preview
            Text(
              post.content,
              style: AppTheme.bodyStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Category tag and Stats Footer
            Row(
              children: [
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: AppTheme.neutralChipDecoration(),
                  child: Text(
                    post.category,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.text,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),

                // Reply Count
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: AppTheme.textSoft,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.replyCount}', style: AppTheme.captionStyle),
                  ],
                ),
                const SizedBox(width: 16),

                // Like Button & Count
                GestureDetector(
                  onTap: onLikeToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: post.isLikedByCurrentUser
                            ? AppTheme.accent
                            : AppTheme.textSoft,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: AppTheme.captionStyle.copyWith(
                          color: post.isLikedByCurrentUser
                              ? AppTheme.accent
                              : AppTheme.textSoft,
                          fontWeight: post.isLikedByCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
