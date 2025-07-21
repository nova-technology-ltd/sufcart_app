import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/auth/login/screens/login_screen.dart';
import 'package:sufcart_app/features/auth/registration/screens/registration_screen.dart';
import 'package:sufcart_app/features/auth/service/google_sign_in_service.dart';
import 'package:sufcart_app/features/welcome/component/onboarding_dynamic_image_card.dart';
import 'package:sufcart_app/utilities/components/custom_button_one.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import 'package:sufcart_app/utilities/constants/app_icons.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await _googleSignInService.signInWithGoogle(context);
    } catch (e) {
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            OnboardingDynamicImageCard(image: "onb_01.jpg", isCircle: false, height: 100, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_02.jpg", isCircle: false, height: 50, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_03.jpg", isCircle: false, height: 150, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_04.jpg", isCircle: false, height: 80, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_05.jpg", isCircle: false, height: 100, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_15.jpg", isCircle: false, height: 50, width: 80,),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            OnboardingDynamicImageCard(image: "onb_11.jpg.jpg", isCircle: false, height: 50, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_08.jpg", isCircle: false, height: 80, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_09.jpg", isCircle: false, height: 100, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_10.jpg", isCircle: false, height: 50, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_07.jpg", isCircle: false, height: 150, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_12.jpg", isCircle: false, height: 100, width: 80,),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            OnboardingDynamicImageCard(image: "onb_13.jpg", isCircle: false, height: 100, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_14.jpg", isCircle: false, height: 50, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_16.jpg", isCircle: false, height: 50, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_06.jpg", isCircle: false, height: 150, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_17.jpg", isCircle: false, height: 80, width: 80,),
                            const SizedBox(height: 5,),
                            OnboardingDynamicImageCard(image: "onb_18.jpg", isCircle: false, height: 100, width: 80,),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(AppColors.primaryColorDarkMode).withOpacity(0.2) : Colors.white.withOpacity(0.2)
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Color(AppColors.primaryColorDarkMode).withOpacity(0.8) : Colors.white.withOpacity(0.8),
                    offset: Offset(3, 4),
                    blurRadius: 50,
                    spreadRadius: 20
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Built for Bonds, Designed for Deals",
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      Text(
                        "SufCart connects you with the people you trust and the products you love — all in one vibrant social marketplace.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      const SizedBox(height: 5,),
                      CustomButtonOne(title: "Sign In", onClick: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                      }, isLoading: false),
                      const SizedBox(height: 5,),
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4)),)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              "Or don't have an account?",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4)),)),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: MaterialButton(
                          onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegistrationScreen()));
                          },
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 25,
                                  width: 25,
                                  child: Image.asset(AppIcons.emailOption,)),
                              const SizedBox(width: 5,),
                              Text(
                                "Sign Up with Email",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4)),)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              "SignUp or SignIn",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4)),)),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: MaterialButton(
                          onPressed: () => _signInWithGoogle(context),
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 23,
                                  width: 23,
                                  child: Image.asset(AppIcons.googleOption)),
                              const SizedBox(width: 5,),
                              Text(
                                "Use Google",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
