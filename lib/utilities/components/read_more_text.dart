import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ReadMoreText extends StatefulWidget {
  final String longText;
  final int maxLength;
  final FontWeight? weight;
  final TextStyle? tStyle;
  final TextAlign? textAlign;
  final double? size;
  final Color? color;
  const ReadMoreText({Key? key, required this.longText, this.maxLength = 100, this.weight, this.size, this.color, this.tStyle, this.textAlign}) : super(key: key);

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isLongText = widget.longText.length > widget.maxLength;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded ? widget.longText : widget.longText.substring(0, isLongText ? widget.maxLength : widget.longText.length),
          style: widget.tStyle ?? TextStyle(
            color: widget.color ?? Colors.grey,
            fontSize: widget.size,
            fontWeight: widget.weight,
          ),
          textAlign: widget.textAlign,
        ),
        if (isLongText)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? 'Read less' : 'Read more',
              style: const TextStyle(
                color: Color(AppColors.primaryColor),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
