class PushNotificationModel {
  final String id;
  final String customID;
  final String deviceId;
  final String platform;
  final String token;
  final String userID;
  final DateTime createdAt;
  final DateTime updatedAt;

  PushNotificationModel({
    required this.id,
    required this.customID,
    required this.deviceId,
    required this.platform,
    required this.token,
    required this.userID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PushNotificationModel.fromMap(Map<String, dynamic> map) {
    return PushNotificationModel(
      id: map['_id'] ?? '',
      customID: map['customID'] ?? '',
      deviceId: map['deviceId'] ?? '',
      platform: map['platform'] ?? '',
      token: map['token'] ?? '',
      userID: map['userID'] ?? '',
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'customID': customID,
      'deviceId': deviceId,
      'platform': platform,
      'token': token,
      'userID': userID,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
