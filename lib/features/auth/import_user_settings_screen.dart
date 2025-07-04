import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../state_management/shared_preference_provider.dart';
import '../../state_management/shared_preference_services.dart';
import '../../utilities/components/animated_text_widget.dart';
import '../../utilities/components/custom_bottom_nav/custom_bottom_navigation_bar.dart';
import '../../utilities/components/radar_glow_indicator.dart';
import '../../utilities/constants/app_colors.dart';
import '../../utilities/constants/app_icons.dart';
import '../../utilities/shape_morphing_container.dart';
import '../../utilities/themes/theme_provider.dart';
import '../profile/model/user_model.dart';

enum SettingsType {
  theme,
  security,
  notifications,
  social,
  privacy,
  personalization,
}

class ImportUserSettingsScreen extends StatefulWidget {
  const ImportUserSettingsScreen({super.key});

  @override
  State<ImportUserSettingsScreen> createState() => _ImportUserSettingsScreenState();
}

class _ImportUserSettingsScreenState extends State<ImportUserSettingsScreen> {
  bool _isLoading = true;
  SettingsType _currentSetting = SettingsType.theme;

  @override
  void initState() {
    super.initState();
    _restoreUserSettings();
  }

  Future<void> _restoreUserSettings() async {
    SharedPreferencesService sharedPreferencesService = await SharedPreferencesService.getInstance();
    UserModel? userModel = await sharedPreferencesService.getUserModel();

    if (userModel != null) {
      SharedPreferencesProvider sharedPreferencesProvider = Provider.of<SharedPreferencesProvider>(context, listen: false);
      ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      // Restore user settings
      setState(() => _currentSetting = SettingsType.notifications);
      await sharedPreferencesProvider.saveNotificationSettingsFromUserModel(userModel);

      setState(() => _currentSetting = SettingsType.theme);
      await sharedPreferencesProvider.saveIsDarkMode(userModel.userSettings.isDarkMode);
      themeProvider.setThemeMode(userModel.userSettings.isDarkMode);

      setState(() => _currentSetting = SettingsType.security);
      await sharedPreferencesProvider.saveExtraSecurity(userModel.extraSecurity);
      await sharedPreferencesProvider.savePassCodeLock(userModel.userSettings.passCodeLock);

      // Add more settings restoration here...
    }

    setState(() {
      _isLoading = false;
    });

    Future.delayed(const Duration(seconds: 15), () async {

      // Navigate to the next screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        // builder: (context) => BottomNavigationSection(),
        builder: (context) => CustomBottomNavigationBar(),
      ));
    });

  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Stack(
          children: [
            Center(child: EndlessShapeMorphingContainer()),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle
                  ),
                  child: Center(
                    child: Icon(IconlyBold.profile, color: Colors.grey.withOpacity(0.8), size: 22,),
                  ),
                ),
                const SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedTextWidget(
                      texts: ['Restoring Your Account', 'We Are Almost Done.☺️'],
                      textDuration: Duration(seconds: 2),
                      animationDuration: Duration(milliseconds: 800),
                      textStyle: TextStyle(fontSize: 13, color: themeProvider.isDarkMode ? null : Color(AppColors.primaryColor), fontWeight: FontWeight.w500),
                      beginOffset: Offset(0, 1.0),
                      endOffset: Offset.zero,
                    ),
                    const SizedBox(width: 10,),
                    RadarCircleIndicator(
                      size: 8,
                      color: Color(AppColors.primaryColor),
                      animationSpeed: 3,
                      circleCount: 5,
                    )
                  ],
                ),
                AnimatedTextWidget(
                  texts: ['Notifications Settings', 'Social Settings', 'Privacy Settings', 'Personalization Settings', 'Security Settings', 'Carts', 'Wishlist', 'Notifications', 'Profile', 'Account settings', 'Importing Data', 'Finishing Up'],
                  textDuration: Duration(seconds: 2),
                  animationDuration: Duration(milliseconds: 800),
                  textStyle: TextStyle(fontSize: 10, color: themeProvider.isDarkMode ? null : Color(AppColors.primaryColor), fontWeight: FontWeight.w500),
                  beginOffset: Offset(0, 0.5),
                  endOffset: Offset.zero,
                ),
                const SizedBox(height: 10,),
                Text("Setting up your account—it’ll be like you never left.", style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey
                ),),
                const Spacer(),
                SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(AppIcons.nomadTechLogo, color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.8) : Color(AppColors.primaryColor).withOpacity(0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}