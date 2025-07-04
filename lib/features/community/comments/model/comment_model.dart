class ReplyCommentModel {
  final String replyID;
  final String userID;
  final String replyText;
  final List<String> replyImages;
  final Map<String, dynamic> replyUserDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReplyCommentModel({
    required this.replyID,
    required this.userID,
    required this.replyText,
    required this.replyImages,
    required this.replyUserDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReplyCommentModel.fromMap(Map<String, dynamic> map) {
    return ReplyCommentModel(
      replyID: map['replyID'] ?? '',
      userID: map['userID'] ?? '',
      replyText: map['replyText'] ?? '',
      replyImages: List<String>.from(map['replyImages'] ?? []),
      replyUserDetails: Map<String, dynamic>.from(map['replyUserDetails'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'replyID': replyID,
      'userID': userID,
      'replyText': replyText,
      'replyImages': replyImages,
      'replyUserDetails': replyUserDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CommentModel {
  final String commentID;
  final String userID;
  final String commentText;
  final List<String> commentImages;
  final int likes;
  final List<ReplyCommentModel> replies;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> commentUserDetails;

  CommentModel({
    required this.commentID,
    required this.userID,
    required this.commentText,
    required this.commentImages,
    required this.likes,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
    required this.commentUserDetails,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentID: map['commentID'] ?? '',
      userID: map['userID'] ?? '',
      commentText: map['commentText'] ?? '',
      commentImages: List<String>.from(map['commentImages'] ?? []),
      likes: map['likes'] ?? 0,
      replies: (map['replies'] as List)
          .map((e) => ReplyCommentModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
      commentUserDetails: Map<String, dynamic>.from(map['commentUserDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentID': commentID,
      'userID': userID,
      'commentText': commentText,
      'commentImages': commentImages,
      'likes': likes,
      'replies': replies.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'commentUserDetails': commentUserDetails,
    };
  }
}