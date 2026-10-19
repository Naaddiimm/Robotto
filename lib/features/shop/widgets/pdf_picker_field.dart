import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'shop_theme.dart';

/// PDF manual upload field. Uses file_picker with FileType.custom and
/// allowedExtensions ['pdf']. Shows file name and size with Replace and
/// remove actions. Validates .pdf, max 10 MB, not empty. Optional field.
class PdfPickerField extends StatefulWidget {
  /// Initial file path (existing manual in edit mode).
  final String? initialPath;

  /// Initial file name (existing manual in edit mode).
  final String? initialName;

  /// Called whenever the value changes. path and name are null when removed.
  final void Function(String? path, String? name) onChanged;

  const PdfPickerField({
    super.key,
    this.initialPath,
    this.initialName,
    required this.onChanged,
  });

  @override
  State<PdfPickerField> createState() => _PdfPickerFieldState();
}

class _PdfPickerFieldState extends State<PdfPickerField> {
  String? _path;
  String? _name;
  int? _sizeBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
    _name = widget.initialName;
    if (_path != null) {
      final file = File(_path!);
      if (file.existsSync()) {
        _sizeBytes = file.lengthSync();
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      final filePath = picked.path;
      if (filePath == null) {
        setState(() => _error = 'Could not access the file');
        return;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        setState(() => _error = 'The selected file could not be found');
        return;
      }

      // Validate extension
      final ext = filePath.split('.').last.toLowerCase();
      if (ext != 'pdf') {
        setState(() => _error = 'Only PDF files are allowed');
        return;
      }

      // Validate size
      final size = file.lengthSync();
      if (size == 0) {
        setState(() => _error = 'The file is empty');
        return;
      }
      if (size > 10 * 1024 * 1024) {
        setState(() => _error = 'The manual must be at most 10 MB');
        return;
      }

      setState(() {
        _path = filePath;
        _name = picked.name;
        _sizeBytes = size;
        _error = null;
      });
      widget.onChanged(_path, _name);
    } catch (e) {
      setState(() => _error = 'Failed to pick file: $e');
    }
  }

  void _removeFile() {
    setState(() {
      _path = null;
      _name = null;
      _sizeBytes = null;
      _error = null;
    });
    widget.onChanged(null, null);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            'User Manual (PDF) — Optional',
            style: ShopTheme.labelStyle,
          ),
        ),
        if (_path != null && _name != null)
          _fileChip()
        else
          _uploadButton(),
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

  Widget _uploadButton() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: ShopTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ShopTheme.surfaceHigh),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file_outlined,
              color: ShopTheme.secondaryText,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Upload user manual (PDF)',
              style: TextStyle(
                fontFamily: ShopTheme.fontFamily,
                color: ShopTheme.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileChip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: ShopTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ShopTheme.violet.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            color: ShopTheme.violet,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    color: ShopTheme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_sizeBytes != null)
                  Text(
                    _formatSize(_sizeBytes!),
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      color: ShopTheme.secondaryText,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Replace
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ShopTheme.violet.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Replace',
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  color: ShopTheme.violet,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Remove
          GestureDetector(
            onTap: _removeFile,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ShopTheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: ShopTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
