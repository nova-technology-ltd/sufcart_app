import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';

class AccountPinSuccessScreen extends StatelessWidget {
  const AccountPinSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: const Color(AppColors.primaryColor).withOpacity(0.8),
                  shape: BoxShape.circle
              ),
              child: const Center(
                child: Icon(Icons.check, color: Colors.white,),
              ),
            ),
            const SizedBox(height: 10,),
            const Text(
              "Account PIN Set Successfully",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
              ),
            ),
            const Text(
              "You have successfully set your account PIN and can now be used to securely perform transactions within the app.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey
              ),
            ),
            const Spacer(),
            CustomButtonOne(title: "Done", onClick: (){
              Navigator.pop(context);
              Navigator.pop(context);
            }, isLoading: false,)
          ],
        ),
      ),
    );
  }
}
