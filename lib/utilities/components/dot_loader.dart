import 'package:flutter/material.dart';

class ProgressiveDotLoader extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final double dotSpacing;
  final Color activeColor;
  final Color inactiveColor;
  final Duration duration;

  const ProgressiveDotLoader({
    super.key,
    this.dotCount = 4,
    this.dotSize = 12.0,
    this.dotSpacing = 8.0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<ProgressiveDotLoader> createState() => _ProgressiveDotLoaderState();
}

class _ProgressiveDotLoaderState extends State<ProgressiveDotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: widget.dotCount.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            bool isActive = _animation.value >= index;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.dotSpacing / 2),
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                color: isActive ? widget.activeColor : widget.inactiveColor,
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}


