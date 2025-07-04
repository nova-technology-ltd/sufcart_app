class UserSettingsModel {
  final NotificationSettings notificationSettings;
  final bool isDarkMode;
  final ChatSettings chatSettings;
  final String lastSeenOnline;
  final String profilePhoto;
  final String dateOfBirth;
  final String biography;
  final bool twoStepVerification;
  final bool passCodeLock;
  final bool syncContacts;

  UserSettingsModel({
    required this.notificationSettings,
    required this.isDarkMode,
    required this.chatSettings,
    required this.lastSeenOnline,
    required this.profilePhoto,
    required this.dateOfBirth,
    required this.biography,
    required this.twoStepVerification,
    required this.passCodeLock,
    required this.syncContacts,
  });

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      notificationSettings: NotificationSettings.fromMap(map['notificationSettings']),
      isDarkMode: map['isDartMode'] ?? false,
      chatSettings: ChatSettings.fromMap(map['chatSettings']),
      lastSeenOnline: map['lastSeenOnline'] ?? 'Everybody',
      profilePhoto: map['profilePhoto'] ?? 'Everybody',
      dateOfBirth: map['dateOfBirth'] ?? 'Everybody',
      biography: map['biography'] ?? 'Everybody',
      twoStepVerification: map['twoStepVerification'] ?? false,
      passCodeLock: map['passCodeLock'] ?? false,
      syncContacts: map['syncContacts'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationSettings': notificationSettings.toMap(),
      'isDartMode': isDarkMode,
      'chatSettings': chatSettings.toMap(),
      'lastSeenOnline': lastSeenOnline,
      'profilePhoto': profilePhoto,
      'dateOfBirth': dateOfBirth,
      'biography': biography,
      'twoStepVerification': twoStepVerification,
      'passCodeLock': passCodeLock,
      'syncContacts': syncContacts,
    };
  }
}

class NotificationSettings {
  final bool newsLetterNotification;
  final bool newItemsNotification;
  final bool cartNotification;
  final bool orderNotification;
  final bool wishlistNotification;
  final bool incommingMessagesNotification;
  final bool privateChatNotification;
  final bool groupChatNotification;
  final bool receivedRequestNotification;
  final bool creditAlertNotification;
  final bool debitAlertNotification;
  final bool creditAlertEmailNotification;
  final bool debitAlertEmailNotification;
  final bool securitySettingsNotification;
  final bool accountUpdateNotification;
  final bool billPaymentNotification;

  NotificationSettings({
    required this.newsLetterNotification,
    required this.newItemsNotification,
    required this.cartNotification,
    required this.orderNotification,
    required this.wishlistNotification,
    required this.incommingMessagesNotification,
    required this.privateChatNotification,
    required this.groupChatNotification,
    required this.receivedRequestNotification,
    required this.creditAlertNotification,
    required this.debitAlertNotification,
    required this.creditAlertEmailNotification,
    required this.debitAlertEmailNotification,
    required this.securitySettingsNotification,
    required this.accountUpdateNotification,
    required this.billPaymentNotification,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      newsLetterNotification: map['newsLetterNotification'] ?? true,
      newItemsNotification: map['newItemsNotification'] ?? true,
      cartNotification: map['cartNotification'] ?? true,
      orderNotification: map['orderNotification'] ?? true,
      wishlistNotification: map['wishlistNotification'] ?? true,
      incommingMessagesNotification: map['incommingMessagesNotification'] ?? true,
      privateChatNotification: map['privateChatNotification'] ?? true,
      groupChatNotification: map['groupChatNotification'] ?? true,
      receivedRequestNotification: map['receivedRequestNotification'] ?? true,
      creditAlertNotification: map['creditAlertNotification'] ?? true,
      debitAlertNotification: map['debitAlertNotification'] ?? true,
      creditAlertEmailNotification: map['creditAlertEmailNotification'] ?? false,
      debitAlertEmailNotification: map['debitAlertEmailNotification'] ?? false,
      securitySettingsNotification: map['securitySettingsNotification'] ?? true,
      accountUpdateNotification: map['accountUpdateNotification'] ?? true,
      billPaymentNotification: map['billPaymentNotification'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newsLetterNotification': newsLetterNotification,
      'newItemsNotification': newItemsNotification,
      'cartNotification': cartNotification,
      'orderNotification': orderNotification,
      'wishlistNotification': wishlistNotification,
      'incommingMessagesNotification': incommingMessagesNotification,
      'privateChatNotification': privateChatNotification,
      'groupChatNotification': groupChatNotification,
      'receivedRequestNotification': receivedRequestNotification,
      'creditAlertNotification': creditAlertNotification,
      'debitAlertNotification': debitAlertNotification,
      'creditAlertEmailNotification': creditAlertEmailNotification,
      'debitAlertEmailNotification': debitAlertEmailNotification,
      'securitySettingsNotification': securitySettingsNotification,
      'accountUpdateNotification': accountUpdateNotification,
      'billPaymentNotification': billPaymentNotification,
    };
  }
}

class ChatSettings {
  final bool useEnterForSend;
  final bool unReadMessagesCounter;
  final bool messageRequest;

  ChatSettings({
    required this.useEnterForSend,
    required this.unReadMessagesCounter,
    required this.messageRequest,
  });

  factory ChatSettings.fromMap(Map<String, dynamic> map) {
    return ChatSettings(
      useEnterForSend: map['useEnterForSend'] ?? true,
      unReadMessagesCounter: map['unReadMessagesCounter'] ?? true,
      messageRequest: map['messageRequest'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'useEnterForSend': useEnterForSend,
      'unReadMessagesCounter': unReadMessagesCounter,
      'messageRequest': messageRequest,
    };
  }
}