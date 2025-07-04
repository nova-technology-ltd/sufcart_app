import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';

class ProfileUpdateSuccessScreen extends StatefulWidget {
  const ProfileUpdateSuccessScreen({super.key});

  @override
  State<ProfileUpdateSuccessScreen> createState() => _ProfileUpdateSuccessScreenState();
}

class _ProfileUpdateSuccessScreenState extends State<ProfileUpdateSuccessScreen> {
  final AuthService _authService = AuthService();
  @override
  void initState() {

    _authService.userProfile(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryColor).withOpacity(0.8),
                shape: BoxShape.circle
              ),
              child: const Center(
                child: Icon(Icons.check, color: Colors.white,),
              ),
            ),
            const SizedBox(height: 10,),
            const Text(
              "Profile Updated",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            ),
            const Text(
              "You have successfully updated your profile information",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey
              ),
            ),
            const Spacer(),
            CustomButtonOne(title: "Done", onClick: (){
              Navigator.pop(context);
              Navigator.pop(context);
            }, isLoading: false,)
          ],
        ),
      ),
    );
  }
}
