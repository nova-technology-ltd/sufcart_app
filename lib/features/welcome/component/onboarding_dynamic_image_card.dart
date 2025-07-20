import 'package:flutter/material.dart';

class OnboardingDynamicImageCard extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final bool isCircle;
  const OnboardingDynamicImageCard({super.key, required this.image, this.height, this.width, required this.isCircle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 100,
      width: width ?? 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
        borderRadius: !isCircle ? BorderRadius.circular(10) : null,
        shape: !isCircle ? BoxShape.rectangle : BoxShape.circle
      ),
      child: Image.asset("images/$image", fit: BoxFit.cover,),
    );
  }
}
