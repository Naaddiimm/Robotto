import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/forum_service.dart';
import '../../../core/data/models/forum_post.dart';

class CreatePostScreen extends StatefulWidget {
  final ForumPost? postToEdit;

  const CreatePostScreen({super.key, this.postToEdit});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ForumService _forumService = ForumService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = 'Robotics & Automation';
  String _selectedPostType = 'discussion';
  bool _isPublishing = false;

  static const List<String> _categories = [
    'Robotics & Automation',
    'Electronics & Embedded Systems',
    'Programming & AI',
    'Mechanical Design & Fabrication',
    'Community & Activities',
  ];

  static const List<Map<String, String>> _postTypes = [
    {'value': 'discussion', 'label': 'Discussion'},
    {'value': 'question', 'label': 'Question'},
    {'value': 'project', 'label': 'Project'},
    {'value': 'tutorial', 'label': 'Tutorial'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _titleController.text = widget.postToEdit!.title;
      _contentController.text = widget.postToEdit!.content;
      if (_categories.contains(widget.postToEdit!.category)) {
        _selectedCategory = widget.postToEdit!.category;
      }
      _selectedPostType = widget.postToEdit!.postType.toLowerCase();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      if (widget.postToEdit != null) {
        await _forumService.updatePost(
          postId: widget.postToEdit!.id!,
          title: _titleController.text,
          content: _contentController.text,
          category: _selectedCategory,
          postType: _selectedPostType,
        );
      } else {
        await _forumService.createPost(
          title: _titleController.text,
          content: _contentController.text,
          category: _selectedCategory,
          postType: _selectedPostType,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.postToEdit != null
                  ? 'Publication updated successfully!'
                  : 'Publication created successfully!',
              style: const TextStyle(
                fontFamily: AppTheme.font,
                color: AppTheme.bg,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true); // Return true to trigger feed refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(
                fontFamily: AppTheme.font,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.postToEdit != null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Publication' : 'Create Publication'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Picker
                Text('Category', style: AppTheme.labelStyle),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: AppTheme.surfaceHigh,
                      style: AppTheme.bodyBoldStyle,
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Post Type Segmented Picker
                Text('Publication Type', style: AppTheme.labelStyle),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _postTypes.map((type) {
                    final isSelected = _selectedPostType == type['value'];
                    return ChoiceChip(
                      label: Text(type['label']!),
                      selected: isSelected,
                      selectedColor: AppTheme.accent.withValues(alpha: 0.2),
                      backgroundColor: AppTheme.surfaceHigh,
                      labelStyle: TextStyle(
                        fontFamily: AppTheme.font,
                        fontSize: 13,
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
                            _selectedPostType = type['value']!;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Title Input
                Text('Title', style: AppTheme.labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  maxLength: 120,
                  style: AppTheme.bodyBoldStyle,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'e.g. How to calibrate LiDAR with ROS 2?',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.trim().length > 120) {
                      return 'Title cannot exceed 120 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Content Input
                Text('Content', style: AppTheme.labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  maxLength: 10000,
                  style: AppTheme.bodyStyle.copyWith(color: AppTheme.text),
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Share your questions, project details, code snippets, or tutorials...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter content';
                    }
                    if (value.trim().length > 10000) {
                      return 'Content cannot exceed 10,000 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.buttonRadius,
                        ),
                      ),
                    ),
                    onPressed: _isPublishing ? null : _handlePublish,
                    child: _isPublishing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.bg,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEditing ? 'Save Changes' : 'Publish Post',
                            style: AppTheme.buttonLargeStyle,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
