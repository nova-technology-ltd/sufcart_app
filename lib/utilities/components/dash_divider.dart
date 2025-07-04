import 'package:flutter/material.dart';

class DashDivider extends StatelessWidget {
  final double dashWidth;
  final double dashHeight;
  final double dashSpacing;
  final Color dashColor;

  const DashDivider({
    Key? key,
    this.dashWidth = 10.0,
    this.dashHeight = 1.0,
    this.dashSpacing = 5.0,
    this.dashColor = Colors.blueGrey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the number of dashes that fit in the available width
          final screenWidth = constraints.maxWidth;
          final dashCount =
          (screenWidth / (dashWidth + dashSpacing)).floor();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (index) {
              return Container(
                width: dashWidth,
                height: dashHeight,
                color: dashColor,
              );
            }),
          );
        },
      ),
    );
  }
}