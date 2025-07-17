import 'package:flutter/material.dart';

class SampleAvatars extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;
  final String image;
  const SampleAvatars({super.key, required this.height, required this.width, this.color, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color?.withOpacity(0.2)
      ),
      child: Image.asset("images/$image"),
    );
  }
}