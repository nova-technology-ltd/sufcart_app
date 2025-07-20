import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../forgot_password/screens/forgot_password_screen.dart';
import '../../registration/screens/registration_screen.dart';
import '../../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isEyeClicked = true;
  bool isLoading = false;
  AuthService authService = AuthService();

  Future<void> startLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      setState(() {
        isLoading = true;
      });
      await authService.userLogin(context, email, password);
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
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "Welcome Back!",
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]),
                  ),
                  const Text(
                    "Please enter your login credentials to access your account and stay updated with the latest activities.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey
                        ),
                      ),
                      CustomTextField(
                        hintText: "e.g johndoe@gmail.com",
                        prefixIcon: null,
                        controller: emailController,
                        isObscure: false,
                        outlineInputBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5)
                        ),
                        outlineFocusInputBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(AppColors.primaryColor).withOpacity(0.3), width: 1.5)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Password",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey
                        ),
                      ),
                      CustomTextField(
                        hintText: "e.g *********",
                        prefixIcon: null,
                        outlineInputBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5)
                        ),
                        outlineFocusInputBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(AppColors.primaryColor).withOpacity(0.3), width: 1.5)
                        ),
                        controller: passwordController,
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
                            child: Image.asset( isEyeClicked ? AppIcons.eyeCloseIcon: AppIcons.eyeOpenIcon, color: Colors.grey,),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isLoading ? const SizedBox.shrink(): Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordScreen()));
                      },
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  CustomButtonOne(
                    title: "Login",
                    onClick: () {
                      FocusScope.of(context).unfocus();
                      if (emailController.text.trim().isNotEmpty && passwordController.text.trim().isNotEmpty) {
                        startLogin(context);
                      } else {
                        showSnackBar(context: context, message: "Please make sure to provide your email and password before attempting to login", title: "Missing Fields");
                      }
                    }, isLoading: isLoading ? true : false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  isLoading ? const SizedBox.shrink(): Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                      const Text(
                        " OR ",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                    ],
                  ),
                  isLoading ? const SizedBox.shrink(): const SizedBox(
                    height: 10,
                  ),
                  isLoading ? const SizedBox.shrink(): GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>  RegistrationScreen()));
                    },
                    child: RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: "Don't have an account yet? ",
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 14,
                          )),
                      TextSpan(
                          text: "SignUp",
                          style: TextStyle(
                              color: Color(AppColors.primaryColor),
                              fontSize: 14,)),
                    ])),
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
