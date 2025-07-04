import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomButtonOne extends StatelessWidget {
  final String title;
  final VoidCallback onClick;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final double? corner;
  final double? height;
  final double? width;
  final double? fontSize;

  const CustomButtonOne(
      {super.key, required this.title, required this.onClick, required this.isLoading, this.color, this.corner, this.textColor, this.fontSize, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: height ?? 43,
        width: width ?? MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: isLoading ? Colors.transparent : color ?? const Color(AppColors.primaryColor),
            borderRadius: BorderRadius.circular( corner ?? 15)),
        child: isLoading ? const CupertinoActivityIndicator(): Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor ?? Colors.white, fontSize: fontSize ?? 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
