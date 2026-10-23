import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RobotHeroWidget extends StatefulWidget {
  const RobotHeroWidget({super.key});

  @override
  State<RobotHeroWidget> createState() => _RobotHeroWidgetState();
}

class _RobotHeroWidgetState extends State<RobotHeroWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOutSine,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.12, end: 0.28).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return SizedBox(
          height: 190,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Pulsating background ambient cyan glow
              Positioned(
                right: 20,
                top: 20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accent.withValues(alpha: _glowAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withValues(alpha: _glowAnimation.value),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Handwritten text on the left
              Positioned(
                left: 24,
                top: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build',
                      style: GoogleFonts.caveat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'Your Ideas',
                      style: GoogleFonts.caveat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'with Us',
                      style: GoogleFonts.caveat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Handwritten underline arc
                    CustomPaint(
                      size: const Size(90, 8),
                      painter: UnderlinePainter(),
                    ),
                  ],
                ),
              ),

              // Floating 3D Cute Robot Mascot Illustration
              Positioned(
                right: 16,
                bottom: 0,
                top: 0,
                child: Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: SizedBox(
                    width: 220,
                    child: CustomPaint(
                      painter: HeroRobotMascotPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width, size.height * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeroRobotMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final robotCenterX = size.width * 0.65;
    final robotCenterY = size.height * 0.5;

    // Background Robotic Arm Workstation Silhouette
    final armPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final armPath = Path();
    armPath.moveTo(size.width * 0.1, size.height * 0.75);
    armPath.lineTo(size.width * 0.25, size.height * 0.45);
    armPath.lineTo(size.width * 0.35, size.height * 0.55);
    canvas.drawPath(armPath, armPaint);

    // Robotic Joint circles
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.45), 6, Paint()..color = AppTheme.accent);

    // Robot Antenna Light
    canvas.drawCircle(Offset(robotCenterX, robotCenterY - 60), 5, Paint()..color = AppTheme.accent);

    // Antenna Wire
    canvas.drawLine(
      Offset(robotCenterX, robotCenterY - 55),
      Offset(robotCenterX, robotCenterY - 40),
      Paint()..color = Colors.white..strokeWidth = 2.5,
    );

    // Robot Head (Round white helmet)
    final headRect = Rect.fromCenter(
      center: Offset(robotCenterX, robotCenterY - 22),
      width: 68,
      height: 52,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(26)),
      Paint()..color = Colors.white,
    );

    // Dark Visor Screen inside Head
    final visorRect = Rect.fromCenter(
      center: Offset(robotCenterX, robotCenterY - 22),
      width: 54,
      height: 36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(18)),
      Paint()..color = const Color(0xFF0B1220),
    );

    // Happy Glowing Cyan Eye Arcs (^ ^)
    final eyePaint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    // Left Eye
    final leftEye = Path();
    leftEye.moveTo(robotCenterX - 16, robotCenterY - 20);
    leftEye.quadraticBezierTo(robotCenterX - 11, robotCenterY - 28, robotCenterX - 6, robotCenterY - 20);
    canvas.drawPath(leftEye, eyePaint);

    // Right Eye
    final rightEye = Path();
    rightEye.moveTo(robotCenterX + 6, robotCenterY - 20);
    rightEye.quadraticBezierTo(robotCenterX + 11, robotCenterY - 28, robotCenterX + 16, robotCenterY - 20);
    canvas.drawPath(rightEye, eyePaint);

    // Robot Body (White rounded capsule)
    final bodyRect = Rect.fromCenter(
      center: Offset(robotCenterX, robotCenterY + 30),
      width: 60,
      height: 50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(25)),
      Paint()..color = Colors.white,
    );

    // Chest Logo "R"
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'R',
        style: TextStyle(
          color: const Color(0xFF0B1220),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.orbitron().fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(robotCenterX - textPainter.width / 2, robotCenterY + 22));

    // Left Waving Arm/Hand
    final armLeftPath = Path();
    armLeftPath.moveTo(robotCenterX - 28, robotCenterY + 22);
    armLeftPath.quadraticBezierTo(robotCenterX - 45, robotCenterY + 10, robotCenterX - 48, robotCenterY - 5);
    canvas.drawPath(
      armLeftPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // Left Waving Hand Palm
    canvas.drawCircle(Offset(robotCenterX - 48, robotCenterY - 5), 7, Paint()..color = Colors.white);

    // Right Arm
    canvas.drawCircle(Offset(robotCenterX + 30, robotCenterY + 25), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
