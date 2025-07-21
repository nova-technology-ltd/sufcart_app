import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_loader.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/components/strong_password_check.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_fonts.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final setNewPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final confirmSetNewPasswordController = TextEditingController();
  bool isEyeClicked = false;
  AuthService authService = AuthService();
  bool isLoading = false;

  bool isPasswordValid() {
    // Password criteria checks
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

  Future<void> startPasswordUpdate(
      BuildContext context, String oldPassword, String newPassword) async {
    try {
      setState(() {
        isLoading = true;
      });
      await authService.updatePassword(context, oldPassword, newPassword);
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
              backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              leadingWidth: 90,
              title: const Text(
                "Change Password",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  CustomTextField(
                    isObscure: isEyeClicked ? false : true,
                    controller: oldPasswordController,
                    hintText: "Old Password",
                    prefixIcon: null,
                    outlineInputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5)
                    ),
                    outlineFocusInputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(AppColors.primaryColor).withOpacity(0.3), width: 1.5)
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isEyeClicked = !isEyeClicked;
                          });
                        },
                        icon: Icon(
                          isEyeClicked
                              ? Icons.remove_red_eye
                              : Icons.remove_red_eye_outlined,
                          color: Colors.grey,
                        )),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextField(
                    isObscure: isEyeClicked ? false : true,
                    controller: setNewPasswordController,
                    onChange: (value) {
                      setState(() {});
                    },
                    hintText: "Enter password",
                    prefixIcon: null,
                    outlineInputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5)
                    ),
                    outlineFocusInputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(AppColors.primaryColor).withOpacity(0.3), width: 1.5)
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isEyeClicked = !isEyeClicked;
                          });
                        },
                        icon: Icon(
                          isEyeClicked
                              ? Icons.remove_red_eye
                              : Icons.remove_red_eye_outlined,
                          color: Colors.grey,
                        )),
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
                        icon: Icon(
                          isEyeClicked
                              ? Icons.remove_red_eye
                              : Icons.remove_red_eye_outlined,
                          color: Colors.grey,
                        )),
                  ),
                  const Spacer(),
                  CustomButtonOne(
                      title: "Change",
                      onClick: () {
                        if (oldPasswordController.text.trim().isNotEmpty &&
                            setNewPasswordController.text.trim().isNotEmpty &&
                            confirmSetNewPasswordController.text
                                .trim()
                                .isNotEmpty &&
                            isPasswordValid()) {
                          if (setNewPasswordController.text.trim() ==
                              confirmSetNewPasswordController.text.trim()) {
                            startPasswordUpdate(
                                context,
                                oldPasswordController.text.trim(),
                                setNewPasswordController.text.trim());
                          } else {
                            showSnackBar(
                                context: context,
                                message:
                                    "Please make sure you match the confirm password with the new password, else you cant be able to update it",
                                title: "Password Does Not Match");
                          }
                        } else {
                          showSnackBar(
                              context: context,
                              message:
                                  "Please make sure to provide all necessary information",
                              title: "Missing Fields");
                        }
                      }, isLoading: isLoading ? true : false,),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
              child: const Center(child: CustomLoader(colors: Color(AppColors.primaryColor), maxSize: 50))
            )
        ],
      ),
    );
  }
}
