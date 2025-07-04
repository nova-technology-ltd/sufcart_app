import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? Color(AppColors.primaryColor) : Colors.grey.withOpacity(0.5),
            width: 1.5,
          ),
          shape: BoxShape.circle,
        ),
        child: value
            ? Center(
              child: Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
              color: Color(AppColors.primaryColor),
              shape: BoxShape.circle
                        ),
                      ),
            )
            : null,
      ),
    );
  }
}