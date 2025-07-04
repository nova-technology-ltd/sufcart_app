class NotificationModel {
  final String notificationID;
  final String recipient;
  final String title;
  final String message;
  final String type;
  final String image;
  final String itemID;
  final bool isComplete;
  final bool isCancel;
  final String notificationIcon;
  final bool hasImage;
  final bool isRead;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.notificationID,
    required this.recipient,
    required this.title,
    required this.message,
    required this.type,
    required this.image,
    required this.itemID,
    required this.isComplete,
    required this.isCancel,
    required this.notificationIcon,
    required this.hasImage,
    required this.isRead,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationID: map['notificationID'] ?? '',
      recipient: map['recipient'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      image: map['image'] ?? '',
      itemID: map['itemID'] ?? '',
      isComplete: map['isComplete'] ?? false,
      isCancel: map['isCancel'] ?? false,
      notificationIcon: map['notificationIcon'] ?? '',
      hasImage: map['hasImage'] ?? false,
      isRead: map['isRead'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationID': notificationID,
      'recipient': recipient,
      'title': title,
      'message': message,
      'type': type,
      'image': image,
      'itemID': itemID,
      'isComplete': isComplete,
      'isCancel': isCancel,
      'notificationIcon': notificationIcon,
      'hasImage': hasImage,
      'isRead': isRead,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
