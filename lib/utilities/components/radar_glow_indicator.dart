import 'package:flutter/material.dart';

class RadarCircleIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final double animationSpeed;
  final int circleCount;

  const RadarCircleIndicator({super.key,
    this.size = 50,
    this.color = Colors.green,
    this.animationSpeed = 2,
    this.circleCount = 3,
  });

  @override
  State<RadarCircleIndicator> createState() => _RadarCircleIndicatorState();
}

class _RadarCircleIndicatorState extends State<RadarCircleIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.animationSpeed.toInt()),
    )..repeat();

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Inner solid circle
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
        // Animated concentric circles
        for (int i = 0; i < widget.circleCount; i++)
          Transform.scale(
            scale: 1 + (_animation.value * (i + 1)), // Scale each circle
            child: Opacity(
              opacity: 1 - _animation.value, // Fade out as the circle grows
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color,
                    width: 2, // Border thickness
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}