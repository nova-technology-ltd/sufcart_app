import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_strings.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../login/screens/login_screen.dart';

class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? null : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Center(
              child: Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(AppColors.primaryColor)),
                  child: const Center(
                      child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ))),
            ),
            const Text(
              "Reset Successful!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                      text: "You have successfully changed your ",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      )),
                  const TextSpan(
                      text: AppStrings.appNameText,
                      style: TextStyle(
                          color: Color(AppColors.primaryColor),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                  TextSpan(
                      text:
                          " password, try writing it down somewhere to help you not to forget next time.",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      )),
                ])),
            const Spacer(),
            CustomButtonOne(
                title: "Login",
                onClick: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                }, isLoading: false,)
          ],
        ),
      ),
    );
  }
}
