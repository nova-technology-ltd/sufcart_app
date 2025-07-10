import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';
import 'dart:math' as math;

import 'features/community/messages/components/typing_indicator.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      // body: Center(
      //   child: TypingIndicator(
      //     dotSize: 9.0,
      //     dotColor: Colors.grey.withOpacity(0.3),
      //     animationDuration: Duration(milliseconds: 1000),
      //   ),
      // ),
    );
  }
}