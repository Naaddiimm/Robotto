import 'package:flutter/material.dart';

class BackgroundWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF00F5C4).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint2 = Paint()
      ..color = const Color(0xFF00F5C4).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Top Right ambient wave
    final path1 = Path();
    path1.moveTo(size.width * 0.3, 0);
    path1.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.1,
      size.width,
      size.height * 0.2,
    );
    canvas.drawPath(path1, paint1);

    // Hero section bottom curve divider line
    final path2 = Path();
    path2.moveTo(0, size.height * 0.48);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.52,
      size.width,
      size.height * 0.44,
    );
    canvas.drawPath(path2, paint2);

    // Bottom left subtle wave
    final path3 = Path();
    path3.moveTo(0, size.height * 0.82);
    path3.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.95,
      size.width,
      size.height * 0.88,
    );
    canvas.drawPath(path3, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
