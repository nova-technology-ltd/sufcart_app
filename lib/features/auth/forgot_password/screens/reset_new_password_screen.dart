import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_loader.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/components/strong_password_check.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../service/auth_service.dart';

class ResetNewPasswordScreen extends StatefulWidget {
  final String otp;
  final String email;

  const ResetNewPasswordScreen(
      {super.key, required this.otp, required this.email});

  @override
  State<ResetNewPasswordScreen> createState() => _ResetNewPasswordScreenState();
}

class _ResetNewPasswordScreenState extends State<ResetNewPasswordScreen> {
  final setNewPasswordController = TextEditingController();
  final confirmSetNewPasswordController = TextEditingController();
  bool isEyeClicked = false;
  bool isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _verifyAndResetPassword(BuildContext context, String email,
      String otp, String newPassword) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _authService.verifyOTPAndResetPassword(
          context, email, otp, newPassword);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
          context: context, message: "$e", title: "Something Went Wrong");
    }
  }

  bool isPasswordValid() {
    bool hasMinLength = setNewPasswordController.text.length >= 6;
    bool hasDigits = RegExp(r'\d').hasMatch(setNewPasswordController.text);
    bool hasUpperCase =
        RegExp(r'[A-Z]').hasMatch(setNewPasswordController.text);
    bool hasLowerCase =
        RegExp(r'[a-z]').hasMatch(setNewPasswordController.text);
    bool hasSymbols = RegExp(r'[!@#$%^&*(),.?":{}|<>]')
        .hasMatch(setNewPasswordController.text);

    return hasMinLength &&
        hasDigits &&
        hasUpperCase &&
        hasLowerCase &&
        hasSymbols;
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
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
              leadingWidth: 90,
              backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create New Password",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400),
                  ),
                  const Text(
                    "password must be unique from those previously used.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    isObscure: isEyeClicked ? false : true,
                    controller: setNewPasswordController,
                    onChange: (value) {
                      setState(() {});
                    },
                    hintText: "Enter password",
                    prefixIcon: SizedBox(
                        height: 10,
                        width: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Image.asset(
                            "images/lock-outlined.png",
                            color: Colors.grey,
                          ),
                        )),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isEyeClicked = !isEyeClicked;
                        });
                      },
                      icon: SizedBox(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          isEyeClicked
                              ? AppIcons.eyeCloseIcon
                              : AppIcons.eyeOpenIcon,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  StrongPasswordCheck(
                    title: "6 characters and above",
                    isValid: setNewPasswordController.text.length >= 6,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  StrongPasswordCheck(
                    title: "use of number",
                    isValid:
                        RegExp(r'\d').hasMatch(setNewPasswordController.text),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  StrongPasswordCheck(
                    title: "use of capital letter",
                    isValid: RegExp(r'[A-Z]')
                        .hasMatch(setNewPasswordController.text),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  StrongPasswordCheck(
                    title: "use of small letter",
                    isValid: RegExp(r'[a-z]')
                        .hasMatch(setNewPasswordController.text),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  StrongPasswordCheck(
                    title: "use of symbol",
                    isValid: RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                        .hasMatch(setNewPasswordController.text),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextField(
                    isObscure: isEyeClicked ? false : true,
                    controller: confirmSetNewPasswordController,
                    onChange: (value) {
                      setState(() {});
                    },
                    hintText: "Confirm password",
                    prefixIcon: SizedBox(
                        height: 10,
                        width: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Image.asset(
                            "images/lock-outlined.png",
                            color: Colors.grey,
                          ),
                        )),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isEyeClicked = !isEyeClicked;
                        });
                      },
                      icon: SizedBox(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          isEyeClicked
                              ? AppIcons.eyeCloseIcon
                              : AppIcons.eyeOpenIcon,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  CustomButtonOne(
                    title: "Finish",
                    onClick: () {
                      if (setNewPasswordController.text.trim().isNotEmpty &&
                          confirmSetNewPasswordController.text
                              .trim()
                              .isNotEmpty &&
                          setNewPasswordController.text.trim().isNotEmpty ==
                              confirmSetNewPasswordController.text
                                  .trim()
                                  .isNotEmpty &&
                          isPasswordValid()) {
                        _verifyAndResetPassword(context, widget.email,
                            widget.otp, setNewPasswordController.text.trim());
                      } else {
                        showSnackBar(
                          context: context,
                          message:
                              "Please make sure to provide matching passwords",
                          title: "Password Required",
                        );
                      }
                    },
                    isLoading: isLoading ? true : false,
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              child: const Center(
                  child: CustomLoader(
                      colors: Color(AppColors.primaryColor), maxSize: 50)),
            )
        ],
      ),
    );
  }
}
