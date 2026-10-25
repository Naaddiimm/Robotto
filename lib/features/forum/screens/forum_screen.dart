import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/data/models/forum_post.dart';
import '../../../core/services/forum_service.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumService _forumService = ForumService();
  final TextEditingController _searchController = TextEditingController();

  List<ForumPost> _posts = [];
  bool _isLoading = true;
  String? _selectedCategory = 'All';
  String _selectedPostType = 'all';
  String _searchQuery = '';

  static const List<String> _categories = [
    'All',
    'Robotics & Automation',
    'Electronics & Embedded Systems',
    'Programming & AI',
    'Mechanical Design & Fabrication',
    'Community & Activities',
  ];

  static const List<Map<String, String>> _postTypes = [
    {'value': 'all', 'label': 'All Types'},
    {'value': 'discussion', 'label': 'Discussions'},
    {'value': 'question', 'label': 'Questions'},
    {'value': 'project', 'label': 'Projects'},
    {'value': 'tutorial', 'label': 'Tutorials'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _forumService.getFeed(
        category: _selectedCategory,
        postType: _selectedPostType,
        searchQuery: _searchQuery,
      );

      if (mounted) {
        setState(() {
          _posts = posts;
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

  Future<void> _handleToggleLike(ForumPost post) async {
    try {
      final isLiked = await _forumService.toggleLike(post.id!);
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          final oldPost = _posts[index];
          final newCount = isLiked
              ? oldPost.likeCount + 1
              : oldPost.likeCount - 1;
          _posts[index] = oldPost.copyWith(
            isLikedByCurrentUser: isLiked,
            likeCount: newCount < 0 ? 0 : newCount,
          );
        }
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

  Future<void> _navigateToCreatePost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      _loadFeed();
    }
  }

  Future<void> _navigateToPostDetail(int postId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(postId: postId)),
    );

    if (result == true) {
      _loadFeed();
    } else {
      // Reload anyway to sync like/reply counts
      _loadFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Robotto branding
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ROBOTT',
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accent, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Bell icon with accent dot
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: TextField(
                controller: _searchController,
                style: AppTheme.bodyBoldStyle,
                decoration: AppTheme.inputDecoration(
                  hintText: 'Search topics, questions, tutorials...',
                  prefixIcon: Icons.search,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppTheme.textSoft,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _loadFeed();
                          },
                        )
                      : null,
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _loadFeed();
                },
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.accent.withValues(alpha: 0.2),
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      fontFamily: AppTheme.font,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? AppTheme.accent : AppTheme.textSoft,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.accent : AppTheme.border,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                        _loadFeed();
                      }
                    },
                  );
                },
              ),
            ),

            // Post Type Segmented Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _postTypes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final type = _postTypes[index];
                  final isSelected = _selectedPostType == type['value'];
                  return ChoiceChip(
                    label: Text(type['label']!),
                    selected: isSelected,
                    selectedColor: AppTheme.surfaceTop,
                    backgroundColor: Colors.transparent,
                    labelStyle: TextStyle(
                      fontFamily: AppTheme.font,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? AppTheme.text : AppTheme.textDisabled,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.border : Colors.transparent,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPostType = type['value']!;
                        });
                        _loadFeed();
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Feed Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    )
                  : RefreshIndicator(
                      color: AppTheme.accent,
                      backgroundColor: AppTheme.surface,
                      onRefresh: _loadFeed,
                      child: _posts.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.surfaceHigh,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.forum_outlined,
                                          size: 48,
                                          color: AppTheme.textSoft,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No discussions found',
                                        style: AppTheme.titleStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 32.0,
                                        ),
                                        child: Text(
                                          'Be the first to start a conversation, ask a robotics question, or share your project!',
                                          textAlign: TextAlign.center,
                                          style: AppTheme.bodyStyle,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accent,
                                          foregroundColor: AppTheme.bg,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.add_comment_rounded,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Start Discussion',
                                          style: AppTheme.buttonStyle,
                                        ),
                                        onPressed: _navigateToCreatePost,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                AppTheme.bottomNavPad,
                              ),
                              itemCount: _posts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final post = _posts[index];
                                return PostCard(
                                  post: post,
                                  onTap: () => _navigateToPostDetail(post.id!),
                                  onLikeToggle: () => _handleToggleLike(post),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Above custom nav bar
        child: FloatingActionButton(
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.bg,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: _navigateToCreatePost,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
