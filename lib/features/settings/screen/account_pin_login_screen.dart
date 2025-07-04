import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/components/custom_bottom_nav/custom_bottom_navigation_bar.dart';
import '../../../utilities/components/custom_loader.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../../auth/service/auth_service.dart';
import '../../profile/model/user_provider.dart';

class AccountPinLoginScreen extends StatefulWidget {
  const AccountPinLoginScreen({super.key});

  @override
  State<AccountPinLoginScreen> createState() => _AccountPinLoginScreenState();
}

class _AccountPinLoginScreenState extends State<AccountPinLoginScreen> {
  String accountPIN = "";
  AuthService authService = AuthService();
  bool isLoading = false;

  Widget otpButtons(int numbers) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        height: 75,
        width: 75,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (accountPIN.length < 4) {
                accountPIN += numbers.toString();
              }
              if (accountPIN.length == 4) {
                _validatePIN();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                numbers.toString(),
                style: TextStyle(color: themeProvider.isDarkMode ? null : Colors.black, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validatePIN() {
    final user = Provider.of<UserProvider>(context, listen: false).userModel;
    if (accountPIN == user.accountPIN.toString()) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CustomBottomNavigationBar()),
            (route) => false,
      );
    } else {
      showSnackBar(
        context: context,
        message: "You provided an incorrect account PIN",
        title: "Wrong PIN",
      );
      setState(() {
        accountPIN = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            appBar: AppBar(
              backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
              leadingWidth: 90,
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Enter Account PIN",
                  style: TextStyle(
                    fontSize: 14,
                    // color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: index < accountPIN.length
                                  ? const Color(AppColors.primaryColor)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 1,
                                color: index < accountPIN.length
                                    ? const Color(AppColors.primaryColor)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: index < accountPIN.length
                                      ? const Color(AppColors.primaryColor)
                                      .withOpacity(0.3)
                                      : Colors.transparent,
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(1, 5),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        for (int i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                3,
                                    (index) => otpButtons(1 + 3 * i + index),
                              ).toList(),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(3),
                              child: SizedBox(
                                height: 75,
                                width: 75,
                              ),
                            ),
                            otpButtons(0),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (accountPIN.isNotEmpty) {
                                    accountPIN =
                                        accountPIN.substring(0, accountPIN.length - 1);
                                  }
                                });
                              },
                              child: SizedBox(
                                height: 60,
                                width: 75,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.backspace,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
              child: const Center(
                child: CustomLoader(
                  colors: Color(AppColors.primaryColor),
                  maxSize: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
