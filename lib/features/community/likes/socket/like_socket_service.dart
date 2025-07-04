// import 'dart:async';
// import '../../../../../utilities/socket/socket_config_provider.dart';
//
// class LikeSocketService {
//   final SocketConfigProvider _socketConfigProvider;
//   final _likeController = StreamController<Map<String, dynamic>>.broadcast();
//   final _errorController = StreamController<String>.broadcast();
//   final _successController = StreamController<Map<String, dynamic>>.broadcast();
//   StreamSubscription? _eventSubscription;
//
//   Stream<Map<String, dynamic>> get likeStream => _likeController.stream;
//   Stream<String> get errorStream => _errorController.stream;
//   Stream<Map<String, dynamic>> get successStream => _successController.stream;
//
//   LikeSocketService({required SocketConfigProvider socketConfigProvider})
//       : _socketConfigProvider = socketConfigProvider {
//     _eventSubscription = _socketConfigProvider.eventStream.listen((eventData) {
//       final event = eventData['event'];
//       final data = eventData['data'];
//       switch (event) {
//         case 'likes:initial':
//         case 'likes:updated':
//           if (!_likeController.isClosed) _likeController.add(data); // Check if not closed
//           break;
//         case 'likes:success':
//           if (!_successController.isClosed) _successController.add(data);
//           break;
//         case 'likes:error':
//           if (!_errorController.isClosed) _errorController.add(data['message']);
//           break;
//       }
//     });
//   }
//
//   Future<void> _ensureConnected() async {
//     if (!_socketConfigProvider.isConnected) {
//       await _socketConfigProvider.connectionStatus
//           .firstWhere((status) => status == true, orElse: () => false);
//       if (!_socketConfigProvider.isConnected) {
//         throw Exception('Socket not connected');
//       }
//     }
//   }
//
//   Future<void> joinPost(String postID) async {
//     await _ensureConnected();
//     _socketConfigProvider.emit('joinPost', {'postID': postID});
//   }
//
//   Future<void> addLike(String postID) async {
//     await _ensureConnected();
//     _socketConfigProvider.emit('addLikes', {'postID': postID});
//   }
//
//   Future<void> removeLike(String postID, String likeID) async {
//     await _ensureConnected();
//     _socketConfigProvider.emit('removeLikes', {'postID': postID, 'likeID': likeID});
//   }
//
//   void dispose() {
//     _eventSubscription?.cancel();
//     _likeController.close();
//     _errorController.close();
//     _successController.close();
//   }
// }


import 'dart:async';
import '../../../../../utilities/socket/socket_config_provider.dart';
import '../../likes/model/likes_model.dart';

class LikeSocketService {
  final SocketConfigProvider _socketConfigProvider;
  final _likeController = StreamController<List<LikesModel>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _successController = StreamController<Map<String, dynamic>>.broadcast();
  StreamSubscription? _eventSubscription;

  Stream<List<LikesModel>> get likeStream => _likeController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>> get successStream => _successController.stream;

  LikeSocketService({required SocketConfigProvider socketConfigProvider})
      : _socketConfigProvider = socketConfigProvider {
    _eventSubscription = _socketConfigProvider.eventStream.listen((eventData) {
      final event = eventData['event'];
      final data = eventData['data'];
      switch (event) {
        case 'likes:initial':
        case 'likes:updated':
          if (!_likeController.isClosed) {
            final likes = (data['likes'] as List<dynamic>?)
                ?.map((like) => LikesModel.fromMap(like as Map<String, dynamic>))
                .toList() ??
                [];
            _likeController.add(likes);
          }
          break;
        case 'likes:success':
          if (!_successController.isClosed) _successController.add(data);
          break;
        case 'likes:error':
          if (!_errorController.isClosed) _errorController.add(data['message']);
          break;
      }
    });
  }

  Future<void> _ensureConnected() async {
    if (!_socketConfigProvider.isConnected) {
      await _socketConfigProvider.connectionStatus
          .firstWhere((status) => status == true, orElse: () => false);
      if (!_socketConfigProvider.isConnected) {
        throw Exception('Socket not connected');
      }
    }
  }

  Future<void> joinPost(String postID) async {
    await _ensureConnected();
    _socketConfigProvider.emit('joinPost', {'postID': postID});
  }

  Future<void> addLike(String postID, String userID) async {
    await _ensureConnected();
    _socketConfigProvider.emit('addLikes', {
      'postID': postID,
      'userID': userID,
    });
  }

  Future<void> removeLike(String postID, String likeID) async {
    await _ensureConnected();
    _socketConfigProvider.emit('removeLikes', {
      'postID': postID,
      'likeID': likeID,
    });
  }

  void dispose() {
    _eventSubscription?.cancel();
    _likeController.close();
    _errorController.close();
    _successController.close();
  }
}