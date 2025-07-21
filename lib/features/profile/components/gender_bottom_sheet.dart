import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';

import '../../../utilities/constants/app_colors.dart';

class GenderBottomSheet extends StatelessWidget {
  final VoidCallback onMaleClicked;
  final VoidCallback onFemaleClicked;
  const GenderBottomSheet({super.key, required this.onMaleClicked, required this.onFemaleClicked});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 205,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const Text(
                  "Select Gender",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: onMaleClicked,
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey.withOpacity(0.2) : const Color(AppColors.primaryColor)
                                        .withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_back_outlined,
                                    size: 16,
                                    color: isDarkMode ? Colors.grey : Color(AppColors.primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                "Male",
                                style: TextStyle(
                                    fontSize: 12),
                              )
                            ],
                          ),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey : Color(AppColors.primaryColor), shape: BoxShape.circle),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: onFemaleClicked,
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey.withOpacity(0.2) : const Color(AppColors.primaryColor)
                                        .withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 16,
                                    color: isDarkMode ? Colors.grey : Color(AppColors.primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                "Female",
                                style: TextStyle(
                                    fontSize: 12),
                              )
                            ],
                          ),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey : Color(AppColors.primaryColor),
                                shape: BoxShape.circle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5,),
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.withOpacity(0.05) : const Color(AppColors.primaryColor).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_rounded, color: isDarkMode ? Colors.grey : Color(AppColors.primaryColor),),
                        SizedBox(width: 10,),
                        Expanded(child: Text(
                          "Please make sure to provide your actual gender, this is to help us serve you well and make sure your experience with us is unique.",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode ? Colors.grey : Color(AppColors.primaryColor)
                          ),
                        ))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
