import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';

class SecurityQuestionsAlertDialog extends StatelessWidget {
  final String question;
  final Function(String) onSubmitted;
  const SecurityQuestionsAlertDialog({super.key, required this.question, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Dialog(
          backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context)
                .size
                .width *
                0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: const Color(
                          AppColors
                              .primaryColor)
                          .withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: const Center(
                    child: Icon(Icons.tips_and_updates_rounded, color: Color(AppColors.primaryColor), size: 20,),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Answer Security Question",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500),
                ),
                const SizedBox(height: 15,),
                TextFormField(
                  autofocus: true,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    labelText: question,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey, width: 1)
                    ),
                    focusedBorder:  OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey, width: 1)
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.grey
                    ),
                    counterStyle: const TextStyle(
                      fontSize: 12
                    ),
                  ),
                  onFieldSubmitted: onSubmitted,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
