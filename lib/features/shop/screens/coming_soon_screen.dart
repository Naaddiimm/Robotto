import 'package:flutter/material.dart';

import '../widgets/shop_theme.dart';

/// Placeholder screen shown for shop sections that are not yet implemented.
/// Takes a [title] to display which section is coming soon.
class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ShopTheme.surface,
                    border: Border.all(
                      color: ShopTheme.violet.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_outlined,
                    size: 36,
                    color: ShopTheme.violet,
                  ),
                ),
                const SizedBox(height: 24),
                Text(title, style: ShopTheme.headingStyle),
                const SizedBox(height: 12),
                Text(
                  'This section is coming soon. We are working hard to bring it to you.',
                  textAlign: TextAlign.center,
                  style: ShopTheme.bodyStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
