import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../utilities/socket/socket_config_provider.dart';
import '../sockets/messages_socket_services.dart';
import '../model/messages_model.dart';
import '../../../profile/model/user_model.dart';

class MessagesSocketProvider extends ChangeNotifier {
  final MessagesSocketServices _messageServices;
  final Map<String, List<MessagesModel>> _userMessages = {};
  final List<UserModel> _chatUsers = [];
  String? _errorMessage;
  String? _successMessage;
  final Map<String, Map<String, String>> _userStatuses = {};
  final Map<String, Map<String, bool>> _userTypingStatuses = {};
  StreamSubscription<Map<String, dynamic>>? _messagesSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<Map<String, dynamic>>? _successSubscription;
  StreamSubscription<List<UserModel>>? _usersSubscription;

  List<MessagesModel> fetchChatHistory(String roomID) => _userMessages[roomID] ?? [];
  List<UserModel> get chatUsers => _chatUsers;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? getUserStatus(String roomID, String userID) => _userStatuses[roomID]?[userID];
  bool getTypingStatus(String roomID, String userID) => _userTypingStatuses[roomID]?[userID] ?? false;

  MessagesSocketProvider({required SocketConfigProvider socketConfigProvider})
      : _messageServices = MessagesSocketServices(socketConfigProvider: socketConfigProvider) {
    _init();
  }

  void _init() {
    _messagesSubscription = _messageServices.messagesStream.listen((data) {
      final roomID = data['roomID'];
      if (data['messages'] != null) {
        _userMessages[roomID] = (data['messages'] as List)
            .map((msg) => MessagesModel.fromMap(msg))
            .toList();
      } else if (data['message'] != null) {
        final message = MessagesModel.fromMap(data['message']);
        final messages = _userMessages[roomID] ?? [];
        if (!messages.any((msg) => msg.messageID == message.messageID)) {
          _userMessages[roomID] = messages + [message];
          // Update lastMessage in chatUsers
          final userIndex = _chatUsers.indexWhere((user) {
            final ids = [user.userID, message.senderID, message.receiverID];
            ids.sort();
            return 'chat:${ids[0]}:${ids[1]}' == roomID;
          });
          if (userIndex != -1) {
            _chatUsers[userIndex] = _chatUsers[userIndex].copyWith(lastMessage: message);
          }
        }
      }
      notifyListeners();
    });

    _errorSubscription = _messageServices.errorStream.listen((message) {
      _errorMessage = message;
      notifyListeners();
    });

    _successSubscription = _messageServices.successStream.listen((data) {
      _successMessage = data['message'];
      final roomID = data['roomID'];
      if (roomID == null || roomID == 'unknown') return;
      if (data['reactions'] != null) {
        final messageID = data['messageID'];
        if (_userMessages[roomID] != null) {
          final messages = _userMessages[roomID]!;
          final index = messages.indexWhere((msg) => msg.messageID == messageID);
          if (index != -1) {
            messages[index] = messages[index].copyWith(reactions: data['reactions']);
            notifyListeners();
          }
        }
      } else if (data['userID'] != null && data['status'] != null) {
        _userStatuses.putIfAbsent(roomID, () => {});
        _userStatuses[roomID]![data['userID']] = data['status'];
        notifyListeners();
      } else if (data['userID'] != null && data['isTyping'] != null) {
        _userTypingStatuses.putIfAbsent(roomID, () => {});
        _userTypingStatuses[roomID]![data['userID']] = data['isTyping'];
        notifyListeners();
      } else if (data['messageID'] != null && data['isRead'] != null) {
        if (_userMessages[roomID] != null) {
          final messages = _userMessages[roomID]!;
          final index = messages.indexWhere((msg) => msg.messageID == data['messageID']);
          if (index != -1) {
            messages[index] = messages[index].copyWith(
              isRead: data['isRead'],
              readAt: data['readAt'] != null ? DateTime.parse(data['readAt']) : null,
            );
            // Update lastMessage in chatUsers if necessary
            final userIndex = _chatUsers.indexWhere((user) {
              final ids = [user.userID, messages[index].senderID, messages[index].receiverID];
              ids.sort();
              return 'chat:${ids[0]}:${ids[1]}' == roomID;
            });
            if (userIndex != -1 && _chatUsers[userIndex].lastMessage?.messageID == data['messageID']) {
              _chatUsers[userIndex] = _chatUsers[userIndex].copyWith(
                lastMessage: messages[index],
              );
            }
            notifyListeners();
          }
        }
      }
    });

    _usersSubscription = _messageServices.usersStream.listen((users) {
      _chatUsers.clear();
      _chatUsers.addAll(users);
      notifyListeners();
    });
  }

  Future<void> joinChat(String receiverID) => _messageServices.joinChat(receiverID);

  Future<void> fetchChatUsers() => _messageServices.fetchChatUsers();

  Future<void> sendMessage(String receiverID, String content, {required List<String> images, required String senderID}) async {
    final roomID = _getRoomID(senderID, receiverID);
    _userTypingStatuses.putIfAbsent(roomID, () => {});
    _userTypingStatuses[roomID]![receiverID] = false;
    notifyListeners();
    return _messageServices.sendMessage(receiverID, content, images: images);
  }

  Future<void> addMessageReaction(String messageID, String reaction) =>
      _messageServices.addMessageReaction(messageID, reaction);

  Future<void> removeMessageReaction(String messageID, String reactionID) =>
      _messageServices.removeMessageReaction(messageID, reactionID);

  Future<void> markMessageAsRead(String messageID) =>
      _messageServices.markMessageAsRead(messageID);

  Future<void> sendTypingStatus(String receiverID, bool isTyping, {required String senderID}) async {
    final roomID = _getRoomID(senderID, receiverID);
    _userTypingStatuses.putIfAbsent(roomID, () => {});
    if (isTyping) {
      await _messageServices.startTyping(receiverID);
    } else {
      await _messageServices.stopTyping(receiverID);
    }
  }

  String _getRoomID(String senderID, String receiverID) {
    final ids = [senderID, receiverID];
    ids.sort();
    return 'chat:${ids.join(':')}';
  }



  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    _usersSubscription?.cancel();
    _messageServices.dispose();
    super.dispose();
  }
}