import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/profile/model/user_model.dart';

class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static SharedPreferences? _preferences;

  SharedPreferencesService._internal();

  static Future<SharedPreferencesService> getInstance() async {
    _instance ??= SharedPreferencesService._internal();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }


  // Save UserModel
  Future<void> saveUserModel(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _preferences?.setString("userModel", userJson);
  }

  // Get UserModel
  Future<UserModel?> getUserModel() async {
    final userJson = _preferences?.getString("userModel");
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  //#################################################### Notifications ################################################################
  // Notification Settings
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    settings.forEach((key, value) async {
      await _preferences?.setBool(key, value);
    });
  }

  // Save notification settings from UserModel
  Future<void> saveNotificationSettingsFromUserModel(UserModel user) async {
    final notificationSettings = user.userSettings.notificationSettings;
    await _preferences?.setBool("newItemsNotification", notificationSettings.newItemsNotification);
    await _preferences?.setBool("cartNotification", notificationSettings.cartNotification);
    await _preferences?.setBool("orderNotification", notificationSettings.orderNotification);
    await _preferences?.setBool("wishlistNotification", notificationSettings.wishlistNotification);
    await _preferences?.setBool("newsLetterNotification", notificationSettings.newsLetterNotification);
    await _preferences?.setBool("incommingMessagesNotification", notificationSettings.incommingMessagesNotification);
    await _preferences?.setBool("privateChatNotification", notificationSettings.privateChatNotification);
    await _preferences?.setBool("groupChatNotification", notificationSettings.groupChatNotification);
    await _preferences?.setBool("receivedRequestNotification", notificationSettings.receivedRequestNotification);
    await _preferences?.setBool("creditAlertNotification", notificationSettings.creditAlertNotification);
    await _preferences?.setBool("debitAlertNotification", notificationSettings.debitAlertNotification);
    await _preferences?.setBool("creditAlertEmailNotification", notificationSettings.creditAlertEmailNotification);
    await _preferences?.setBool("debitAlertEmailNotification", notificationSettings.debitAlertEmailNotification);
    await _preferences?.setBool("securitySettingsNotification", notificationSettings.securitySettingsNotification);
    await _preferences?.setBool("accountUpdateNotification", notificationSettings.accountUpdateNotification);
    await _preferences?.setBool("billPaymentNotification", notificationSettings.billPaymentNotification);
  }

  // Get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    return {
      "newItemsNotification": _preferences?.getBool("newItemsNotification") ?? true,
      "cartNotification": _preferences?.getBool("cartNotification") ?? true,
      "orderNotification": _preferences?.getBool("orderNotification") ?? true,
      "wishlistNotification": _preferences?.getBool("wishlistNotification") ?? true,
      "newsLetterNotification": _preferences?.getBool("newsLetterNotification") ?? true,
      "incommingMessagesNotification": _preferences?.getBool("incommingMessagesNotification") ?? true,
      "privateChatNotification": _preferences?.getBool("privateChatNotification") ?? true,
      "groupChatNotification": _preferences?.getBool("groupChatNotification") ?? true,
      "receivedRequestNotification": _preferences?.getBool("receivedRequestNotification") ?? true,
      "creditAlertNotification": _preferences?.getBool("creditAlertNotification") ?? true,
      "debitAlertNotification": _preferences?.getBool("debitAlertNotification") ?? true,
      "creditAlertEmailNotification": _preferences?.getBool("creditAlertEmailNotification") ?? false,
      "debitAlertEmailNotification": _preferences?.getBool("debitAlertEmailNotification") ?? false,
      "securitySettingsNotification": _preferences?.getBool("securitySettingsNotification") ?? true,
      "accountUpdateNotification": _preferences?.getBool("accountUpdateNotification") ?? true,
      "billPaymentNotification": _preferences?.getBool("billPaymentNotification") ?? false,
    };
  }

  //#################################################### Dark OR Light Mode ################################################################
  // Save isDarkMode
  Future<void> saveIsDarkMode(bool isDarkMode) async {
    await _preferences?.setBool("isDarkMode", isDarkMode);
  }

  // Get isDarkMode
  Future<bool> getIsDarkMode() async {
    return _preferences?.getBool("isDarkMode") ?? false;
  }

//#################################################### ExtraSecurity ################################################################
  Future<void> saveExtraSecurity(bool extraSecurity) async {
    await _preferences?.setBool("extraSecurity", extraSecurity);
  }

  // Get extraSecurity
  Future<bool> getExtraSecurity() async {
    return _preferences?.getBool("extraSecurity") ?? false;
  }

  Future<void> savePassCodeLock(bool extraSecurity) async {
    await _preferences?.setBool("passCodeLock", extraSecurity);
  }

  // Get extraSecurity
  Future<bool> getPassCodeLock() async {
    return _preferences?.getBool("passCodeLock") ?? false;
  }
}