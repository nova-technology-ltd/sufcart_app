class RepostModel {
  final String id;
  final String repostID;
  final String postID;
  final String userID;
  final Map<String, dynamic> postDetails;
  final Map<String, dynamic> userDetails;

  RepostModel({
    required this.id,
    required this.repostID,
    required this.postID,
    required this.userID,
    required this.postDetails,
    required this.userDetails,
  });

  factory RepostModel.fromMap(Map<String, dynamic> map) {
    return RepostModel(
      id: map['_id'] ?? '',
      repostID: map['repostID'] ?? '',
      postID: map['postID'] ?? '',
      userID: map['userID'] ?? '',
      postDetails: Map<String, dynamic>.from(map['postDetails'] ?? {}),
      userDetails: Map<String, dynamic>.from(map['userDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'repostID': repostID,
      'postID': postID,
      'userID': userID,
      'postDetails': Map<String, dynamic>.from(postDetails),
      'userDetails': Map<String, dynamic>.from(userDetails),
    };
  }
}

