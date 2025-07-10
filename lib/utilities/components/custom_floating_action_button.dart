import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final icon;
  const CustomFloatingActionButton({super.key, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(AppColors.primaryColor),
        ),
        child: Center(
          child: icon,
        ),
      ),
    );
  }
}
