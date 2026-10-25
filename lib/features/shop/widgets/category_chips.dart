import 'package:flutter/material.dart';

import '../data/models/product.dart';
import 'shop_theme.dart';

/// Horizontal scrollable category chips: "All" + the 8 fixed categories.
class CategoryChips extends StatelessWidget {
  /// The currently selected value. Use `'all'` for no category filter.
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chips = ['all', ...Product.categories];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: ShopTheme.screenPadding,
        ),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = chip == selected;
          final label = chip == 'all' ? 'All' : chip;
          return GestureDetector(
            onTap: () => onSelected(chip),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? ShopTheme.violet.withValues(alpha: 0.25)
                    : ShopTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? ShopTheme.violet.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: ShopTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? ShopTheme.mint : ShopTheme.secondaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
