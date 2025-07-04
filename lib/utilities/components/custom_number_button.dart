import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

class CustomNumberButton extends StatelessWidget {
  final VoidCallback onClick;
  final int numbers;
  const CustomNumberButton({super.key, required this.onClick, required this.numbers});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        height: 50,
        width: 100,
        child: GestureDetector(
          onTap: onClick,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                numbers.toString(),
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black.withOpacity(0.6),
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}