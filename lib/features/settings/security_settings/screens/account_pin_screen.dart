import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_loader.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_fonts.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';

class AccountPinScreen extends StatefulWidget {
  const AccountPinScreen({super.key});

  @override
  State<AccountPinScreen> createState() => _AccountPinScreenState();
}

class _AccountPinScreenState extends State<AccountPinScreen> {
  String accountPIN = "";
  AuthService authService = AuthService();

  Widget otpButtons(int numbers) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        height: 60,
        width: 100,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (accountPIN.length < 4) {
                accountPIN += numbers.toString();
              }
            });
          },
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border:
                      Border.all(width: 1, color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(15)),
              child: Center(
                child: Text(
                  numbers.toString(),
                  style: TextStyle(color: themeProvider.isDarkMode ? null : Colors.black, fontSize: 18),
                ),
              )),
        ),
      ),
    );
  }

  bool isLoading = false;

  Future<void> _createAccountPIN(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      int data = int.parse(accountPIN);
      await authService.setAccountPIN(context, data);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            appBar: AppBar(
              backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
              leadingWidth: 90,
              title: const Text(
                "Account PIN",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
            ),
            body: Column(
              children: [
                const SizedBox(
                  height: 15,
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
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: index < accountPIN.length
                                  ? const Color(AppColors.primaryColor)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1,
                                  color: index < accountPIN.length
                                      ? const Color(AppColors.primaryColor)
                                      : Colors.grey.withOpacity(0.3)),
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
                            child: Center(
                              child: Text(
                                index < accountPIN.length
                                    ? accountPIN[index]
                                    : "",
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const Spacer(),
                for (int i = 0; i < 3; i++)
                  accountPIN.length == 4
                      ? const SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                                  3, (index) => otpButtons(1 + 3 * i + index))
                              .toList(),
                        ),
                accountPIN.length == 4
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: CustomButtonOne(
                          title: "Set PIN",
                          onClick: () => _createAccountPIN(context), isLoading: isLoading ? true : false,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: SizedBox(
                              height: 60,
                              width: 100,
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {});
                                  },
                                  child: const Text("")),
                            ),
                          ),
                          otpButtons(0),
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: SizedBox(
                              height: 60,
                              width: 100,
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      accountPIN = accountPIN.substring(
                                          0, accountPIN.length - 1);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent),
                                    child: const Center(
                                      child: Icon(
                                        Icons.backspace,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
              child: const Center(child: CustomLoader(colors: Color(AppColors.primaryColor), maxSize: 50)),
            )
        ],
      ),
    );
  }
}
