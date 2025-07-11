
import 'dart:math';

import 'package:flutter/material.dart';

class MovingCirclesScreen extends StatefulWidget {
  @override
  _MovingCirclesScreenState createState() => _MovingCirclesScreenState();
}

class _MovingCirclesScreenState extends State<MovingCirclesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<CircleData> _circles = [];

  @override
  void initState() {
    super.initState();

    // Create 15 random circles
    for (int i = 0; i < 15; i++) {
      _circles.add(CircleData(
        size: _random.nextDouble() * 50 + 20, // 20-70 size
        speed: _random.nextDouble() * 2 + 0.5, // 0.5-2.5 speed
        color: Color.fromARGB(
          255,
          _random.nextInt(200) + 55, // R
          _random.nextInt(200) + 55, // G
          _random.nextInt(200) + 55, // B
        ),
        yPosition: _random.nextDouble(),
        xOffset: _random.nextDouble() * 500, // Start at random x position
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: CirclePainter(
              circles: _circles,
              animationValue: _controller.value,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

class CircleData {
  final double size;
  final double speed;
  final Color color;
  final double yPosition;
  double xOffset;

  CircleData({
    required this.size,
    required this.speed,
    required this.color,
    required this.yPosition,
    required this.xOffset,
  });
}

class CirclePainter extends CustomPainter {
  final List<CircleData> circles;
  final double animationValue;

  CirclePainter({
    required this.circles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var circle in circles) {
      // Update x position based on speed and animation value
      circle.xOffset -= circle.speed;

      // Reset to right side when circle goes off left side
      if (circle.xOffset < -circle.size) {
        circle.xOffset = size.width + circle.size;
      }

      // Calculate position
      final x = circle.xOffset;
      final y = circle.yPosition * size.height;

      // Draw circle
      final paint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        circle.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}