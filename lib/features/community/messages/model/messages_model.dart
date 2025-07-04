class MessagesModel {
  final String messageID;
  final String senderID;
  final String receiverID;
  final String content;
  final List<String> images;
  final List<dynamic> reactions;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  MessagesModel({
    required this.messageID,
    required this.senderID,
    required this.receiverID,
    required this.content,
    required this.images,
    required this.reactions,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      messageID: map['messageID'] ?? '',
      senderID: map['senderID'] ?? '',
      receiverID: map['receiverID'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['image'] ?? []),
      reactions: map['reactions'] ?? [],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageID': messageID,
      'senderID': senderID,
      'receiverID': receiverID,
      'content': content,
      'images': images,
      'reactions': reactions,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
    };
  }

  MessagesModel copyWith({
    String? messageID,
    String? senderID,
    String? receiverID,
    String? content,
    List<String>? images,
    List<dynamic>? reactions,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessagesModel(
      messageID: messageID ?? this.messageID,
      senderID: senderID ?? this.senderID,
      receiverID: receiverID ?? this.receiverID,
      content: content ?? this.content,
      images: images ?? this.images,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}