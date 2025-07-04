class ReactionModel {
  final String reactionID;
  final String postID;
  final String userID;
  final String reaction;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReactionModel({
    required this.reactionID,
    required this.postID,
    required this.userID,
    required this.reaction,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReactionModel.fromMap(Map<String, dynamic> map) {
    return ReactionModel(
      reactionID: map['reactionID'] ?? '',
      postID: map['postID'] ?? '',
      userID: map['userID'] ?? '',
      reaction: map['reaction'] ?? '',
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reactionID': reactionID,
      'postID': postID,
      'userID': userID,
      'reaction': reaction,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}