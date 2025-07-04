class FollowModel {
  final String followID;
  final String userID;
  final DateTime createdAt;
  final DateTime updatedAt;

  FollowModel({
    required this.followID,
    required this.userID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      followID: map['followID'] ?? '',
      userID: map['userID'] ?? '',
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followID': followID,
      'userID': userID,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}