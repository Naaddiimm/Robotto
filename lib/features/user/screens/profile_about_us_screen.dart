import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProfileAboutUsScreen extends StatelessWidget {
  const ProfileAboutUsScreen({super.key});

  // Cybernetic Orbit Colors
  static const Color bgColor = AppTheme.bg;
  static const Color surfaceHigh = AppTheme.surfaceHigh;
  static const Color surface = AppTheme.surface;
  static const Color primaryMint = AppTheme.accent;
  static const Color mainText = AppTheme.text;
  static const Color secondaryText = AppTheme.textSoft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: mainText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "About Us",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainText,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: primaryMint.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 80,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.smart_toy,
                                color: primaryMint,
                                size: 48,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      "ROBOTTO",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: mainText,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Version 1.0.0",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryMint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      "ROBOTTO connects robotics enthusiasts, makers, students, and engineers through learning, collaboration, projects, events, and robotics components.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        color: secondaryText,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
