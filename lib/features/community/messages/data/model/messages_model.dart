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
  final DateTime updatedAt;
  final String replyTo;

  MessagesModel({
    required this.messageID,
    required this.senderID,
    required this.receiverID,
    required this.content,
    required this.images,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
    this.readAt,
    required this.replyTo,
  });

  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      messageID: map['messageID'] ?? '',
      senderID: map['senderID'] ?? '',
      receiverID: map['receiverID'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      reactions: map['reactions'] ?? [],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      replyTo: map['replyTo'] ?? '',
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
      'updatedAt': updatedAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'replyTo': replyTo,
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
    DateTime? updatedAt,
    bool? isRead,
    DateTime? readAt,
    String? replyTo,
  }) {
    return MessagesModel(
      messageID: messageID ?? this.messageID,
      senderID: senderID ?? this.senderID,
      receiverID: receiverID ?? this.receiverID,
      content: content ?? this.content,
      images: images ?? this.images,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      replyTo: replyTo ?? this.replyTo,
    );
  }
}
