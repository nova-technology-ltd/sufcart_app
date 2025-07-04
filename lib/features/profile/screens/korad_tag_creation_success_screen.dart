import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/components/custom_button_one.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';

class KoradTagCreationSuccessScreen extends StatelessWidget {
  const KoradTagCreationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
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
              child: Image.asset("images/STK-20240102-WA0044.webp"),
            ),
            const SizedBox(height: 10,),
            const Text(
              "TAGGED Successfully!!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            ),
            const Text(
              "You have successfully created your identification tag and will now be used to easily navigate you through the app",
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
