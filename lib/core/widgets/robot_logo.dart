import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RobotLogo extends StatelessWidget {
  final String? imagePath;

  const RobotLogo({
    super.key,
    this.imagePath = 'assets/images/logoRobotto.png',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Robot Logo Image (or vector fallback)
        SizedBox(
          width: 85,
          height: 85,
          child: Image.asset(
            imagePath!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Custom vector robot painter fallback if image file is not yet added
              return CustomPaint(
                painter: RobotIconPainter(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // ROBOTTO Text Branding
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ROBOTT',
              style: GoogleFonts.orbitron(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            // Cyan glowing O
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(left: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const AppTheme.accent,
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const AppTheme.accent.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Tagline
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
            children: [
              const TextSpan(text: "Tout l'univers de la robotique\nau "),
              TextSpan(
                text: "même endroit",
                style: GoogleFonts.poppins(
                  color: const AppTheme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RobotIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Glowing cyan orbit ellipse
    final orbitPaint = Paint()
      ..color = const AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.35); // tilt orbit
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.width * 0.95, height: size.height * 0.35),
      orbitPaint,
    );
    canvas.restore();

    // Antenna ball
    final antennaPaint = Paint()..color = const AppTheme.accent;
    canvas.drawCircle(Offset(center.dx, center.dy - 32), 4, antennaPaint);

    final antennaLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(Offset(center.dx, center.dy - 30), Offset(center.dx, center.dy - 22), antennaLine);

    // Robot Head Base
    final headPath = Path();
    headPath.moveTo(center.dx - 20, center.dy - 20);
    headPath.quadraticBezierTo(center.dx, center.dy - 26, center.dx + 20, center.dy - 20);
    headPath.quadraticBezierTo(center.dx + 26, center.dy + 8, center.dx + 18, center.dy + 18);
    headPath.quadraticBezierTo(center.dx, center.dy + 24, center.dx - 18, center.dy + 18);
    headPath.quadraticBezierTo(center.dx - 26, center.dy + 8, center.dx - 20, center.dy - 20);

    final headPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(headPath, headPaint);

    // Visor Area
    final visorPath = Path();
    visorPath.moveTo(center.dx - 16, center.dy - 12);
    visorPath.quadraticBezierTo(center.dx, center.dy - 16, center.dx + 16, center.dy - 12);
    visorPath.quadraticBezierTo(center.dx + 18, center.dy + 4, center.dx + 14, center.dy + 10);
    visorPath.quadraticBezierTo(center.dx, center.dy + 14, center.dx - 14, center.dy + 10);
    visorPath.quadraticBezierTo(center.dx - 18, center.dy + 4, center.dx - 16, center.dy - 12);

    final visorPaint = Paint()..color = const Color(0xFF0B1220);
    canvas.drawPath(visorPath, visorPaint);

    // Glowing Eyes
    final eyePaint = Paint()
      ..color = const AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    // Left Eye Arc
    final leftEyePath = Path();
    leftEyePath.moveTo(center.dx - 11, center.dy + 1);
    leftEyePath.quadraticBezierTo(center.dx - 7, center.dy - 5, center.dx - 3, center.dy + 1);
    canvas.drawPath(leftEyePath, eyePaint);

    // Right Eye Arc
    final rightEyePath = Path();
    rightEyePath.moveTo(center.dx + 3, center.dy + 1);
    rightEyePath.quadraticBezierTo(center.dx + 7, center.dy - 5, center.dx + 11, center.dy + 1);
    canvas.drawPath(rightEyePath, eyePaint);

    // Neck / Base accent
    final neckPath = Path();
    neckPath.moveTo(center.dx - 10, center.dy + 20);
    neckPath.lineTo(center.dx + 10, center.dy + 20);
    neckPath.lineTo(center.dx + 12, center.dy + 25);
    neckPath.lineTo(center.dx - 12, center.dy + 25);
    neckPath.close();

    final neckPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawPath(neckPath, neckPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
