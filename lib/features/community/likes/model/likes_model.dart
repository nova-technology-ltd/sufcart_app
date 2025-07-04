class LikesModel {
  final String likeID;
  final String postID;
  final String userID;
  final DateTime createdAt;
  final DateTime updatedAt;

  LikesModel({
    required this.likeID,
    required this.postID,
    required this.userID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LikesModel.fromMap(Map<String, dynamic> map) {
    return LikesModel(
      likeID: map['likeID'] ?? '',
      postID: map['postID'] ?? '',
      userID: map['userID'] ?? '',
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'likeID': likeID,
      'postID': postID,
      'userID': userID,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}