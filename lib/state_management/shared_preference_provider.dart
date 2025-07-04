import 'package:flutter/material.dart';

import '../features/profile/model/user_model.dart';
import '../utilities/themes/theme_provider.dart';
import 'shared_preference_services.dart';

class SharedPreferencesProvider with ChangeNotifier {
  final SharedPreferencesService _sharedPreferencesService;
  UserModel? _cachedUser;
  bool _isDarkMode = false;
  bool _extraSecurity = false;
  bool _passCodeLock = false;
  final ThemeProvider _themeProvider;

  SharedPreferencesProvider(
    this._sharedPreferencesService,
    this._themeProvider,
  );

  Map<String, bool> _notificationSettings = {};

  Map<String, bool> get notificationSettings => _notificationSettings;

  UserModel? get cachedUser => _cachedUser;

  bool get isDarkMode => _isDarkMode;

  bool get extraSecurity => _extraSecurity;
  bool get passCodeLock => _passCodeLock;

  // Cache the UserModel
  void cacheUser(UserModel user) {
    _cachedUser = user;
    _syncThemeWithUserModel(user);
    _syncExtraSecurityWithUserModel(user);
    _syncPassCodeLockWithUserModel(user);
    areNotificationSettingsDifferent(user);
    notifyListeners();
  }

  //#################################################### Notifications ################################################################
  // Load notification settings from SharedPreferences
  Future<void> loadNotificationSettings() async {
    _notificationSettings =
        await _sharedPreferencesService.getNotificationSettings();
    notifyListeners();
  }

  // Save notification settings from UserModel
  Future<void> saveNotificationSettingsFromUserModel(UserModel user) async {
    await _sharedPreferencesService.saveNotificationSettingsFromUserModel(user);
    await loadNotificationSettings();
    notifyListeners();
  }

  // Update a single notification setting
  Future<void> updateNotificationSetting(String key, bool value) async {
    _notificationSettings[key] = value;
    await _sharedPreferencesService.saveNotificationSettings(
      _notificationSettings,
    );
    notifyListeners();
  }

  Future<bool> areNotificationSettingsDifferent(UserModel user) async {
    final notificationSettings =
        await _sharedPreferencesService.getNotificationSettings();
    final userNotificationSettings = user.userSettings.notificationSettings;
    notifyListeners();
    return notificationSettings["newItemsNotification"] !=
            userNotificationSettings.newItemsNotification ||
        notificationSettings["cartNotification"] !=
            userNotificationSettings.cartNotification ||
        notificationSettings["orderNotification"] !=
            userNotificationSettings.orderNotification ||
        notificationSettings["wishlistNotification"] !=
            userNotificationSettings.wishlistNotification ||
        notificationSettings["newsLetterNotification"] !=
            userNotificationSettings.newsLetterNotification ||
        notificationSettings["incommingMessagesNotification"] !=
            userNotificationSettings.incommingMessagesNotification ||
        notificationSettings["privateChatNotification"] !=
            userNotificationSettings.privateChatNotification ||
        notificationSettings["groupChatNotification"] !=
            userNotificationSettings.groupChatNotification ||
        notificationSettings["receivedRequestNotification"] !=
            userNotificationSettings.receivedRequestNotification ||
        notificationSettings["creditAlertNotification"] !=
            userNotificationSettings.creditAlertNotification ||
        notificationSettings["debitAlertNotification"] !=
            userNotificationSettings.debitAlertNotification ||
        notificationSettings["creditAlertEmailNotification"] !=
            userNotificationSettings.creditAlertEmailNotification ||
        notificationSettings["debitAlertEmailNotification"] !=
            userNotificationSettings.debitAlertEmailNotification ||
        notificationSettings["securitySettingsNotification"] !=
            userNotificationSettings.securitySettingsNotification ||
        notificationSettings["accountUpdateNotification"] !=
            userNotificationSettings.accountUpdateNotification ||
        notificationSettings["billPaymentNotification"] !=
            userNotificationSettings.billPaymentNotification;
  }

  //#################################################### Dark OR Light Mode ################################################################

  // Sync isDarkMode from UserModel with ThemeProvider
  void _syncThemeWithUserModel(UserModel user) {
    final isDarkMode = user.userSettings.isDarkMode;
    _themeProvider.setThemeMode(isDarkMode);
    notifyListeners();
  }

  // Compare isDarkMode from UserModel with ThemeProvider
  bool isThemeDifferent(UserModel user) {
    return _themeProvider.isDarkMode != user.userSettings.isDarkMode;
  }

  // Save isDarkMode to SharedPreferences
  Future<void> saveIsDarkMode(bool isDarkMode) async {
    await _sharedPreferencesService.saveIsDarkMode(isDarkMode);
    notifyListeners();
  }

  // Load isDarkMode from SharedPreferences
  Future<void> loadIsDarkMode() async {
    final isDarkMode = await _sharedPreferencesService.getIsDarkMode();
    _themeProvider.setThemeMode(isDarkMode);
    notifyListeners();
  }

  //#################################################### ExtraSecurity ################################################################
  // Sync extraSecurity from UserModel
  void _syncExtraSecurityWithUserModel(UserModel user) {
    _extraSecurity = user.extraSecurity;
    notifyListeners();
  }

  // Compare extraSecurity from UserModel
  bool isExtraSecurityEnabled(UserModel user) {
    return _extraSecurity != user.extraSecurity; // Correct comparison
  }

  // Save extraSecurity to SharedPreferences
  Future<void> saveExtraSecurity(bool extraSecurity) async {
    _extraSecurity = extraSecurity; // Update local state
    await _sharedPreferencesService.saveExtraSecurity(extraSecurity);
    notifyListeners();
  }

  // Load extraSecurity from SharedPreferences
  Future<void> loadExtraSecurity() async {
    _extraSecurity = await _sharedPreferencesService.getExtraSecurity(); // Update local state
    notifyListeners();
  }
  // Sync passCodeLock from UserModel
  void _syncPassCodeLockWithUserModel(UserModel user) {
    _passCodeLock = user.userSettings.passCodeLock;
    notifyListeners();
  }

  // Compare passCodeLock from UserModel
  bool isPassCodeLockEnabled(UserModel user) {
    return _passCodeLock != user.userSettings.passCodeLock; // Correct comparison
  }

  // Save passCodeLock to SharedPreferences
  Future<void> savePassCodeLock(bool passCodeLock) async {
    _passCodeLock = passCodeLock; // Update local state
    await _sharedPreferencesService.savePassCodeLock(passCodeLock);
    notifyListeners();
  }

  // Load passCodeLock from SharedPreferences
  Future<void> loadPassCodeLock() async {
    _passCodeLock = await _sharedPreferencesService.getPassCodeLock(); // Update local state
    notifyListeners();
  }
}
