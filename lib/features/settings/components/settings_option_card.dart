import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';

class SettingsOptionCard extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String title;
  final VoidCallback onClick;
  const SettingsOptionCard({super.key, required this.icon, required this.title, required this.onClick, this.color});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Container(
        height: 35,
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8)
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            color: color?.withOpacity(0.2) ?? const Color(AppColors.primaryColor).withOpacity(0.2),
                            shape: BoxShape.circle
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 16,
                            color: themeProvider.isDarkMode && color == null ? Colors.white.withOpacity(0.6) : !themeProvider.isDarkMode && color == null ? const Color(AppColors.primaryColor) : color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode
                                ? null
                                : Colors.black,
                        ),
                      )
                    ],
                  ),
                  const Icon(Icons.arrow_right_alt, size: 18, color: Colors.grey,)
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: MaterialButton(
                onPressed: onClick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
