
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';

import '../themes/theme_provider.dart';

class SampleMessageCard extends StatelessWidget {
  final String name;
  final String message;
  final String image;
  final String time;
  final Color? bg;
  const SampleMessageCard({super.key, required this.message, required this.image, required this.time, required this.name, this.bg});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.01),
      child: Container(
        height: 55,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 15
              )
            ]
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        color: bg?.withOpacity(0.1),
                        shape: BoxShape.circle
                    ),
                    child: Image.asset("images/$image"),
                  ),
                  const SizedBox(width: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13
                        ),
                      ),
                      Text(
                        message,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  )
                ],
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.withOpacity(0.5)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}