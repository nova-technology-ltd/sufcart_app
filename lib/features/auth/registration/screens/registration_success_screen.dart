import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_lottie_anime.dart';
import '../../../../utilities/constants/app_strings.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../login/screens/login_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Stack(
          children: [
            // Align(
            //   alignment: Alignment.bottomCenter,
            //     child: SizedBox(
            //       height: MediaQuery.of(context).size.height,
            //         width: MediaQuery.of(context).size.width,
            //         child: LottieBuilder.asset(AppLottieAnime.celebrateAnime))),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(AppColors.primaryColor)
                      ),
                      child: const Center(child: Icon(Icons.check, color: Colors.white,))),
                ),
                const Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: "You have successfully created your ",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              )
                          ),
                          const TextSpan(
                              text: AppStrings.appNameText,
                              style: TextStyle(
                                  color: Color(AppColors.primaryColor),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500
                              )
                          ),
                          TextSpan(
                              text: " Account and it's now ready for use, click on the button bellow to get into your account and start exploring all that we offer.",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              )
                          ),
                        ]
                    )),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: CustomButtonOne(title: "Let's Go", onClick: (){
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        }, isLoading: false,),
      ),
    );
  }
}
