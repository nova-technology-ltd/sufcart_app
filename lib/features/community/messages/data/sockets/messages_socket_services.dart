import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../utilities/socket/socket_config_provider.dart';
import '../../../../profile/model/user_model.dart';
import '../../../../settings/model/user_settings_model.dart';


class MessagesSocketServices {
  final SocketConfigProvider _socketConfigProvider;
  final StreamController<Map<String, dynamic>> _messagesController =
  StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _errorController =
  StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _successController =
  StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<List<UserModel>> _usersController =
  StreamController<List<UserModel>>.broadcast();

  Stream<Map<String, dynamic>> get messagesStream => _messagesController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>> get successStream => _successController.stream;
  Stream<List<UserModel>> get usersStream => _usersController.stream;

  MessagesSocketServices({required SocketConfigProvider socketConfigProvider})
      : _socketConfigProvider = socketConfigProvider {
    _init();
  }

  void _init() {
    _socketConfigProvider.eventStream.listen((eventData) {
      if (!_socketConfigProvider.isConnected) {
        print('Socket disconnected, cannot process event: ${eventData['event']}');
        _errorController.add('Socket disconnected, cannot process event');
        return;
      }
      final event = eventData['event'];
      final data = eventData['data'] ?? {};

      String? roomID;
      if (data['senderID'] != null && data['receiverID'] != null) {
        final ids = [data['senderID'], data['receiverID']];
        ids.sort();
        roomID = 'chat:${ids.join(':')}';
      } else if (data['roomID'] != null) {
        roomID = data['roomID'];
      } else if (event == 'user:status' || event == 'chat:typing') {
        if (data['senderID'] != null && data['receiverID'] != null) {
          final ids = [data['senderID'], data['receiverID']];
          ids.sort();
          roomID = 'chat:${ids.join(':')}';
        } else {
          roomID = data['roomID'] ?? 'unknown';
        }
      }

      print('Processing event: $event, data: $data, roomID: $roomID');

      switch (event) {
        case 'chat:history':
          if (data['messages'] != null && data['messages'] is List) {
            String? historyRoomID;
            if (data['messages'].isNotEmpty) {
              final firstMessage = data['messages'][0];
              final ids = [
                firstMessage['senderID'],
                firstMessage['receiverID'],
              ];
              ids.sort();
              historyRoomID = 'chat:${ids.join(':')}';
            } else {
              historyRoomID = data['roomID'] ?? 'unknown';
            }
            _messagesController.add({
              'roomID': historyRoomID,
              'messages': data['messages'],
            });
          } else {
            print('Invalid chat history data');
            _errorController.add('Invalid chat history data');
          }
          break;
        case 'chat:newMessage':
          if (data['senderID'] == null || data['receiverID'] == null) {
            print('Invalid new message data: missing senderID or receiverID');
            _errorController.add(
              'Invalid new message data: missing senderID or receiverID',
            );
            return;
          }
          final ids = [data['senderID'], data['receiverID']];
          ids.sort();
          final newMessageRoomID = 'chat:${ids.join(':')}';
          _messagesController.add({
            'roomID': newMessageRoomID,
            'message': data,
          });
          break;
        case 'chat:reactionUpdated':
          _successController.add({
            'message': 'Reaction updated',
            'roomID': roomID,
            'messageID': data['messageID'] ?? '',
            'reactions': data['reactions'] ?? [],
          });
          break;
        case 'chat:success':
          _successController.add(data);
          break;
        case 'chat:error':
          final errorMessage = data['message'] ?? 'Unknown error: ${data['error'] ?? 'No details'}';
          print('Error received: $errorMessage');
          _errorController.add(errorMessage);
          break;
        case 'user:status':
          if (data['userID'] == null || data['status'] == null) {
            print('Invalid user:status data: missing userID or status');
            _errorController.add(
              'Invalid user:status data: missing userID or status',
            );
            return;
          }
          print('User status update: userID=${data['userID']}, status=${data['status']}, roomID=$roomID');
          _usersController.add([
            UserModel(
              id: '',
              userID: data['userID'],
              googleId: '',
              firstName: '',
              lastName: '',
              otherNames: '',
              userName: '',
              image: '',
              phoneNumber: '',
              gender: '',
              dob: '',
              bio: '',
              email: '',
              password: '',
              accountPIN: 0,
              token: '',
              inviteCode: '',
              isVendor: false,
              isEmailVerified: false,
              connectionRequest: [],
              connections: [],
              myInvites: [],
              blockedConnections: [],
              securityQuestions: [],
              createdAt: null,
              updatedAt: null,
              userSettings: UserSettingsModel.fromMap({}),
              interests: [],
              isProfileComplete: false,
              extraSecurity: false,
              followers: [],
              following: [],
              lastMessage: null,
              status: data['status'],
            )
          ]);
          _successController.add({
            'roomID': roomID,
            'userID': data['userID'],
            'status': data['status'],
          });
          break;
        case 'chat:typing':
          if (data['userID'] == null || data['isTyping'] == null) {
            print('Invalid chat:typing data: missing userID or isTyping');
            _errorController.add(
              'Invalid chat:typing data: missing userID or isTyping',
            );
            return;
          }
          _successController.add({
            'roomID': roomID,
            'userID': data['userID'],
            'isTyping': data['isTyping'],
          });
          break;
        case 'chat:users':
          if (data['users'] != null && data['users'] is List) {
            try {
              final users = (data['users'] as List)
                  .where((user) => user != null && user is Map<String, dynamic>)
                  .map((user) => UserModel.fromMap(user as Map<String, dynamic>))
                  .toList();
              print('Chat users updated: ${users.map((u) => u.userID).toList()}');
              _usersController.add(users);
            } catch (e) {
              print('Error parsing chat users data: $e');
              _errorController.add('Error parsing chat users data: $e');
            }
          } else {
            print('Invalid chat users data');
            _errorController.add('Invalid chat users data');
          }
          break;
        case 'chat:messageRead':
          if (data['messageID'] == null || data['isRead'] == null) {
            print('Invalid chat:messageRead data: missing messageID or isRead');
            _errorController.add(
              'Invalid chat:messageRead data: missing messageID or isRead',
            );
            return;
          }
          _successController.add({
            'roomID': roomID,
            'messageID': data['messageID'],
            'isRead': data['isRead'],
            'readAt': data['readAt'],
          });
          break;
        case 'chat:messageDeleted':
          if (data['messageID'] == null || roomID == null) {
            print('Invalid chat:messageDeleted data: missing messageID or roomID');
            _errorController.add(
              'Invalid chat:messageDeleted data: missing messageID or roomID',
            );
            return;
          }
          _successController.add({
            'roomID': roomID,
            'messageID': data['messageID'],
            'event': 'messageDeleted',
          });
          break;
        case 'fetchUserDetails':
          if (data['user'] != null) {
            try {
              final user = UserModel.fromMap(data['user'] as Map<String, dynamic>);
              print('User details fetched: ${user.userID}');
              _usersController.add([user]);
            } catch (e) {
              print('Error parsing user details: $e');
              _errorController.add('Error parsing user details: $e');
            }
          } else {
            print('Invalid user details data');
            _errorController.add('Invalid user details data');
          }
          break;
      }
    });
  }

  Future<void> _ensureConnected() async {
    if (!_socketConfigProvider.isConnected) {
      print('Attempting to connect socket...');
      final connected = await _socketConfigProvider.connectionStatus
          .firstWhere((status) => status == true, orElse: () => false)
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
      if (!connected) {
        print('Socket connection timed out');
        throw Exception('Socket connection timed out');
      }
      print('Socket connected successfully');
    }
  }

  Future<void> joinChat(String receiverID) async {
    try {
      await _ensureConnected();
      print('Emitting joinChat for receiverID: $receiverID');
      _socketConfigProvider.emit('joinChat', {'receiverID': receiverID});
    } catch (e) {
      print('Socket connection error in joinChat: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  Future<void> fetchChatUsers() async {
    try {
      await _ensureConnected();
      print('Emitting fetchChatUsers');
      _socketConfigProvider.emit('fetchChatUsers', {});
    } catch (e) {
      print('Error fetching chat users: $e');
      _errorController.add('Error fetching chat users: $e');
    }
  }

  Future<void> requestUserStatus(String receiverID) async {
    try {
      await _ensureConnected();
      print('Emitting requestUserStatus for receiverID: $receiverID');
      _socketConfigProvider.emit('requestUserStatus', {'receiverID': receiverID});
    } catch (e) {
      print('Error requesting user status: $e');
      _errorController.add('Error requesting user status: $e');
    }
  }

  Future<void> sendMessage(
      String receiverID,
      String content, {
        required List<String> images,
        required String replyTo
      }) async {
    try {
      await _ensureConnected();
      print('Emitting sendMessage to receiverID: $receiverID, content: $content');
      _socketConfigProvider.emit('sendMessage', {
        'receiverID': receiverID,
        'content': content,
        'images': images,
        'replyTo': replyTo,
      });
    } catch (e) {
      print('Socket connection error in sendMessage: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  Future<void> deleteMessage(String messageID) async {
    try {
      await _ensureConnected();
      print('Emitting deleteMessage for messageID: $messageID');
      _socketConfigProvider.emit('deleteMessage', {
        'messageID': messageID,
      });
    } catch (e) {
      print('Socket connection error in deleteMessage: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  Future<void> addMessageReaction(String messageID, String reaction) async {
    try {
      await _ensureConnected();
      print('Emitting addMessageReaction for messageID: $messageID');
      _socketConfigProvider.emit('addMessageReaction', {
        'messageID': messageID,
        'reaction': reaction,
      });
    } catch (e) {
      print('Socket connection error in addMessageReaction: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  Future<void> removeMessageReaction(String messageID, String reactionID) async {
    try {
      await _ensureConnected();
      print('Emitting removeMessageReaction for messageID: $messageID');
      _socketConfigProvider.emit('removeMessageReaction', {
        'messageID': messageID,
        'reactionID': reactionID,
      });
    } catch (e) {
      print('Socket connection error in removeMessageReaction: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  Future<void> markMessageAsRead(String messageID) async {
    try {
      await _ensureConnected();
      print('Emitting markMessageAsRead for messageID: $messageID');
      _socketConfigProvider.emit('markMessageAsRead', {'messageID': messageID});
    } catch (e) {
      print('Socket connection error in markMessageAsRead: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  Future<void> startTyping(String receiverID) async {
    try {
      await _ensureConnected();
      print('Emitting typing:start for receiverID: $receiverID');
      _socketConfigProvider.emit('typing:start', {'receiverID': receiverID});
    } catch (e) {
      print('Socket connection error in startTyping: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  Future<void> stopTyping(String receiverID) async {
    try {
      await _ensureConnected();
      print('Emitting typing:stop for receiverID: $receiverID');
      _socketConfigProvider.emit('typing:stop', {'receiverID': receiverID});
    } catch (e) {
      print('Socket connection error in stopTyping: $e');
      _errorController.add('Socket connection error: $e');
    }
  }

  void dispose() {
    print('Disposing MessagesSocketServices');
    _messagesController.close();
    _errorController.close();
    _successController.close();
    _usersController.close();
  }
}