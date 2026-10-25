import 'dart:io';

import '../data/models/product.dart';

/// Static validation functions for product fields.
/// Each returns `null` if valid, or an error message string if invalid.
class ProductValidators {
  ProductValidators._();

  // ---------------------------------------------------------------------------
  // Text fields
  // ---------------------------------------------------------------------------

  /// Name: required after trim; 3 to 60 characters; at least one letter.
  static String? validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Product name is required';
    if (trimmed.length < 3) return 'Name must be at least 3 characters';
    if (trimmed.length > 60) return 'Name must be at most 60 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return 'Name must contain at least one letter';
    }
    return null;
  }

  /// Description: required; 10 to 500 characters.
  static String? validateDescription(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Description is required';
    if (trimmed.length < 10)
      return 'Description must be at least 10 characters';
    if (trimmed.length > 500)
      return 'Description must be at most 500 characters';
    return null;
  }

  /// Category: required; must be in the allowed list.
  static String? validateCategory(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Category is required';
    if (!Product.categories.contains(trimmed)) {
      return 'Select a valid category';
    }
    return null;
  }

  /// Level: required; must be in the allowed list.
  static String? validateLevel(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Level is required';
    if (!Product.levels.contains(trimmed)) {
      return 'Select a valid level';
    }
    return null;
  }

  /// Brand: optional; if filled, 2 to 40 characters.
  static String? validateBrand(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null; // Optional
    if (trimmed.length < 2) return 'Brand must be at least 2 characters';
    if (trimmed.length > 40) return 'Brand must be at most 40 characters';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Numeric fields
  // ---------------------------------------------------------------------------

  /// Price: required; accepts comma or dot as decimal separator;
  /// greater than 0; at most 2 decimals; at most 100000.
  static String? validatePrice(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Price is required';

    final normalized = trimmed.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return 'Enter a valid price';

    if (parsed <= 0) return 'Price must be greater than 0';
    if (parsed > 100000) return 'Price must be at most 100000';

    // Check decimal places
    final dotIndex = normalized.indexOf('.');
    if (dotIndex != -1 && normalized.length - dotIndex - 1 > 2) {
      return 'Price can have at most 2 decimal places';
    }

    return null;
  }

  /// Stock: required; whole number; 0 to 100000.
  static String? validateStock(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Stock is required';

    final parsed = int.tryParse(trimmed);
    if (parsed == null) return 'Stock must be a whole number';
    if (parsed < 0) return 'Stock cannot be negative';
    if (parsed > 100000) return 'Stock must be at most 100000';

    return null;
  }

  /// Weight (kg): required; numeric; greater than 0; at most 3 decimals; max 500.
  static String? validateWeightKg(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Weight is required';

    final normalized = trimmed.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return 'Enter a valid weight';

    if (parsed <= 0) return 'Weight must be greater than 0';
    if (parsed > 500) return 'Weight must be at most 500 kg';

    // Check decimal places
    final dotIndex = normalized.indexOf('.');
    if (dotIndex != -1 && normalized.length - dotIndex - 1 > 3) {
      return 'Weight can have at most 3 decimal places';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // File fields
  // ---------------------------------------------------------------------------

  /// Photos: 1 to 5; jpg/jpeg/png/webp; max 5 MB each; files must exist.
  static String? validatePhotos(List<File>? photos) {
    if (photos == null || photos.isEmpty) {
      return 'At least one photo is required';
    }
    if (photos.length > 5) {
      return 'Maximum 5 photos allowed';
    }

    const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    const maxSizeBytes = 5 * 1024 * 1024; // 5 MB

    for (final photo in photos) {
      if (!photo.existsSync()) {
        return 'One or more photos could not be found';
      }
      final ext = photo.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(ext)) {
        return 'Only JPG, PNG and WebP images are allowed';
      }
      final size = photo.lengthSync();
      if (size > maxSizeBytes) {
        return 'Each photo must be at most 5 MB';
      }
    }

    return null;
  }

  /// Manual PDF: optional; .pdf only; max 10 MB; not empty.
  static String? validateManual(File? manual) {
    if (manual == null) return null; // Optional

    if (!manual.existsSync()) {
      return 'The selected file could not be found';
    }

    final ext = manual.path.split('.').last.toLowerCase();
    if (ext != 'pdf') {
      return 'Only PDF files are allowed';
    }

    const maxSizeBytes = 10 * 1024 * 1024; // 10 MB
    final size = manual.lengthSync();
    if (size == 0) {
      return 'The file is empty';
    }
    if (size > maxSizeBytes) {
      return 'The manual must be at most 10 MB';
    }

    return null;
  }
}
