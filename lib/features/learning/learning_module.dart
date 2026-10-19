// ---------------------------------------------------------------------------
// LearningModule — entry widget for the "Courses" tab in HomeScreen.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
          // ── Robotto branding header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 24),
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

          // ── Cours / Formations tab switcher ─────────────────────────────
          _buildSegmentedSwitch(),
          const SizedBox(height: 8),

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
                ? Border.all(
                    color: LearningTheme.violet.withValues(alpha: 0.5))
                : Border.all(color: Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: LearningTheme.font,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color:
                  isSelected ? LearningTheme.mint : LearningTheme.textSecond,
            ),
          ),
        ),
      ),
    );
  }
}
