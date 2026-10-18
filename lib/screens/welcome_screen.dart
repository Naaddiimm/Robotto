import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_screen.dart';
import 'signin_screen.dart'; // Import SignInScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Design system tokens based on DESIGN.md
    const Color bgColor = Color(0xFF091422);
    const Color surfaceLow = Color(0xFF111C2B);
    const Color surface = Color(0xFF15202F);
    const Color primaryMint = Color(0xFF85FFDE);
    const Color primaryContainer = Color(0xFF35E6C0);
    const Color mainText = Color(0xFFD8E3F7);
    const Color secondaryText = Color(0xFFBACAC3);
    const Color courseAccent = Color(0xFFF5A623);
    const Color communityAccent = Color(0xFFF472B6);

    // Apply dark status bar style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                
                // 1 & 2. ROBOTTO Logo with subtle mint glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryMint.withValues(alpha: 0.15),
                        blurRadius: 60,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 90,
                      width: 90,
                      decoration: const BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'LOGO\nMISSING',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryMint, 
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 32),

                // 3. Main headline
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: mainText,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: "Your World of Robotics,\n"),
                      TextSpan(
                        text: "Connected.", 
                        style: TextStyle(color: primaryMint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Supporting description
                const Text(
                  "Discover robotic projects, explore components, join exciting events, and learn alongside a community passionate about robotics.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: secondaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // 5. Section label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "EXPLORE FEATURES",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: secondaryText,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Feature cards - Row 1
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.shopping_cart_outlined, 
                        iconColor: primaryMint, 
                        title: 'Components', 
                        subtitle: 'Kits & Parts', 
                        surface: surface, 
                        surfaceLow: surfaceLow, 
                        mainText: mainText, 
                        secondaryText: secondaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.calendar_today, 
                        iconColor: mainText.withValues(alpha: 0.7), 
                        title: 'Events', 
                        subtitle: 'Challenges & Arenas', 
                        surface: surface, 
                        surfaceLow: surfaceLow, 
                        mainText: mainText, 
                        secondaryText: secondaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.precision_manufacturing, 
                        iconColor: mainText.withValues(alpha: 0.7), 
                        title: 'Projects', 
                        subtitle: 'Creations & Demos', 
                        surface: surface, 
                        surfaceLow: surfaceLow, 
                        mainText: mainText, 
                        secondaryText: secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 6. Feature cards - Row 2
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.school_outlined, 
                        iconColor: courseAccent, 
                        title: 'Courses', 
                        subtitle: 'Classes & Tutorials', 
                        surface: surface, 
                        surfaceLow: surfaceLow, 
                        mainText: mainText, 
                        secondaryText: secondaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.people_outline, 
                        iconColor: communityAccent, 
                        title: 'Community', 
                        subtitle: 'Maker Sharing', 
                        surface: surface, 
                        surfaceLow: surfaceLow, 
                        mainText: mainText, 
                        secondaryText: secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 7. Community highlight banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Badges
                      SizedBox(
                        width: 72,
                        height: 32,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _buildBadge('#1', primaryMint, bgColor, primaryMint),
                            ),
                            Positioned(
                              left: 20,
                              child: _buildBadge('#2', mainText, bgColor, mainText.withValues(alpha: 0.3)),
                            ),
                            Positioned(
                              left: 40,
                              child: _buildBadge('#3', mainText, bgColor, mainText.withValues(alpha: 0.3)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "14,280+ Active Makers",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans', 
                                color: mainText, 
                                fontSize: 13, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Building ROS2, Arduino & Quadruped rigs",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans', 
                                color: secondaryText, 
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.trending_up, color: primaryMint, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 8. Primary button (Get Started)
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryMint, primaryContainer],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: primaryMint.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started', 
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans', 
                            color: bgColor, 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: bgColor, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 9. Secondary action (Sign In)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ", 
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans', 
                        color: secondaryText, 
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      },
                      child: const Text(
                        "Sign In", 
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans', 
                          color: primaryMint, 
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          decoration: TextDecoration.underline,
                          decorationColor: primaryMint,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    required String subtitle, 
    required Color surface, 
    required Color surfaceLow, 
    required Color mainText, 
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans', 
              color: mainText, 
              fontSize: 12, 
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans', 
              color: secondaryText, 
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans', 
          color: textColor, 
          fontSize: 12, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
