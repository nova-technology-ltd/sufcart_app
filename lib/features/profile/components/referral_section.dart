import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../screens/invite_family_and_friends_screen.dart';

class ReferralSection extends StatefulWidget {
  const ReferralSection({super.key});

  @override
  State<ReferralSection> createState() => _ReferralSectionState();
}

class _ReferralSectionState extends State<ReferralSection> {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Container(
          height: 44,
          width: MediaQuery.of(context).size.width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                                color: const Color(AppColors.primaryColor)
                                    .withOpacity(0.3),
                                shape: BoxShape.circle),
                            child: Image.asset("images/STK-20240102-WA0044.webp")),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invite Friends",
                              style: TextStyle(
                                  fontSize: 14, color: themeProvider.isDarkMode ? null : Colors.black),
                            ),
                            Text(
                              "Let your friends know were all the good stuffs are",
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_right_alt,
                      color: themeProvider.isDarkMode ? null : Colors.black,
                      size: 20,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: MaterialButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InviteFamilyAndFriendsScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



