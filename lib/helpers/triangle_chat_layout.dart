import 'package:flutter/material.dart';


class Triangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white;

    var path = Path();
    path.lineTo(10, 0);
    path.lineTo(0, -10);
    path.lineTo(-10, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}