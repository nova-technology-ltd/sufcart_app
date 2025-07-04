// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';
//
// import '../../../../../utilities/socket/socket_config_provider.dart';
// import 'like_socket_service.dart';
// class LikeSocketProvider extends ChangeNotifier {
//   final LikeSocketService _likeService;
//   final Map<String, List<dynamic>> _postLikes = {};
//   String? _errorMessage;
//   String? _successMessage;
//
//   List<dynamic> getLikes(String postID) => _postLikes[postID] ?? [];
//
//   String? getLikeID(String postID, String userID) {
//     final like = _postLikes[postID]?.firstWhere(
//           (like) => like['userID'] == userID,
//       orElse: () => null,
//     );
//     return like?['likeID'];
//   }
//
//   bool isPostLikedByUser(String postID, String userID) =>
//       _postLikes[postID]?.any((like) => like['userID'] == userID) ?? false;
//
//   int getLikeCount(String postID) => _postLikes[postID]?.length ?? 0;
//
//   String? get errorMessage => _errorMessage;
//   String? get successMessage => _successMessage;
//
//   LikeSocketProvider({required SocketConfigProvider socketConfigProvider})
//       : _likeService = LikeSocketService(socketConfigProvider: socketConfigProvider) {
//     _likeService.likeStream.listen((data) {
//       final postID = data['postID'];
//       _postLikes[postID] = data['likes'] ?? [];
//       notifyListeners();
//     });
//
//     _likeService.errorStream.listen((message) {
//       _errorMessage = message;
//       notifyListeners();
//       Future.delayed(const Duration(seconds: 3), () {
//         _errorMessage = null;
//         notifyListeners();
//       });
//     });
//
//     _likeService.successStream.listen((data) {
//       _successMessage = data['message'];
//       notifyListeners();
//       Future.delayed(const Duration(seconds: 3), () {
//         _successMessage = null;
//         notifyListeners();
//       });
//     });
//   }
//
//   Future<void> joinPost(String postID) async {
//     try {
//       await _likeService.joinPost(postID);
//     } catch (e) {
//       _errorMessage = 'Failed to join post: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//   Future<void> toggleLike(String postID, String userID) async {
//     try {
//       if (isPostLikedByUser(postID, userID)) {
//         final likeID = getLikeID(postID, userID);
//         if (likeID != null) {
//           await _likeService.removeLike(postID, likeID);
//           notifyListeners();
//         }
//       } else {
//         await _likeService.addLike(postID);
//         notifyListeners();
//       }
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Failed to toggle like: ${e.toString()}';
//       notifyListeners();
//     }
//   }
//
//   @override
//   void dispose() {
//     _likeService.dispose();
//     super.dispose();
//   }
// }
//
// extension LikeSocketProviderExtension on BuildContext {
//   LikeSocketProvider get likeSocketProvider => read<LikeSocketProvider>();
// }


import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../utilities/socket/socket_config_provider.dart';
import '../../likes/model/likes_model.dart';
import 'like_socket_service.dart';
import 'package:provider/provider.dart';


class LikeSocketProvider extends ChangeNotifier {
  final LikeSocketService _likeService;
  final Map<String, List<LikesModel>> _postLikes = {};
  String? _errorMessage;
  String? _successMessage;

  List<LikesModel> getLikes(String postID) => _postLikes[postID] ?? [];

  String? getLikeID(String postID, String userID) {
    final likes = _postLikes[postID];
    if (likes == null || likes.isEmpty) return null;
    try {
      return likes.firstWhere((like) => like.userID == userID).likeID;
    } catch (e) {
      return null; // No matching like found
    }
  }

  bool isPostLikedByUser(String postID, String userID) =>
      _postLikes[postID]?.any((like) => like.userID == userID) ?? false;

  int getLikeCount(String postID) => _postLikes[postID]?.length ?? 0;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  LikeSocketProvider({required SocketConfigProvider socketConfigProvider})
      : _likeService = LikeSocketService(socketConfigProvider: socketConfigProvider) {
    _likeService.likeStream.listen((likes) {
      final postID = likes.isNotEmpty ? likes.first.postID : null;
      if (postID != null) {
        _postLikes[postID] = likes;
        notifyListeners();
      }
    });

    _likeService.errorStream.listen((message) {
      _errorMessage = message;
      notifyListeners();
      Future.delayed(const Duration(seconds: 3), () {
        _errorMessage = null;
        notifyListeners();
      });
    });

    _likeService.successStream.listen((data) {
      _successMessage = data['message'];
      notifyListeners();
      Future.delayed(const Duration(seconds: 3), () {
        _successMessage = null;
        notifyListeners();
      });
    });
  }

  Future<void> joinPost(String postID) async {
    try {
      await _likeService.joinPost(postID);
    } catch (e) {
      _errorMessage = 'Failed to join post: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postID, String userID) async {
    try {
      final wasLiked = isPostLikedByUser(postID, userID);
      final likeID = getLikeID(postID, userID);

      // Optimistic update
      if (wasLiked && likeID != null) {
        _postLikes[postID] = _postLikes[postID]!.where((like) => like.likeID != likeID).toList();
      } else {
        final newLike = LikesModel(
          likeID: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
          postID: postID,
          userID: userID,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _postLikes[postID] = [...?_postLikes[postID], newLike];
      }
      notifyListeners();

      // Send request to server
      if (wasLiked && likeID != null) {
        await _likeService.removeLike(postID, likeID);
      } else {
        await _likeService.addLike(postID, userID);
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle like: ${e.toString()}';
      notifyListeners();
      // Revert optimistic update on error
      _postLikes[postID] = _postLikes[postID] ?? [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _likeService.dispose();
    super.dispose();
  }
}

extension LikeSocketProviderExtension on BuildContext {
  LikeSocketProvider get likeSocketProvider => read<LikeSocketProvider>();
}