import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';

import 'constants/app_colors.dart';

class EndlessShapeMorphingContainer extends StatefulWidget {
  @override
  _EndlessShapeMorphingContainerState createState() =>
      _EndlessShapeMorphingContainerState();
}

class _EndlessShapeMorphingContainerState
    extends State<EndlessShapeMorphingContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation components
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // Loop the animation forward and backward

    // Define the animation curve and values
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themProvider = Provider.of<ThemeProvider>(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double width = 200 + 500 * _animation.value;
        double height = 100 * 5 * _animation.value;
        double borderRadius = 360 * _animation.value;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.0),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: themProvider.isDarkMode ? Color(AppColors.primaryColor).withOpacity(0.05) : Color(AppColors.primaryColor).withOpacity(0.3),
                offset: const Offset(20, 20),
                blurRadius: 100,
                spreadRadius: 20
              )
            ]
          ),
          child: Center(
          ),
        );
      },
    );
  }
}