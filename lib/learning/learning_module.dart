// ---------------------------------------------------------------------------
// LearningModule — entry widget for the "Courses" tab in HomeScreen.
//
// Mirrors the ShopModule pattern: self-contained, with a segmented switch
// between Cours and Formations. Both are kept in an IndexedStack so their
// state is preserved when switching tabs.
//
// PUBLIC API: none — purely a UI entry point.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'learning_theme.dart';
import 'screens/cours_catalogue_screen.dart';
import 'screens/formation_catalogue_screen.dart';
class LearningModule extends StatefulWidget {
  const LearningModule({super.key});

  @override
  State<LearningModule> createState() => _LearningModuleState();
}

class _LearningModuleState extends State<LearningModule> {
  int _selectedTab = 0; // 0 = Cours, 1 = Formations

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildSegmentedSwitch(),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                CoursCatalogueScreen(),
                FormationCatalogueScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Segmented switch ──────────────────────────────────────────────────────
  Widget _buildSegmentedSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: LearningTheme.screenPadding, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: LearningTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildSegment('Cours', 0),
            _buildSegment('Formations', 1),
          ],
        ),
      ),
    );
  }
  Widget _buildSegment(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? LearningTheme.violet.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: LearningTheme.violet.withValues(alpha: 0.5))
                : Border.all(color: Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: LearningTheme.font,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? LearningTheme.mint : LearningTheme.textSecond,
            ),
          ),
        ),
      ),
    );
  }
}


