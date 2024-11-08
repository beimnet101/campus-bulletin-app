// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(100.0);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AppBarCurvedPainter(),
      child: Container(),
    );
  }
}

class AppBarCurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xFF6750A4);

    double width = size.width;
    double height = size.height;

    Path path = Path()
      ..lineTo(0, height - 75)
      ..quadraticBezierTo(width/2, height + 100, width, height-75)
      ..lineTo(width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
