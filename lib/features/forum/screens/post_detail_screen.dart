import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/data/models/forum_post.dart';
import '../../../core/data/models/forum_reply.dart';
import '../../../core/services/forum_service.dart';
import 'create_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ForumService _forumService = ForumService();
  final TextEditingController _replyController = TextEditingController();

  ForumPost? _post;
  List<ForumReply> _replies = [];
  int? _currentUserId;
  bool _isLoading = true;
  bool _isSubmittingReply = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = await _forumService.getCurrentUserId();
      final post = await _forumService.getPostDetails(widget.postId);
      final replies = await _forumService.getReplies(widget.postId);

      if (mounted) {
        setState(() {
          _currentUserId = currentUserId;
          _post = post;
          _replies = replies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleToggleLike() async {
    if (_post == null) return;

    try {
      final isLiked = await _forumService.toggleLike(_post!.id!);
      setState(() {
        final newCount = isLiked ? _post!.likeCount + 1 : _post!.likeCount - 1;
        _post = _post!.copyWith(
          isLikedByCurrentUser: isLiked,
          likeCount: newCount < 0 ? 0 : newCount,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmittingReply = true;
    });

    try {
      await _forumService.addReply(postId: widget.postId, content: text);
      if (!mounted) return;
      _replyController.clear();
      FocusScope.of(context).unfocus();

      // Reload post details and replies
      final updatedPost = await _forumService.getPostDetails(widget.postId);
      final updatedReplies = await _forumService.getReplies(widget.postId);

      if (mounted) {
        setState(() {
          _post = updatedPost;
          _replies = updatedReplies;
          _isSubmittingReply = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Reply submitted!',
              style: TextStyle(fontFamily: AppTheme.font, color: AppTheme.bg),
            ),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingReply = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleEditPost() async {
    if (_post == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(postToEdit: _post),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _handleDeletePost() async {
    if (_post == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceHigh,
        title: const Text('Delete Publication', style: AppTheme.titleStyle),
        content: const Text(
          'Are you sure you want to delete this publication and all its replies?',
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _forumService.deletePost(_post!.id!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Publication deleted.')));
          Navigator.pop(context, true); // Signal feed refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteReply(int replyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceHigh,
        title: const Text('Delete Reply', style: AppTheme.titleStyle),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _forumService.deleteReply(replyId);
        final updatedPost = await _forumService.getPostDetails(widget.postId);
        final updatedReplies = await _forumService.getReplies(widget.postId);

        if (mounted) {
          setState(() {
            _post = updatedPost;
            _replies = updatedReplies;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  String _formatRelativeTime(String isoDateStr) {
    try {
      final dateTime = DateTime.parse(isoDateStr);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Publication Details'),
        actions: [
          if (_post != null &&
              _currentUserId != null &&
              _post!.userId == _currentUserId) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.accent),
              onPressed: _handleEditPost,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: _handleDeletePost,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          : _post == null
          ? const Center(
              child: Text(
                'Publication not found or has been deleted.',
                style: AppTheme.bodyStyle,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Post Content and Replies Scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author Header
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.surfaceHigh,
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: ClipOval(
                                  child:
                                      _post!.authorAvatarPath != null &&
                                          _post!.authorAvatarPath!.isNotEmpty &&
                                          File(_post!.authorAvatarPath!)
                                              .existsSync()
                                      ? Image.file(
                                          File(_post!.authorAvatarPath!),
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.person_outline,
                                          color: AppTheme.textSoft,
                                          size: 24,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _post!.authorName ?? 'Robotics Member',
                                      style: AppTheme.bodyBoldStyle,
                                    ),
                                    Text(
                                      _formatRelativeTime(_post!.createdAt),
                                      style: AppTheme.captionStyle,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: AppTheme.accentChipDecoration(),
                                child: Text(
                                  _post!.postType.toUpperCase(),
                                  style: AppTheme.captionStyle.copyWith(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: AppTheme.neutralChipDecoration(),
                            child: Text(
                              _post!.category,
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(_post!.title, style: AppTheme.headingStyle),
                          const SizedBox(height: 12),

                          // Content
                          Text(
                            _post!.content,
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.text,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action Bar (Likes & Reply count)
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _handleToggleLike,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: AppTheme.cardDecoration(
                                    color: AppTheme.surfaceHigh,
                                    radius: 20,
                                    withBorder: true,
                                    accentBorder: _post!.isLikedByCurrentUser,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _post!.isLikedByCurrentUser
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _post!.isLikedByCurrentUser
                                            ? AppTheme.accent
                                            : AppTheme.textSoft,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_post!.likeCount}',
                                        style: AppTheme.labelStyle.copyWith(
                                          color: _post!.isLikedByCurrentUser
                                              ? AppTheme.accent
                                              : AppTheme.textSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    color: AppTheme.textSoft,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_post!.replyCount} replies',
                                    style: AppTheme.labelStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Replies Header
                          Text(
                            'Replies (${_replies.length})',
                            style: AppTheme.titleStyle,
                          ),
                          const SizedBox(height: 12),

                          // Replies List
                          if (_replies.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Text(
                                  'No replies yet. Be the first to share your thoughts!',
                                  style: AppTheme.bodyStyle,
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _replies.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final reply = _replies[index];
                                final isReplyAuthor =
                                    _currentUserId != null &&
                                    reply.userId == _currentUserId;

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: AppTheme.cardDecoration(
                                    color: AppTheme.surfaceHigh,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.surfaceTop,
                                            ),
                                            child: ClipOval(
                                              child:
                                                  reply.authorAvatarPath !=
                                                          null &&
                                                      reply
                                                          .authorAvatarPath!
                                                          .isNotEmpty &&
                                                      File(
                                                        reply.authorAvatarPath!,
                                                      ).existsSync()
                                                  ? Image.file(
                                                      File(
                                                        reply.authorAvatarPath!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Icon(
                                                      Icons.person_outline,
                                                      size: 16,
                                                      color: AppTheme.textSoft,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              reply.authorName ?? 'Member',
                                              style: AppTheme.bodyBoldStyle
                                                  .copyWith(fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            _formatRelativeTime(
                                              reply.createdAt,
                                            ),
                                            style: AppTheme.captionStyle
                                                .copyWith(fontSize: 10),
                                          ),
                                          if (isReplyAuthor)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: AppTheme.error,
                                              ),
                                              onPressed: () =>
                                                  _handleDeleteReply(reply.id!),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        reply.content,
                                        style: AppTheme.bodyStyle.copyWith(
                                          color: AppTheme.text,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Reply Composer Input Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      border: Border(top: BorderSide(color: AppTheme.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            maxLength: 2000,
                            maxLines: null,
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.text,
                            ),
                            decoration: AppTheme.inputDecoration(
                              hintText: 'Write a reply...',
                            ).copyWith(counterText: ''),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: AppTheme.bg,
                          ),
                          icon: _isSubmittingReply
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.bg,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 20),
                          onPressed: _isSubmittingReply
                              ? null
                              : _handleSubmitReply,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
