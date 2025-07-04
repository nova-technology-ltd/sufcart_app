import 'package:flutter/material.dart';

class ProfilePostTabShimmaLoader extends StatelessWidget {
  final Animation<double> animation;

  const ProfilePostTabShimmaLoader({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < 8; i++) // Simulate 2 rows
            Row(
              children: [
                for (int j = 0; j < 3; j++) // 3 columns per row
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ShimmerBox(animation: animation),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final Animation<double> animation;

  const ShimmerBox({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.grey[300]!,
              Colors.grey[100]!,
              Colors.grey[300]!,
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: _SlideGradientTransform(animation.value),
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlideGradientTransform(this.slidePercent);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}