import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../themes/theme_provider.dart';

class CustomBottomNavItem extends StatelessWidget {
  final String title;
  final String icon;
  final int position;
  final int index;
  final VoidCallback onTap;

  const CustomBottomNavItem({
    super.key,
    required this.title,
    required this.icon,
    required this.position,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == position;
    final textWidth = _calculateTextWidth(title, TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ), context);

    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return MaterialButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 22,
            child: Image.asset(
              icon,
              color: isSelected ? Color(AppColors.primaryColor) : Colors.grey,
            ),
          ),
          if (isSelected)
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Color(AppColors.primaryColor) : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  double _calculateTextWidth(String text, TextStyle style, BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }
}