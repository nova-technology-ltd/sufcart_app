import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';

class EmailVerificationSuccessScreen extends StatelessWidget {
  const EmailVerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                  color: const Color(AppColors.primaryColor).withOpacity(0.4),
                  shape: BoxShape.circle
              ),
              child: const Center(child: Icon(Icons.check, color: Colors.white, size: 25,)),
            ),
            const SizedBox(height: 10,),
            const Text(
              "Email Verified Successfully",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
              ),
            ),
            const Text(
              "You have successfully verified you email",
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
