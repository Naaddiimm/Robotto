import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'shop_theme.dart';

/// Multi-photo upload field. Opens a bottom sheet with Gallery / Camera
/// options. Shows thumbnails in a horizontal list with remove (x) buttons.
/// The first photo is the cover; tap a star to set a photo as cover.
/// Max 5 photos. Validates type (jpg, jpeg, png, webp) and size (max 5 MB).
class PhotoPickerField extends StatefulWidget {
  /// Initial photo paths (existing images in edit mode).
  final List<String> initialPaths;

  /// Called whenever the list of paths changes.
  final ValueChanged<List<String>> onChanged;

  const PhotoPickerField({
    super.key,
    this.initialPaths = const [],
    required this.onChanged,
  });

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  late List<String> _paths;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _paths = List.from(widget.initialPaths);
  }

  void _notifyChanged() {
    widget.onChanged(List.from(_paths));
  }

  // ---------------------------------------------------------------------------
  // Pick from gallery or camera
  // ---------------------------------------------------------------------------

  void _showSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ShopTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    color: ShopTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _sourceOption(
                  icon: Icons.photo_library_outlined,
                  text: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
                const SizedBox(height: 12),
                _sourceOption(
                  icon: Icons.camera_alt_outlined,
                  text: 'Take a Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                const SizedBox(height: 12),
                _sourceOption(
                  icon: Icons.close,
                  text: 'Cancel',
                  isCancel: true,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isCancel ? Colors.transparent : ShopTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancel ? ShopTheme.surfaceHigh : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isCancel ? ShopTheme.secondaryText : ShopTheme.mint,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: isCancel ? ShopTheme.secondaryText : ShopTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    if (_paths.length >= 5) {
      setState(() => _error = 'Maximum 5 photos allowed');
      return;
    }

    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (images.isEmpty) return;
      _addPhotos(images.map((x) => x.path).toList());
    } catch (e) {
      setState(() => _error = 'Failed to pick image: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    if (_paths.length >= 5) {
      setState(() => _error = 'Maximum 5 photos allowed');
      return;
    }

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (photo == null) return;
      _addPhotos([photo.path]);
    } catch (e) {
      setState(() => _error = 'Failed to take photo: $e');
    }
  }

  void _addPhotos(List<String> newPaths) {
    final allowed = ['jpg', 'jpeg', 'png', 'webp'];
    const maxBytes = 5 * 1024 * 1024;
    final valid = <String>[];

    for (final path in newPaths) {
      if (_paths.length + valid.length >= 5) {
        setState(() => _error = 'Maximum 5 photos allowed');
        break;
      }
      final ext = path.split('.').last.toLowerCase();
      if (!allowed.contains(ext)) {
        setState(() => _error = 'Only JPG, PNG and WebP images are allowed');
        continue;
      }
      // Try to check size but don't block if the file isn't accessible yet
      try {
        final file = File(path);
        if (file.existsSync()) {
          final size = file.lengthSync();
          if (size > maxBytes) {
            setState(() => _error = 'Each photo must be at most 5 MB');
            continue;
          }
        }
      } catch (_) {
        // File might not be accessible immediately after picking — skip size check
      }
      valid.add(path);
    }

    if (valid.isNotEmpty) {
      setState(() {
        _paths.addAll(valid);
        _error = null;
      });
      _notifyChanged();
    }
  }

  // ---------------------------------------------------------------------------
  // Remove and reorder
  // ---------------------------------------------------------------------------

  void _removeAt(int index) {
    setState(() {
      _paths.removeAt(index);
      _error = null;
    });
    _notifyChanged();
  }

  void _setCover(int index) {
    if (index == 0) return;
    setState(() {
      final item = _paths.removeAt(index);
      _paths.insert(0, item);
    });
    _notifyChanged();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text('Photos', style: ShopTheme.labelStyle),
        ),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              if (_paths.length < 5)
                GestureDetector(
                  onTap: _showSourceBottomSheet,
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: ShopTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ShopTheme.surfaceHigh),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: ShopTheme.secondaryText,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add photo',
                          style: TextStyle(
                            fontFamily: ShopTheme.fontFamily,
                            fontSize: 11,
                            color: ShopTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Thumbnails
              ...List.generate(_paths.length, (index) {
                final path = _paths[index];
                final file = File(path);
                final exists = file.existsSync();
                return _thumbnail(path, index, exists);
              }),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              _error!,
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.error,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _thumbnail(String path, int index, bool exists) {
    return Container(
      width: 100,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ShopTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          exists
              ? Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, _) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: ShopTheme.secondaryText.withValues(alpha: 0.5),
                    ),
                  ),
                  cacheWidth: 200,
                )
              : Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: ShopTheme.secondaryText.withValues(alpha: 0.5),
                  ),
                ),
          // Gradient overlay for controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cover star
                  GestureDetector(
                    onTap: () => _setCover(index),
                    child: Icon(
                      index == 0 ? Icons.star : Icons.star_border,
                      size: 18,
                      color: index == 0
                          ? ShopTheme.mint
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  // Remove button
                  GestureDetector(
                    onTap: () => _removeAt(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
