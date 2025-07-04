import 'package:flutter/material.dart';

import '../constants/app_icons.dart';

class CustomLoader extends StatefulWidget {
  final Color? colors;
  final double? maxSize;
  const CustomLoader({super.key, this.colors, this.maxSize});


  @override
  _CustomLoaderState createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: SizedBox(
                height: widget.maxSize ?? 100,
                width: widget.maxSize ?? 100,
                child: Image.asset(AppIcons.koradLogo, color: widget.colors ?? Colors.white,),
              ),
            ),
          ),
        );
      },
    );
  }
}
