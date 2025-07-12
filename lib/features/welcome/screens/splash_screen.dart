import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utilities/components/dot_loader.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/constants/app_icons.dart';
import '../../../utilities/constants/app_strings.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../../auth/login/screens/login_screen.dart';
import '../../auth/service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool isFailed = false;
  @override
  void initState() {
    super.initState();
    _checkConnectionAndProceed();
  }


  Future<void> _checkConnectionAndProceed() async {
    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
        Future.delayed(const Duration(seconds: 2), () async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString("Authorization");
          if (token == null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          } else {
            try {
              setState(() {
                isLoading = true;
                isFailed = false;
              });
              await _authService.checkIfUserIsLoggedIn(context);
              setState(() {
                isLoading = false;
                isFailed = false;
              });
            } catch (e) {
              setState(() {
                isLoading = false;
                isFailed = false;
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            }
          }
        });
      } else if (connectivityResult.contains(ConnectivityResult.none)) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
        showSnackBar(context: context, message: "You are currently not connected to the internet, please connect to an internet and try again. Thank You.", title: "No Internet Connection");
      } else {
        print("Connected to another network type");
      }
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  // @override
  // void dispose() {
  //   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //       systemNavigationBarColor: Colors.white,
  //       systemNavigationBarIconBrightness: Brightness.dark
  //   ));
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              height: 65,
                width: 65,
                child: Image.asset(AppIcons.koradLogo, color: themeProvider.isDarkMode ? Colors.white : Color(AppColors.primaryColor))),
            const SizedBox(height: 5,),
            isLoading ? ProgressiveDotLoader(
              dotCount: 4,
              dotSize: 8.0,
              dotSpacing: 4.0,
              activeColor: themeProvider.isDarkMode ? Colors.white : Color(AppColors.primaryColor),
              inactiveColor: themeProvider.isDarkMode ? Colors.white.withOpacity(0.2) : Color(AppColors.primaryColor).withOpacity(0.2),
              duration: const Duration(milliseconds: 1500),
            ) : const SizedBox.shrink(),
            const Spacer(),
            SizedBox(
              height: 100,
                width: 100,
                child: Image.asset(AppIcons.nomadTechLogo, color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.8) : Color(AppColors.primaryColor).withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
