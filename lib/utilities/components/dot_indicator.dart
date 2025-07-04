import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../themes/theme_provider.dart';

class DotIndicator extends StatelessWidget {
  final bool isCurrent;
  final double? height;
  final double? width;
  final double? shape;
  const DotIndicator({super.key, required this.isCurrent, this.height, this.width, this.shape});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        height: height ?? 6,
        width: width ?? (isCurrent ? 30 : 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(shape ?? 360),
          color: isCurrent ? const Color(AppColors.primaryColor) : themeProvider.isDarkMode ? Colors.grey : Colors.grey[200]
        ),
      ),
    );
  }
}
