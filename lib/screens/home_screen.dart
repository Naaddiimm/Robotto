import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'drawer_screen.dart';
import 'projects_screen.dart';
import '../shop/shop_module.dart';
import '../learning/learning_module.dart';
import '../event/event_module.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  
  late AnimationController _controller;
  late Animation<double> _animation;
  late Tween<double> _positionTween;

  // Cybernetic Orbit Colors based on DESIGN.md
  static const Color bgColor = Color(0xFF091422);
  static const Color activePurple = Color(0xFF5F00BE);
  static const Color secondaryTeal = Color(0xFF8B5CF6);
  static const Color inactiveIcon = Color(0xFF85948E);
  static const Color whiteContainer = Color(0xFFFFFFFF);

  final List<_NavItem> _navItems = [
    _NavItem(Icons.shopping_bag_outlined, "Marketplace"),
    _NavItem(Icons.forum_outlined, "Forum"),
    _NavItem(Icons.school_outlined, "Courses"),
    _NavItem(Icons.calendar_month_outlined, "Events"),
    _NavItem(Icons.precision_manufacturing, "Projects"),
    _NavItem(Icons.person_outline, "Profile"),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _positionTween = Tween<double>(begin: 0, end: 0);
    _animation = _positionTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // Fluid and responsive, no excessive bouncing
      ),
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    _positionTween.begin = _animation.value;
    _positionTween.end = index.toDouble();
    _controller.forward(from: 0.0);
  }

  Widget _buildPlaceholderScreen(String title) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false, // Prevents the floating navbar from moving up when keyboard opens
      drawer: const DrawerScreen(), // Added Drawer Screen
      body: Stack(
        children: [
          // Main Content Body (IndexedStack for tabs)
          IndexedStack(
            index: _selectedIndex,
            children: [
              const ShopModule(),
              _buildPlaceholderScreen("Forum"),
              const LearningModule(),
              const EventModule(),
              const ProjectsScreen(),
              const ProfileScreen(),
            ],
          ),

          // Custom Floating Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              bottom: true,
              child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final double value = _animation.value;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        final double itemWidth = width / _navItems.length;
                        final double center = (value * itemWidth) + (itemWidth / 2);
                        const double dotSize = 12.0;
                        final double dotLeft = center - (dotSize / 2);

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. White Container with Fluid Curved Notch
                            CustomPaint(
                              painter: _NavBarPainter(value, _navItems.length),
                              child: SizedBox(
                                height: 72,
                                width: width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: List.generate(_navItems.length, (index) {
                                    final double distance = (value - index).abs();
                                    final double intensity = 1.0 - distance.clamp(0.0, 1.0);
                                    
                                    // Smoothly transition colors
                                    final Color currentColor = Color.lerp(inactiveIcon, secondaryTeal, intensity)!;
                                    // Shift active item slightly downwards to avoid the notch
                                    final double topShift = intensity * 8.0;

                                    return GestureDetector(
                                      onTap: () => _onItemTapped(index),
                                      behavior: HitTestBehavior.opaque,
                                      child: SizedBox(
                                        width: itemWidth,
                                        child: Transform.translate(
                                          offset: Offset(0, topShift),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _navItems[index].icon,
                                                color: currentColor,
                                                size: 24,
                                              ),
                                              const SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    _navItems[index].label,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 10,
                                                      fontWeight: intensity > 0.5 ? FontWeight.bold : FontWeight.w600,
                                                      color: currentColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            
                            // 2. Active Indicator Dot
                            Positioned(
                              top: -2, // Moved upward by 8 logical pixels
                              left: dotLeft,
                              child: Container(
                                width: dotSize,
                                height: dotSize,
                                decoration: BoxDecoration(
                                  color: activePurple,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: activePurple.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    );
                  },
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem(this.icon, this.label);
}

class _NavBarPainter extends CustomPainter {
  final double position;
  final int itemCount;

  _NavBarPainter(this.position, this.itemCount);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = _HomeScreenState.whiteContainer..style = PaintingStyle.fill;
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25) // Subtle depth shadow for the navbar
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final double itemWidth = size.width / itemCount;
    final double center = (position * itemWidth) + (itemWidth / 2);

    // Notch math for a smooth, fluid concave cutout wrapping the active dot
    const double spread = 24.0; // Half width of the notch
    const double dip = 16.0;    // Depth of the notch

    // 1. Draw the primary background
    final Path background = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, size.height),
        topLeft: const Radius.circular(24),
        topRight: const Radius.circular(24),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      ));

    // 2. Draw the fluid notch shape to subtract from the pill
    final Path notch = Path();
    notch.moveTo(center - spread, -10); // Start safely above the bar
    notch.lineTo(center - spread, 0); // Drop to the top edge
    
    // Left curve downwards
    notch.cubicTo(
      center - spread * 0.4, 0,
      center - spread * 0.6, dip,
      center, dip,
    );
    
    // Right curve upwards
    notch.cubicTo(
      center + spread * 0.6, dip,
      center + spread * 0.4, 0,
      center + spread, 0,
    );
    
    notch.lineTo(center + spread, -10); // Close safely above
    notch.close();

    // 3. Combine shapes (Subtract notch from the pill)
    final Path finalPath = Path.combine(PathOperation.difference, background, notch);

    // Render shadow followed by the clean white shape
    canvas.drawPath(finalPath, shadowPaint);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(_NavBarPainter oldDelegate) => oldDelegate.position != position;
}
