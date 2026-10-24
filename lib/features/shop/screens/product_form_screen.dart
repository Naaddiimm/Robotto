import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../core/services/auth_service.dart';
import '../data/models/product.dart';
import '../data/models/product_image.dart';
import '../data/repositories/product_repository.dart';
import '../data/file_storage_service.dart';
import '../validators/product_validators.dart';
import '../widgets/shop_theme.dart';
import '../widgets/shop_text_field.dart';
import '../widgets/photo_picker_field.dart';
import '../widgets/pdf_picker_field.dart';

/// Add and edit form for a product. Same screen for both modes.
/// In edit mode, pass the existing [product] and its [images] to prefill.
class ProductFormScreen extends StatefulWidget {
  /// Existing product for edit mode. Null for add mode.
  final Product? product;

  /// Existing images for edit mode.
  final List<ProductImage>? images;

  const ProductFormScreen({
    super.key,
    this.product,
    this.images,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = ProductRepository();
  final _fileStorage = FileStorageService();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _weightController = TextEditingController();

  late String _selectedCategory;
  late String _selectedLevel;
  List<String> _photoPaths = [];
  String? _manualPath;
  String? _manualName;

  // Track initial values to know which files are new vs existing
  late final List<String> _initialPhotoPaths;
  late final String? _initialManualPath;

  bool _isSaving = false;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final p = widget.product!;
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _brandController.text = p.brand ?? '';
      _priceController.text = p.price.toStringAsFixed(2);
      _stockController.text = p.stock.toString();
      _weightController.text = p.weightKg.toStringAsFixed(2);
      _selectedCategory = p.category;
      _selectedLevel = p.level;
      _manualPath = p.manualPath;
      _manualName = p.manualName;
      _initialPhotoPaths =
          (widget.images ?? []).map((e) => e.path).toList();
      _photoPaths = List.from(_initialPhotoPaths);
      _initialManualPath = p.manualPath;
    } else {
      _selectedCategory = Product.categories.first;
      _selectedLevel = Product.levels.first;
      _initialPhotoPaths = [];
      _initialManualPath = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Dropdowns (bottom sheet style, matching signup_screen.dart)
  // ---------------------------------------------------------------------------

  void _showCategorySheet() {
    _showOptionSheet(
      title: 'Select Category',
      options: Product.categories,
      selected: _selectedCategory,
      onSelected: (value) => setState(() => _selectedCategory = value),
    );
  }

  void _showLevelSheet() {
    _showOptionSheet(
      title: 'Select Level',
      options: Product.levels,
      selected: _selectedLevel,
      onSelected: (value) => setState(() => _selectedLevel = value),
    );
  }

  void _showOptionSheet({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ShopTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: ShopTheme.fontFamily,
                        color: ShopTheme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: options.map((option) {
                          final isSelected = option == selected;
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 16.0),
                              color: isSelected
                                  ? ShopTheme.surface
                                  : Colors.transparent,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontFamily: ShopTheme.fontFamily,
                                      color: isSelected
                                          ? ShopTheme.mint
                                          : ShopTheme.text,
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: ShopTheme.mint),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _saveProduct() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // Validate photos
    final photoError = ProductValidators.validatePhotos(
      _photoPaths.map((p) => File(p)).toList(),
    );
    if (photoError != null) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: ShopTheme.error,
        icon: const Icon(Icons.error_outline,
            color: ShopTheme.background, size: 24),
        messageText: Text(
          photoError,
          style: const TextStyle(
            fontFamily: ShopTheme.fontFamily,
            color: ShopTheme.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    setState(() => _isSaving = true);

    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showErrorFlushbar('You must be logged in to save a product.');
      return;
    }

    final now = DateTime.now().toIso8601String();

    // Track copied files for cleanup on failure
    final copiedPaths = <String>[];
    String? copiedManualPath;

    try {
      // 1. Copy new photos to app storage
      final savedPhotoPaths = <String>[];
      for (int i = 0; i < _photoPaths.length; i++) {
        final path = _photoPaths[i];
        if (_initialPhotoPaths.contains(path)) {
          // Already in app storage — keep as-is
          savedPhotoPaths.add(path);
        } else {
          // New file — copy to app storage
          final newPath =
              await _fileStorage.saveProductImage(File(path));
          copiedPaths.add(newPath);
          savedPhotoPaths.add(newPath);
        }
      }

      // 2. Copy new manual if changed
      String? savedManualPath;
      String? savedManualName;
      if (_manualPath != null && _manualPath != _initialManualPath) {
        savedManualPath =
            await _fileStorage.saveManual(File(_manualPath!));
        copiedManualPath = savedManualPath;
        savedManualName = _manualName;
      } else if (_manualPath != null) {
        // Keep existing manual
        savedManualPath = _manualPath;
        savedManualName = _manualName;
      }

      // 3. Build Product
      final product = Product(
        id: widget.product?.id,
        sellerId: userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        level: _selectedLevel,
        price: double.parse(
            _priceController.text.trim().replaceAll(',', '.')),
        stock: int.parse(_stockController.text.trim()),
        weightKg: double.parse(
            _weightController.text.trim().replaceAll(',', '.')),
        manualPath: savedManualPath,
        manualName: savedManualName,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      // 4. Build ProductImage list
      final images = <ProductImage>[];
      for (int i = 0; i < savedPhotoPaths.length; i++) {
        images.add(ProductImage(
          productId: product.id ?? 0,
          path: savedPhotoPaths[i],
          position: i,
        ));
      }

      // 5. Write to DB
      if (!_isEditMode) {
        await _repo.insert(product, images);
      } else {
        await _repo.update(product, images);
      }

      // 6. Delete old files that were removed or replaced
      for (final oldPath in _initialPhotoPaths) {
        if (!_photoPaths.contains(oldPath)) {
          await _fileStorage.deleteFile(oldPath);
        }
      }
      if (_initialManualPath != null &&
          _initialManualPath != _manualPath) {
        await _fileStorage.deleteFile(_initialManualPath);
      }

      // 7. Success — pop without Flushbar (parent shows the message)
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      // DB write failed — delete copied files to prevent orphans
      for (final path in copiedPaths) {
        await _fileStorage.deleteFile(path);
      }
      if (copiedManualPath != null) {
        await _fileStorage.deleteFile(copiedManualPath);
      }
      if (!mounted) return;
      _showErrorFlushbar(e.toString().replaceAll('Exception: ', ''));
      setState(() => _isSaving = false);
    }
  }

  void _showErrorFlushbar(String message) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: ShopTheme.error,
      icon: const Icon(Icons.error_outline,
          color: ShopTheme.background, size: 24),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: ShopTheme.fontFamily,
          color: ShopTheme.background,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: ShopTheme.screenPadding, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: ShopTheme.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'Edit Product' : 'Add Product',
                    style: ShopTheme.titleStyle,
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      ShopTextField(
                        label: 'Product Name',
                        controller: _nameController,
                        hintText: 'Enter product name',
                        icon: Icons.label_outline,
                        validator: ProductValidators.validateName,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      ShopTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        hintText: 'Describe your product',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        validator: ProductValidators.validateDescription,
                      ),
                      const SizedBox(height: 16),

                      // Category dropdown
                      _buildDropdownField(
                        label: 'Category',
                        value: _selectedCategory,
                        onTap: _showCategorySheet,
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Level dropdown
                      _buildDropdownField(
                        label: 'Level',
                        value: _selectedLevel,
                        onTap: _showLevelSheet,
                        icon: Icons.bar_chart_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Brand (optional)
                      ShopTextField(
                        label: 'Brand (optional)',
                        controller: _brandController,
                        hintText: 'Enter brand name',
                        icon: Icons.business_outlined,
                        validator: ProductValidators.validateBrand,
                      ),
                      const SizedBox(height: 16),

                      // Price
                      ShopTextField(
                        label: 'Price (TND)',
                        controller: _priceController,
                        hintText: '0.00',
                        icon: Icons.attach_money_outlined,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,]')),
                        ],
                        validator: ProductValidators.validatePrice,
                      ),
                      const SizedBox(height: 16),

                      // Stock
                      ShopTextField(
                        label: 'Stock',
                        controller: _stockController,
                        hintText: '0',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: ProductValidators.validateStock,
                      ),
                      const SizedBox(height: 16),

                      // Weight
                      ShopTextField(
                        label: 'Weight (kg)',
                        controller: _weightController,
                        hintText: '0.000',
                        icon: Icons.scale_outlined,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,]')),
                        ],
                        validator: ProductValidators.validateWeightKg,
                      ),
                      const SizedBox(height: 24),

                      // Photos
                      PhotoPickerField(
                        initialPaths: _initialPhotoPaths,
                        onChanged: (paths) => _photoPaths = paths,
                      ),
                      const SizedBox(height: 24),

                      // Manual PDF
                      PdfPickerField(
                        initialPath: _initialManualPath,
                        initialName:
                            _isEditMode ? widget.product?.manualName : null,
                        onChanged: (path, name) {
                          _manualPath = path;
                          _manualName = name;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ShopTheme.mint,
                            foregroundColor: ShopTheme.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveProduct,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: ShopTheme.background,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isEditMode
                                          ? 'Save Changes'
                                          : 'Create Product',
                                      style: TextStyle(
                                        fontFamily: ShopTheme.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(label, style: ShopTheme.labelStyle),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ShopTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: ShopTheme.secondaryText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: ShopTheme.fontFamily,
                      color: ShopTheme.text,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    color: ShopTheme.secondaryText, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
