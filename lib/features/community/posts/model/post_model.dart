import 'package:sufcart_app/features/profile/model/user_model.dart';

import '../../likes/model/likes_model.dart';
import '../../reactions/model/reaction_model.dart';
import '../../views/model/post_view_model.dart';

class PostModel {
  final String postID;
  final String userID;
  final String postText;
  final List<String> postImages;
  final List<PostViewModel> views;
  final List<ReactionModel> reactions;
  final List<LikesModel> likes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? userDetails;

  PostModel({
    required this.postID,
    required this.userID,
    required this.postText,
    required this.postImages,
    required this.views,
    required this.reactions,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
    this.userDetails,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postID: map['postID'] ?? '',
      userID: map['userID'] ?? '',
      postText: map['postText'] ?? '',
      postImages: List<String>.from(map['postImages'] ?? []),
      views: (map['views'] as List<dynamic>?)
          ?.map((view) => PostViewModel.fromMap(view as Map<String, dynamic>))
          .toList() ??
          [],
      reactions: (map['reactions'] as List<dynamic>?)
          ?.map((reaction) => ReactionModel.fromMap(reaction as Map<String, dynamic>))
          .toList() ??
          [],
      likes: (map['likes'] as List<dynamic>?)
          ?.map((like) => LikesModel.fromMap(like as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
      userDetails: UserModel.fromMap(map['userDetails']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postID': postID,
      'userID': userID,
      'postText': postText,
      'postImages': postImages,
      'views': views.map((view) => view.toMap()).toList(),
      'reactions': reactions.map((reaction) => reaction.toMap()).toList(),
      'likes': likes.map((like) => like.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userDetails': userDetails?.toMap(),
    };
  }
}