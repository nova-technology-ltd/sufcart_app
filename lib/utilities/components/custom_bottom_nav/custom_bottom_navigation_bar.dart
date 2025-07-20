import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/follows/screens/my_social_profile_screen.dart';
import '../../../features/community/follows/screens/users_screen.dart';
import '../../../features/community/messages/data/provider/messages_socket_provider.dart';
import '../../../features/community/messages/presentations/screens/talks_screen.dart';
import '../../../features/community/screen/community_screen.dart';
import '../../../features/notification/screens/notification_screens.dart';
import '../../../features/profile/model/user_provider.dart';
import '../../../features/profile/screens/profile_screen.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../socket/socket_config.dart';
import '../../socket/socket_config_provider.dart';
import '../../themes/theme_provider.dart';
import 'components/custom_bottom_nav_item.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final SocketConfigService _socketConfig = SocketConfigService();
  final navScreens = [
    const CommunityScreen(),
    const TalksScreen(),
    const NotificationScreens(),
    const UsersScreen(),
    const MySocialProfileScreen(),
  ];
  int currentScreen = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketProvider = context.read<SocketConfigProvider>();
      if (!socketProvider.isConnected) {
        print('Socket not connected on init, waiting for connection...');
      }
    });
    super.initState();
  }

  int _getTotalUnreadMessages(
      {required MessagesSocketProvider messagesProvider, required String userID}) {
    return messagesProvider.getTotalUnreadMessages(currentUserID: userID);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = Provider.of<UserProvider>(context).userModel;
    final messagesProvider = Provider.of<MessagesSocketProvider>(context);
    final totalUnread = _getTotalUnreadMessages(messagesProvider: messagesProvider, userID: user.userID,);

    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      body: navScreens[currentScreen],
      bottomNavigationBar: Container(
        height: 55,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: CustomBottomNavItem(
                title: "Community",
                icon: currentScreen == 0 ? AppIcons.communitySelectedIcon : AppIcons.communityUnselectedIcon,
                position: 0,
                index: currentScreen,
                onTap: () => setState(() => currentScreen = 0),
              ),
            ),
            Expanded(
              child: MaterialButton(
                onPressed: () => setState(() => currentScreen = 1),
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 22,
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  currentScreen == 1 ? CupertinoIcons.chat_bubble_2_fill : CupertinoIcons.chat_bubble_2,
                                  color: currentScreen == 1 ? Color(AppColors.primaryColor) : Colors.grey,
                                ),
                              ),
                              if (totalUnread > 0)
                                Positioned(
                                  right: totalUnread > 99 ? 15 : 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(360),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                                      child: Text(
                                        totalUnread.toString(),
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (currentScreen == 1)
                          Text(
                            "Talks",
                            style: TextStyle(
                              color: currentScreen == 1 ? Color(AppColors.primaryColor) : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: CustomBottomNavItem(
                title: "Notification",
                icon: currentScreen == 2 ? AppIcons.bellSelected : AppIcons.bellUnselected,
                position: 2,
                index: currentScreen,
                onTap: () => setState(() => currentScreen = 2),
              ),
            ),
            Expanded(
              child: CustomBottomNavItem(
                title: "People",
                icon: currentScreen == 3 ? AppIcons.profileSelected : AppIcons.profileUnselected,
                position: 3,
                index: currentScreen,
                onTap: () => setState(() => currentScreen = 3),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => currentScreen = 4),
                child: Container(
                  height: 35,
                  width: 35,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.2),
                    border: Border.all(color: currentScreen == 4 ? const Color(AppColors.primaryColor) : Colors.transparent),
                  ),
                  child: Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: user.image == ""
                          ? Container(
                        height: 100,
                        width: 100,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(IconlyBold.profile, color: Colors.grey, size: 18),
                        ),
                      )
                          : Image.network(
                        user.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, st) {
                          return const Icon(IconlyBold.profile, size: 18, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}