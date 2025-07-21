import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_loader.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../service/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final forgotPasswordEmailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  Future<void> _requestOTP(BuildContext context, String email) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _authService.resetPassword(context, email);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context: context, message: "$e", title: "Something Went Wrong");
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
              leading: AppBarBackArrow(onClick: (){
                Navigator.pop(context);
              },),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Password Recovery",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  const Text(
                    "Please enter your email to recover your password",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12
                    ),
                  ),
                  const SizedBox(height: 10,),
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
                        controller: forgotPasswordEmailController,
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
                  const Spacer(),
                  CustomButtonOne(title: "Recover Password", onClick: (){
                    if (forgotPasswordEmailController.text.trim().isNotEmpty) {
                      _requestOTP(context, forgotPasswordEmailController.text.trim());
                    } else {
                      try {
                        showSnackBar(context: context, message: "Please make sure to provide a registered email address", title: "Email Required");
                      } catch (e, s) {
                        print(s);
                      }
                    }
                  }, isLoading: isLoading ? true : false,)
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.0)
              ),
              child: const Center(child: CustomLoader(colors: Color(AppColors.primaryColor), maxSize: 50)),
            )
        ],
      ),
    );
  }
}
