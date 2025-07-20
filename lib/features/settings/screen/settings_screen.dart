import 'package:flutter/cupertino.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/notification/service/notification_service.dart';
import 'package:sufcart_app/utilities/components/custom_button_one.dart';
import '../../../state_management/shared_preference_provider.dart';
import '../../../utilities/components/app_bar_back_arrow.dart';
import '../../../utilities/components/custom_check_bok.dart';
import '../../../utilities/components/custom_loader.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/constants/app_icons.dart';
import '../../../utilities/constants/app_strings.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../../auth/service/auth_service.dart';
import '../../profile/help_center/screens/terms_and_condition.dart';
import '../../profile/model/user_model.dart';
import '../../profile/model/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../account_settings/screens/notification_settings_screen.dart';
import '../account_settings/screens/profile_settings.dart';
import '../account_settings/screens/verify_email.dart';
import '../components/settings_option_card.dart';
import '../security_settings/screens/account_pin_screen.dart';
import '../security_settings/screens/change_password_screen.dart';
import '../security_settings/screens/extra_security_screen.dart';
import '../service/settings_services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final webUrl = Uri.parse("https://www.youtube.com/");
  AuthService authService = AuthService();
  bool isLoading = false;
  bool extraSecurity = false;

  String getTimeZone() {
    Duration offset = DateTime.now().timeZoneOffset;
    int hours = offset.inHours;
    int minutes = offset.inMinutes.remainder(60);

    String sign = hours >= 0 ? '+' : '-';
    String formattedTimeZone =
        "GMT$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.abs().toString().padLeft(2, '0')}";

    return formattedTimeZone;
  }

  final SettingsServices _settingsServices = SettingsServices();
  final NotificationService _notificationService = NotificationService();

  Future<void> _registerNotification(BuildContext context) async {
    try {

    } catch (e) {
      print(e);
    }
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
        extraSecurity = user.extraSecurity;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _enableOrDisableExtraSecurity(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _settingsServices.enableOrDisableExtraSecurity(context);
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
  Future<void> _darkModeOrLightMode({required BuildContext context, required bool isDarkMode}) async {
    try {
      Map<String, dynamic> updates = {
        "isDartMode": isDarkMode
      };
      await authService.updateAccountPersonalization(context, updates);
      await authService.userProfile(context);
    } catch (e) {
      showSnackBar(
        context: context,
        message: "Sorry, but we are unable to complete your request at the moment, please try again later. Thank You",
        title: "Something Went Wrong",
      );
    }
  }
  void logUserOut(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await authService.logOut(context);
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
    final user = Provider.of<UserProvider>(context).userModel;
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
              title: const Text(
                "Settings",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: AppBarBackArrow(
                onClick: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account Settings",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    SettingsOptionCard(
                      icon: Icons.person,
                      title: "Profile",
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => ProfileSettings(userInfo: user),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 35,
                      width: MediaQuery.of(context).size.width,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Padding(
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
                                      child: Center(
                                        child: Icon(
                                          Icons.mail,
                                          size: 16,
                                          color:
                                              themeProvider.isDarkMode
                                                  ? Colors.white.withOpacity(
                                                    0.6,
                                                  )
                                                  : const Color(
                                                    AppColors.primaryColor,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Verify Account Email",
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
                                user.isEmailVerified
                                    ? Container(
                                      height: 15,
                                      width: 15,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 8,
                                        ),
                                      ),
                                    )
                                    : Container(
                                      height: 15,
                                      width: 15,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "!",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: MaterialButton(
                              onPressed:
                                  user.isEmailVerified
                                      ? () {
                                        showSnackBar(
                                          context: context,
                                          message:
                                              "Your account email is already verified",
                                          title: "Email Verified",
                                        );
                                      }
                                      : () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => VerifyEmail(
                                                  email: user.email,
                                                ),
                                          ),
                                        );
                                      },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Image.asset(
                                              AppIcons
                                                  .notificationSettingsIcons,
                                              color:
                                                  themeProvider.isDarkMode
                                                      ? Colors.white
                                                          .withOpacity(0.6)
                                                      : const Color(
                                                        AppColors.primaryColor,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Notification Settings",
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
                                  const Icon(
                                    Icons.arrow_right_alt,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const NotificationSettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Security Settings",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    SettingsOptionCard(
                      icon: Icons.password,
                      title: "Change Password",
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsOptionCard(
                      icon: Icons.pin,
                      title: "Account PIN",
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AccountPinScreen(),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap:
                      sharedPreferencesProvider.extraSecurity
                          ?  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ExtraSecurityScreen(),
                                  ),
                                );
                              }
                              : () {
                                showSnackBar(
                                  context: context,
                                  message:
                                      "Please make sure to turn on the option before attempting to enter",
                                  title: "Turn On Extra Security First",
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
                                    child: Center(
                                      child: Icon(
                                        Icons.mail,
                                        size: 16,
                                        color:
                                            themeProvider.isDarkMode
                                                ? Colors.white.withOpacity(0.6)
                                                : const Color(
                                                  AppColors.primaryColor,
                                                ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Enable Extra Security",
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
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: CupertinoSwitch(
                                      activeColor: const Color(
                                        AppColors.primaryColor,
                                      ),
                                      value: sharedPreferencesProvider.extraSecurity,
                                      onChanged: (value) {
                                        sharedPreferencesProvider.saveExtraSecurity(value);
                                        _enableOrDisableExtraSecurity(context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "System System",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    SettingsOptionCard(
                      icon: Icons.scale_rounded,
                      title: "Terms & Condition",
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TermsAndCondition(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: Center(
                                child: SizedBox(
                                  height: 15,
                                  child: Icon(Icons.language, size: 14, color: Color(AppColors.primaryColor)
                                ),
                              ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Language",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                themeProvider.isDarkMode
                                    ? null
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                  color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(360)
                              ),
                              child: !themeProvider.isDarkMode ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 5),
                                child: RichText(text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "Default: ",
                                          style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          )
                                      ),
                                      TextSpan(
                                          text: "English",
                                          style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.black
                                          )
                                      ),
                                    ]
                                )),
                              ) : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                                child: Text("Dark", style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: Center(
                                child: SizedBox(
                                  height: 15,
                                  child: Icon(IconlyBold.time_circle, size: 14, color: Color(AppColors.primaryColor),)
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Time Zone",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                themeProvider.isDarkMode
                                    ? null
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                  color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(360)
                              ),
                              child: !themeProvider.isDarkMode ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 5),
                                child: RichText(text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "Default: ",
                                          style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          )
                                      ),
                                      TextSpan(
                                          text: "${getTimeZone()}",
                                          style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.black
                                          )
                                      ),
                                    ]
                                )),
                              ) : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                                child: Text("Dark", style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      // height: 45,
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
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      child: Center(
                                        child: SizedBox(
                                          height: 15,
                                          child: Image.asset(
                                            AppIcons.paintBrush,
                                            color:
                                                themeProvider.isDarkMode
                                                    ? Colors.white
                                                    : Color(AppColors.primaryColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Personalization",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            themeProvider.isDarkMode
                                                ? null
                                                : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(360)
                                      ),
                                      child: !themeProvider.isDarkMode ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 5),
                                        child: RichText(text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "Default: ",
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  )
                                              ),
                                              TextSpan(
                                                  text: "Light",
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.black
                                                  )
                                              ),
                                            ]
                                        )),
                                      ) : Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                                        child: Text("Dark", style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                                        child: Center(
                                          child: Icon(
                                            themeProvider.isDarkMode
                                                ? Icons.nightlight_round
                                                : Icons.wb_sunny,
                                            color:
                                            themeProvider.isDarkMode
                                                ? Colors.white
                                                : Color(AppColors.primaryColor),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "App Theme",
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
                                      child: Transform.scale(
                                        scale: 0.8,
                                        child: CupertinoSwitch(
                                          activeColor: const Color(
                                            AppColors.primaryColor,
                                          ),
                                          value: themeProvider.isDarkMode,
                                          onChanged: (value) {
                                            themeProvider.toggleTheme();
                                            _darkModeOrLightMode(context: context, isDarkMode: value);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5,),
                            Row(
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
                                      child: Center(
                                        child: Icon(
                                          Icons.phone_android_rounded,
                                          color:
                                          themeProvider.isDarkMode
                                              ? Colors.white
                                              : Color(AppColors.primaryColor),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Use System Default",
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: SizedBox(
                                    child: Center(
                                      child: CustomCheckbox(
                                        value: themeProvider.useSystemDefault,
                                        onChanged: (value) {
                                          themeProvider.setSystemDefault(value ?? false);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5,),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SettingsOptionCard(
                      icon: Icons.web,
                      title: "Visit Our Website",
                      onClick:
                          () => setState(() {
                            launchUrl(
                              webUrl,
                              mode: LaunchMode.externalApplication,
                            );
                          }),
                    ),
                    const SizedBox(height: 10),
                    SettingsOptionCard(
                      icon: Icons.power_settings_new_rounded,
                      color: Colors.red,
                      title: "Logout",
                      onClick: () => logUserOut(context),
                    ),
                    const SizedBox(height: 50),
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
