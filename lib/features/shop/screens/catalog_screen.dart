import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';
import '../widgets/shop_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chips.dart';
import 'product_detail_screen.dart';

/// The "Catalog" view of ShopModule. Searchable, filterable product grid.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _repo = ProductRepository();
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<ProductWithCover> _products = [];
  bool _isLoading = true;

  // Filters
  String _searchQuery = '';
  String _selectedCategory = 'all';
  double? _minPrice;
  double? _maxPrice;
  String _brandFilter = '';
  bool _inStockOnly = false;
  String? _levelFilter;

  // Sort
  String _sort = 'newest';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _repo.getAllWithCover(
      search: _searchQuery,
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      inStockOnly: _inStockOnly ? true : null,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      brand: _brandFilter.isEmpty ? null : _brandFilter,
      level: _levelFilter,
      sort: _sort,
    );
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = value.trim();
      _loadProducts();
    });
  }

  // ---------------------------------------------------------------------------
  // Filter bottom sheet
  // ---------------------------------------------------------------------------

  void _showFilterSheet() {
    double minPrice = _minPrice ?? 0;
    double maxPrice = _maxPrice ?? 100000;
    String brand = _brandFilter;
    bool inStock = _inStockOnly;
    String? level = _levelFilter;

    showModalBottomSheet(
      context: context,
      backgroundColor: ShopTheme.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontFamily: ShopTheme.fontFamily,
                          color: ShopTheme.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Price range
                      Text('Price Range (TND)', style: ShopTheme.labelStyle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                hintText: 'Min',
                                hintStyle: TextStyle(
                                  color: ShopTheme.secondaryText,
                                ),
                                filled: true,
                                fillColor: ShopTheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                color: ShopTheme.text,
                                fontFamily: ShopTheme.fontFamily,
                              ),
                              controller: TextEditingController(
                                text: minPrice == 0
                                    ? ''
                                    : minPrice.toStringAsFixed(0),
                              ),
                              onChanged: (v) {
                                final parsed = double.tryParse(
                                  v.replaceAll(',', '.'),
                                );
                                if (parsed != null) {
                                  setSheetState(() => minPrice = parsed);
                                } else if (v.isEmpty) {
                                  setSheetState(() => minPrice = 0);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                hintText: 'Max',
                                hintStyle: TextStyle(
                                  color: ShopTheme.secondaryText,
                                ),
                                filled: true,
                                fillColor: ShopTheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                color: ShopTheme.text,
                                fontFamily: ShopTheme.fontFamily,
                              ),
                              controller: TextEditingController(
                                text: maxPrice == 100000
                                    ? ''
                                    : maxPrice.toStringAsFixed(0),
                              ),
                              onChanged: (v) {
                                final parsed = double.tryParse(
                                  v.replaceAll(',', '.'),
                                );
                                if (parsed != null) {
                                  setSheetState(() => maxPrice = parsed);
                                } else if (v.isEmpty) {
                                  setSheetState(() => maxPrice = 100000);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Brand
                      Text('Brand', style: ShopTheme.labelStyle),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Filter by brand',
                          hintStyle: TextStyle(color: ShopTheme.secondaryText),
                          filled: true,
                          fillColor: ShopTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color: ShopTheme.text,
                          fontFamily: ShopTheme.fontFamily,
                        ),
                        controller: TextEditingController(text: brand),
                        onChanged: (v) => setSheetState(() => brand = v),
                      ),
                      const SizedBox(height: 20),

                      // Level
                      Text('Level', style: ShopTheme.labelStyle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: Product.levels.map((lvl) {
                          final isSelected = level == lvl;
                          return ChoiceChip(
                            label: Text(lvl),
                            selected: isSelected,
                            onSelected: (selected) {
                              setSheetState(
                                () => level = selected ? lvl : null,
                              );
                            },
                            selectedColor: ShopTheme.violet.withValues(
                              alpha: 0.25,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? ShopTheme.mint
                                  : ShopTheme.secondaryText,
                              fontFamily: ShopTheme.fontFamily,
                            ),
                            backgroundColor: ShopTheme.surface,
                            side: BorderSide(
                              color: isSelected
                                  ? ShopTheme.violet.withValues(alpha: 0.5)
                                  : Colors.transparent,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // In stock only
                      SwitchListTile(
                        title: Text(
                          'In stock only',
                          style: TextStyle(
                            color: ShopTheme.text,
                            fontFamily: ShopTheme.fontFamily,
                          ),
                        ),
                        value: inStock,
                        onChanged: (v) => setSheetState(() => inStock = v),
                        activeThumbColor: ShopTheme.violet,
                      ),
                      const SizedBox(height: 24),

                      // Apply / Reset
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _minPrice = null;
                                  _maxPrice = null;
                                  _brandFilter = '';
                                  _inStockOnly = false;
                                  _levelFilter = null;
                                });
                                Navigator.pop(context);
                                _loadProducts();
                              },
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: ShopTheme.secondaryText,
                                  fontFamily: ShopTheme.fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ShopTheme.mint,
                                foregroundColor: ShopTheme.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _minPrice = minPrice == 0 ? null : minPrice;
                                  _maxPrice = maxPrice == 100000
                                      ? null
                                      : maxPrice;
                                  _brandFilter = brand;
                                  _inStockOnly = inStock;
                                  _levelFilter = level;
                                });
                                Navigator.pop(context);
                                _loadProducts();
                              },
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  fontFamily: ShopTheme.fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Sort
  // ---------------------------------------------------------------------------

  void _showSortSheet() {
    final options = [
      ('newest', 'Newest'),
      ('price_low_high', 'Price: Low to High'),
      ('price_high_low', 'Price: High to Low'),
      ('name_az', 'Name: A to Z'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: ShopTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontFamily: ShopTheme.fontFamily,
                    color: ShopTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map((option) {
                  final isSelected = _sort == option.$1;
                  return InkWell(
                    onTap: () {
                      setState(() => _sort = option.$1);
                      Navigator.pop(context);
                      _loadProducts();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option.$2,
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
                            const Icon(
                              Icons.check_circle,
                              color: ShopTheme.mint,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ShopTheme.screenPadding,
            8,
            ShopTheme.screenPadding,
            8,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextStyle(
              color: ShopTheme.text,
              fontFamily: ShopTheme.fontFamily,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(color: ShopTheme.secondaryText),
              prefixIcon: Icon(
                Icons.search,
                color: ShopTheme.secondaryText,
                size: 20,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter
                  IconButton(
                    icon: Icon(
                      Icons.filter_list_outlined,
                      color: ShopTheme.secondaryText,
                      size: 20,
                    ),
                    onPressed: _showFilterSheet,
                  ),
                  // Sort
                  IconButton(
                    icon: Icon(
                      Icons.sort_outlined,
                      color: ShopTheme.secondaryText,
                      size: 20,
                    ),
                    onPressed: _showSortSheet,
                  ),
                ],
              ),
              filled: true,
              fillColor: ShopTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Category chips
        CategoryChips(
          selected: _selectedCategory,
          onSelected: (value) {
            setState(() => _selectedCategory = value);
            _loadProducts();
          },
        ),
        const SizedBox(height: 8),
        // Grid
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: ShopTheme.mint),
                )
              : _products.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    ShopTheme.screenPadding,
                    4,
                    ShopTheme.screenPadding,
                    ShopTheme.bottomNavPadding,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final item = _products[index];
                    return ProductCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: item.product.id!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 56,
            color: ShopTheme.secondaryText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: ShopTheme.headingStyle.copyWith(
              color: ShopTheme.secondaryText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters.',
            style: ShopTheme.bodyStyle,
          ),
        ],
      ),
    );
  }
}
