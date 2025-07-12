import 'package:flutter/cupertino.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/auth/registration/screens/registration_success_screen.dart';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/dot_indicator.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/components/strong_password_check.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../service/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool privacyAndPolicyCheck = false;
  bool termsAndConditionsCheck = false;
  int totalPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void onPageChange(int index) {
    setState(() {
      totalPage = index;
    });
  }

  final firstNameController = TextEditingController();
  final lastNameNameController = TextEditingController();
  final otherNamesController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final conPasswordController = TextEditingController();
  final inviteCodeController = TextEditingController();
  AuthService authService = AuthService();

  bool isEyeClicked = false;

  bool isLoading = false;

  bool isAccepted = false;

  bool isPasswordValid() {
    // Password criteria checks
    bool hasMinLength = passwordController.text.length >= 6;
    bool hasDigits = RegExp(r'\d').hasMatch(passwordController.text);
    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(passwordController.text);
    bool hasLowerCase = RegExp(r'[a-z]').hasMatch(passwordController.text);
    bool hasSymbols =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(passwordController.text);

    return hasMinLength &&
        hasDigits &&
        hasUpperCase &&
        hasLowerCase &&
        hasSymbols;
  }

  Future<void> startRegistration({required BuildContext context,
    required String firstName,
    required String lastName,
    required String otherNames,
    required String phoneNumber,
    required String email,
    required String password,
    required String inviteCode,}
  ) async {
    try {
      setState(() {
        isLoading = true;
      });
      int statusCode = await authService.registerUser(
        context: context,
        firstName: firstName,
        lastName: lastName,
        otherNames: otherNames,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        inviteCode: inviteCode
      );

      if (statusCode == 200 || statusCode == 201) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => RegistrationSuccessScreen()), (route) => false);
      } else {
        setState(() {
          isLoading = false;
        });
      }
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
              automaticallyImplyLeading: false,
              leadingWidth: 90,
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        if (totalPage == i)
                          const DotIndicator(isCurrent: true)
                        else
                          const DotIndicator(isCurrent: false)
                    ],
                  ),
                ),
              ],
            ),
            body: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              onPageChanged: onPageChange,
              itemBuilder: (context, pageIndex) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pageIndex == 0) ...[
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                          const Text(
                            "Please make sure to provide your first name and last name, other names are optional.",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            hintText: "First Name",
                            prefixIcon: const Icon(IconlyLight.profile),
                            isObscure: false,
                            controller: firstNameController,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            hintText: "Last Name",
                            prefixIcon: const Icon(IconlyLight.profile),
                            isObscure: false,
                            controller: lastNameNameController,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            hintText: "Other Names(optional)",
                            prefixIcon: const Icon(IconlyLight.profile),
                            isObscure: false,
                            controller: otherNamesController,
                          ),
                        ] else if (pageIndex == 1) ...[
                          const Text(
                            "Phone Number",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                          const Text(
                            "You are expected to provide a valid phone number.",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 40,
                            child: CustomTextField(
                              hintText: "Phone Number",
                              prefixIcon: SizedBox(
                                width: 80,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 25,
                                          width: 25,
                                          child: Image.asset("images/flag_icon.jpg")),
                                      const Text(
                                        " +234", style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey
                                      ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Container(width: 1, height: 20, decoration: const BoxDecoration(
                                        color: Colors.grey
                                      ),)
                                    ],
                                  ),
                                ),
                              ),
                              isObscure: false,
                              controller: phoneNumberController,
                            ),
                          ),
                        ] else if (pageIndex == 2) ...[
                          const Text(
                            "Email Address",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                          const Text(
                            "Please be sure to provide a valid email address.",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            hintText: "Email",
                            prefixIcon: const Icon(IconlyLight.message),
                            isObscure: false,
                            controller: emailController,
                          ),
                        ] else if (pageIndex == 3) ...[
                          RichText(text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Invited By?",
                                  style: TextStyle(
                                      fontSize: 25, fontWeight: FontWeight.w400, color: themeProvider.isDarkMode ? Colors.white : Colors.black)
                              ),
                              TextSpan(
                                text: "(Optional)",
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w400, color: themeProvider.isDarkMode ? Colors.white : Colors.grey)
                              ),
                            ]
                          )),
                          const Text(
                            "Where you invited by someone? if yes, please provide the invite code below.",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            hintText: "K0O-R0A0D",
                            prefixIcon: const Icon(IconlyLight.info_square),
                            isObscure: false,
                            controller: inviteCodeController,
                          ),
                        ] else ...[
                          const Text(
                            "Account Password",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                          const Text(
                            "Provide a password that satisfies the password requirements bellow.",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            hintText: "Password",
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
                            controller: passwordController,
                            onChange: (value) {
                              setState(() {});
                            },
                            isObscure: isEyeClicked ? true : false,
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
                            isValid: passwordController.text.length >= 6,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          StrongPasswordCheck(
                            title: "use of number",
                            isValid:
                                RegExp(r'\d').hasMatch(passwordController.text),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          StrongPasswordCheck(
                            title: "use of capital letter",
                            isValid: RegExp(r'[A-Z]')
                                .hasMatch(passwordController.text),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          StrongPasswordCheck(
                            title: "use of small letter",
                            isValid: RegExp(r'[a-z]')
                                .hasMatch(passwordController.text),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          StrongPasswordCheck(
                            title: "use of symbol",
                            isValid: RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                .hasMatch(passwordController.text),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            hintText: "Confirm Password",
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
                            controller: conPasswordController,
                            isObscure: isEyeClicked ? true : false,
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
                          const SizedBox(height: 25,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){},
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                      text: "By registering you are agreeing to our",
                                      style: TextStyle(
                                        color: termsAndConditionsCheck
                                            ? Colors.black
                                            : Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                    TextSpan(
                                      text: "\nTerms and Conditions",
                                      style: TextStyle(
                                        color: termsAndConditionsCheck
                                            ? const Color(AppColors.primaryColor)
                                            : const Color(AppColors.primaryColor).withOpacity(0.5),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500
                                      ),
                                    )
                                  ])),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  activeColor: const Color(AppColors.primaryColor),
                                    value: termsAndConditionsCheck, onChanged: (value) {
                                  setState(() {
                                    termsAndConditionsCheck = value;
                                  });
                                }),
                              )
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){},
                                  child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: "You've read and understood our",
                                          style: TextStyle(
                                              color: privacyAndPolicyCheck
                                                  ? Colors.black
                                                  : Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        TextSpan(
                                          text: "\nPrivacy, Policy",
                                          style: TextStyle(
                                              color: privacyAndPolicyCheck
                                                  ? const Color(AppColors.primaryColor)
                                                  : const Color(AppColors.primaryColor).withOpacity(0.5),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500
                                          ),
                                        )
                                      ])),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                    activeColor: const Color(AppColors.primaryColor),
                                    value: privacyAndPolicyCheck, onChanged: (value) {
                                  setState(() {
                                    privacyAndPolicyCheck = value;
                                  });
                                }),
                              )
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button (only visible when not on the first page)
                  if (totalPage > 0)
                    isLoading
                        ? const SizedBox.shrink()
                        : Expanded(
                            flex: 3,
                            child: CustomButtonOne(
                                color: Colors.grey[300],
                                corner: 50,
                                textColor: Colors.black,
                                title: "Previous",
                                onClick: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                                isLoading: isLoading ? true : false)),
                  isLoading
                      ? const SizedBox.shrink()
                      : totalPage == 0
                          ? const SizedBox.shrink()
                          : const SizedBox(
                              width: 10,
                            ),
                  // Next Button
                  Expanded(
                    flex: 8,
                    child: CustomButtonOne(
                        title: totalPage < 4 ? "Next" : "Register",
                        onClick: totalPage < 4
                            ? () {
                                FocusScope.of(context).unfocus();
                                if (totalPage < 4) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                }
                              }
                            : () {
                                FocusScope.of(context).unfocus();
                                if (passwordController.text.trim() ==
                                        conPasswordController.text.trim() &&
                                    isPasswordValid() && privacyAndPolicyCheck == true && termsAndConditionsCheck == true) {
                                  startRegistration(
                                      context: context,
                                      firstName: firstNameController.text.trim(),
                                      lastName: lastNameNameController.text.trim(),
                                      otherNames: otherNamesController.text.trim(),
                                      phoneNumber: phoneNumberController.text.trim(),
                                      email: emailController.text.trim(),
                                      inviteCode: inviteCodeController.text.trim(),
                                      password: passwordController.text.trim());
                                } else {
                                  showSnackBar(
                                      context: context,
                                      message:
                                          "Please make sure you provide a valid information",
                                      title: "Invalid Information");
                                }
                              },
                        isLoading: isLoading ? true : false),
                  )
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.01)),
            )
        ],
      ),
    );
  }
}
