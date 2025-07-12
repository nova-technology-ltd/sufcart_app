import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/settings/security_settings/screens/security_questions_screen.dart';

import '../../../../state_management/shared_preference_provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_loader.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';
import '../../../profile/model/user_model.dart';
import '../../components/settings_option_card.dart';
import '../../service/settings_services.dart';

class ExtraSecurityScreen extends StatefulWidget {
  const ExtraSecurityScreen({super.key});

  @override
  State<ExtraSecurityScreen> createState() => _ExtraSecurityScreenState();
}

class _ExtraSecurityScreenState extends State<ExtraSecurityScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isLoginWithAccountPINEnabled = false;
  String _authStatus = "Not Authenticated";
  final SettingsServices _settingsServices = SettingsServices();
  AuthService authService = AuthService();
  bool isLoading = false;

  Future<void> _requestPermission() async {
    // var status = await Permission.microphone.request();
    // if (status.isGranted) {
    //   // Permission granted, proceed with speech recognition
    //   _authenticate();
    // } else if (status.isDenied) {
    //   // Permission denied, show message to the user
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content:
    //             Text("Microphone permission is required to use voice search.")),
    //   );
    // } else if (status.isPermanentlyDenied) {
    //   // Permission permanently denied, redirect to app settings
    //   openAppSettings();
    // }
  }

  @override
  void initState() {
    super.initState();
    authService.userProfile(context).then((user) {
      setInitialValues(user);
    });
  }

  void setInitialValues(UserModel? user) {
    if (user != null) {
      setState(() {
        isLoginWithAccountPINEnabled = user.userSettings.passCodeLock;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _authenticate() async {
    try {
      await _requestPermission();
      // Check if biometrics are available
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final availableBiometrics = await auth.getAvailableBiometrics();

      print("Can check biometrics: $canCheckBiometrics");
      print("Available biometrics: $availableBiometrics");

      if (!canCheckBiometrics) {
        setState(() {
          _authStatus =
              "Biometric authentication not available on this device.";
        });
        return;
      }

      // Perform the authentication
      print("Attempting to authenticate...");
      final authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      print("Authentication result: $authenticated");

      setState(() {
        _authStatus =
            authenticated
                ? "Authentication Successful"
                : "Authentication Failed";
      });
    } catch (e) {
      setState(() {
        _authStatus = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _enableOrDisableLoginWithAccountPIN(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _settingsServices.enableOrDisableLoginWithAccountPIN(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context: context,
        message:
            "Sorry, but we are unable to complete your request at the moment, please try again later. Thank You",
        title: "Something Went Wrong",
      );
    }
  }

  // final LocalAuthentication auth = LocalAuthentication();
  // bool _canCheckBiometrics = false;
  // String _authorized = "Not Authorized";
  // @override
  // void initState() {
  //   super.initState();
  //   _checkBiometrics(context);
  // }
  // Future<void> _checkBiometrics(BuildContext context) async {
  //   print("Called");
  //   try {
  //     final canCheck = await auth.canCheckBiometrics;
  //     setState(() {
  //       _canCheckBiometrics = canCheck;
  //     });
  //   } catch (e) {
  //     print("Error checking biometrics: $e");
  //   }
  // }
  // Future<void> _authenticate() async {
  //   try {
  //     final authenticated = await auth.authenticate(
  //       localizedReason: 'Scan your fingerprint to authenticate',
  //       options: const AuthenticationOptions(
  //         biometricOnly: true,
  //         stickyAuth: true,
  //       ),
  //     );
  //     setState(() {
  //       _authorized = authenticated ? "Authorized" : "Not Authorized";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _authorized = "Error: $e";
  //     });
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sharedPreferencesProvider = Provider.of<SharedPreferencesProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            appBar: AppBar(
              backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              leadingWidth: 90,
              leading: AppBarBackArrow(
                onClick: () {
                  Navigator.pop(context);
                },
              ),
              centerTitle: true,
              title: const Text(
                "Extra Security",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    SettingsOptionCard(
                      icon: Icons.tips_and_updates_rounded,
                      title: "Add Security Questions",
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => const SecurityQuestionsScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsOptionCard(
                      icon: Icons.fingerprint,
                      title: "Biometrics",
                      onClick: _authenticate,
                    ),
                    GestureDetector(
                      onTap: () {
                        showSnackBar(
                          context: context,
                          message:
                              "Increase your account security by login in all the time with your account PIN",
                          title: "Login With Account PIN",
                        );
                      },
                      child: Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        AppColors.primaryColor,
                                      ).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.mail,
                                        size: 16,
                                        color: Color(AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Login With Account PIN",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          themeProvider.isDarkMode
                                              ? null
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                child: Center(
                                  child: CupertinoSwitch(
                                    activeColor: const Color(
                                      AppColors.primaryColor,
                                    ),
                                    value: sharedPreferencesProvider.passCodeLock,
                                    onChanged: (value) {
                                      sharedPreferencesProvider.savePassCodeLock(value);
                                      _enableOrDisableLoginWithAccountPIN(
                                        context,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CupertinoActivityIndicator(),
            ),
        ],
      ),
    );
  }
}
