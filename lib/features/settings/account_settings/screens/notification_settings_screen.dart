import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../state_management/shared_preference_provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';
import '../../../notification/service/notification_service.dart';
import '../../service/settings_services.dart';
import '../components/notification_settings_option.dart';


class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final SettingsServices _settingsServices = SettingsServices();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sharedPreferencesProvider = Provider.of<SharedPreferencesProvider>(context, listen: false);
    if (sharedPreferencesProvider.cachedUser == null) {
      final user = await _authService.userProfile(context);
      if (user != null) {
        sharedPreferencesProvider.cacheUser(user);
        final areSettingsDifferent = await sharedPreferencesProvider.areNotificationSettingsDifferent(user);
        if (areSettingsDifferent) {
          await sharedPreferencesProvider.saveNotificationSettingsFromUserModel(user);
        }
      }
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _toggleSetting(String settingType) async {
    final sharedPreferencesProvider = Provider.of<SharedPreferencesProvider>(context, listen: false);
    final currentValue = sharedPreferencesProvider.notificationSettings[settingType] ?? true;
    await sharedPreferencesProvider.updateNotificationSetting(settingType, !currentValue);
    await _settingsServices.toggleNotificationSetting(context, settingType);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sharedPreferencesProvider = Provider.of<SharedPreferencesProvider>(context);
    final notificationSettings = sharedPreferencesProvider.notificationSettings;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        leadingWidth: 90,
        title: const Text(
          "Notification Settings",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: AppBarBackArrow(onClick: () {
          Navigator.pop(context);
        }),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "E-Commerce Notifications",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              NotificationSettingsOption(
                title: "Cart Notifications",
                switchValue: notificationSettings['cartNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("cartNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.cartNotificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All cart activities related notification',
              ),
              NotificationSettingsOption(
                title: "Order Notifications",
                switchValue: notificationSettings['orderNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("orderNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.orderNotificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All order activities related notification',
              ),
              NotificationSettingsOption(
                title: "Wishlist Notifications",
                switchValue: notificationSettings['wishlistNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("wishlistNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.wishlistNotificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All wishlist activities related notification',
              ),
              NotificationSettingsOption(
                title: "New Items Notifications",
                switchValue: notificationSettings['newItemsNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("newItemsNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.incomingMessageIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'Notifications on all new items that come into the market',
              ),

              const SizedBox(height: 10),
              const Text(
                "Billing Notification",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              NotificationSettingsOption(
                title: "Credit Alert Email Notifications",
                switchValue: notificationSettings['creditAlertEmailNotification'] ?? false,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("creditAlertEmailNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.emailAlertIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All wishlist activities related notification',
              ),
              NotificationSettingsOption(
                title: "Debit Alert Email Notifications",
                switchValue: notificationSettings['debitAlertEmailNotification'] ?? false,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("debitAlertEmailNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.emailAlertIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All wishlist activities related notification',
              ),
              NotificationSettingsOption(
                title: "Billing Notifications",
                switchValue: notificationSettings['billPaymentNotification'] ?? false,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("billPaymentNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.notificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All wishlist activities related notification',
              ),
              NotificationSettingsOption(
                title: "Credit Alert Notifications",
                switchValue: notificationSettings['creditAlertNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("creditAlertNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.notificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All wishlist activities related notification',
              ),
              NotificationSettingsOption(
                title: "Debit Alert Notifications",
                switchValue: notificationSettings['debitAlertNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("debitAlertNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.notificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All wishlist activities related notification',
              ),

              const SizedBox(height: 10),
              const Text(
                "Social Notification",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              NotificationSettingsOption(
                title: "Incoming Messages Notifications",
                switchValue: notificationSettings['incommingMessagesNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("incommingMessagesNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.incomingMessageIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'Notifications on all your incoming messages',
              ),
              NotificationSettingsOption(
                title: "Private Message Notifications",
                switchValue: notificationSettings['privateChatNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("privateChatNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.privateMessageIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'Notifications on all your private chats',
              ),
              NotificationSettingsOption(
                title: "Group Chat Notifications",
                switchValue: notificationSettings['groupChatNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("groupChatNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.groupMessageIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'Notifications from your group chats',
              ),
              NotificationSettingsOption(
                title: "Connection Request Notifications",
                switchValue: notificationSettings['receivedRequestNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("receivedRequestNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.connectionRequestIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'Notifications on all your connection requests',
              ),
              const SizedBox(height: 10),
              const Text(
                "System Notification",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              NotificationSettingsOption(
                title: "Account Notifications",
                switchValue: notificationSettings['accountUpdateNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("accountUpdateNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.accountNotificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'All wishlist activities related notification',
              ),
              NotificationSettingsOption(
                title: "Security Notifications",
                switchValue: notificationSettings['securitySettingsNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("securitySettingsNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.securityNotificationIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: 'Notifications on security activities in your account',
              ),
              NotificationSettingsOption(
                title: "News Letter Notifications",
                switchValue: notificationSettings['newsLetterNotification'] ?? true,
                onClick: () {},
                onChange: (_) {
                  _toggleSetting("newsLetterNotification");
                },
                iconTwo: Image.asset(
                  AppIcons.newsLetterIcon,
                  color: const Color(AppColors.primaryColor),
                ),
                subMessage: "Don't miss out on all the exclusive stuffs",
              ),
              const SizedBox(height: 25,),
              Container(
                height: 98,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(AppColors.primaryColor).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.announcement_outlined, color: Color(AppColors.primaryColor)),
                      SizedBox(width: 5,),
                      Expanded(
                        child: Text(
                          "Any notification setting that you decide to switch of will only be used on that particular notification, please don't expect the switch for cart to work on wishlist or order, it will only work for cart, we separated the notification option to make it much more easier for you to understand the notification you are trying to stop.",
                          style: TextStyle(
                              color: Color(AppColors.primaryColor),
                              fontSize: 11,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
