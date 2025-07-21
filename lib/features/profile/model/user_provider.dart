import 'package:flutter/material.dart';
import 'package:sufcart_app/features/profile/model/user_model.dart';
import '../../settings/model/user_settings_model.dart';


class UserProvider extends ChangeNotifier {
  UserModel _userModel = UserModel(
    id: '',
    userID: '',
    googleId: '',
    firstName: '',
    lastName: '',
    otherNames: '',
    userName: '',
    image: '',
    phoneNumber: '',
    gender: '',
    dob: '',
    bio: '',
    email: '',
    password: '',
    accountPIN: 0,
    token: '',
    inviteCode: '',
    isVendor: false,
    isEmailVerified: false,
    // cart: [],
    connectionRequest: [],
    connections: [],
    myInvites: [],
    blockedConnections: [],
    securityQuestions: [],
    createdAt: null,
    updatedAt: null,
    interests: [],
    isProfileComplete: false,
    extraSecurity: false,
    userSettings: UserSettingsModel(
      notificationSettings: NotificationSettings(
        newsLetterNotification: true,
        newItemsNotification: true,
        cartNotification: true,
        orderNotification: true,
        wishlistNotification: true,
        incommingMessagesNotification: true,
        privateChatNotification: true,
        groupChatNotification: true,
        receivedRequestNotification: true,
        creditAlertNotification: true,
        debitAlertNotification: true,
        creditAlertEmailNotification: false,
        debitAlertEmailNotification: false,
        securitySettingsNotification: true,
        accountUpdateNotification: true,
        billPaymentNotification: false,
      ),
      isDarkMode: false,
      chatSettings: ChatSettings(
        useEnterForSend: true,
        unReadMessagesCounter: true,
        messageRequest: false,
      ),
      lastSeenOnline: 'Everybody',
      profilePhoto: 'Everybody',
      dateOfBirth: 'Everybody',
      biography: 'Everybody',
      twoStepVerification: false,
      passCodeLock: false,
      syncContacts: false,
    ),
    // userWallet: UserWalletModel(
    //   accountBalance: 0,
    //   currency: 'NGN',
    //   bankDetails: BankDetails(
    //     bankName: '',
    //     accountNumber: '',
    //     accountName: '',
    //   ),
    //   virtualAccountId: '',
    //   isActive: true,
    //   createdAt: null,
    //   accountReference: '',
    //   bankCode: '',
    //   reservationReference: '',
    //   status: '',
    // ),
    followers: [],
    following: [],
  );

  String? _loggedInUserId;

  UserModel get userModel => _userModel;

  String? get loggedInUserId => _loggedInUserId;

  void setUser(String user) {
    _userModel = UserModel.fromJson(user);
    _loggedInUserId = _userModel.id;
    notifyListeners();
  }

  void setUserFromModel(UserModel userModel) {
    _userModel = userModel;
    _loggedInUserId = userModel.id;
    notifyListeners();
  }

  void updateUser(UserModel newUser) {
    _userModel = newUser;
    notifyListeners();
  }
}
