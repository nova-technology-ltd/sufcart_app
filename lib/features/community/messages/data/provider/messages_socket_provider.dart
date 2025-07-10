import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sufcart_app/features/profile/model/user_model.dart';
import '../../../../../utilities/socket/socket_config_provider.dart';
import '../sockets/messages_socket_services.dart';
import '../model/messages_model.dart';


class MessagesSocketProvider extends ChangeNotifier {
  final MessagesSocketServices _messageServices;
  final Map<String, List<MessagesModel>> _userMessages = {};
  final List<UserModel> _chatUsers = [];
  String? _errorMessage;
  String? _successMessage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundPlayedForMessage = false;
  final Map<String, Map<String, String>> _userStatuses = {};
  final Map<String, Map<String, bool>> _userTypingStatuses = {};
  StreamSubscription<Map<String, dynamic>>? _messagesSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<Map<String, dynamic>>? _successSubscription;
  StreamSubscription<List<UserModel>>? _usersSubscription;
  final String _currentUserID;

  List<MessagesModel> fetchChatHistory(String roomID) => _userMessages[roomID] ?? [];
  List<UserModel> get chatUsers => _chatUsers;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? getUserStatus(String roomID, String userID) => _userStatuses[roomID]?[userID];
  bool getTypingStatus(String roomID, String userID) => _userTypingStatuses[roomID]?[userID] ?? false;

  MessagesSocketProvider({
    required SocketConfigProvider socketConfigProvider,
    required String currentUserID,
  })  : _messageServices = MessagesSocketServices(socketConfigProvider: socketConfigProvider),
        _currentUserID = currentUserID {
    _init();
    _initializeAudioPlayer();
  }

  void _init() {
    _messagesSubscription = _messageServices.messagesStream.listen((data) {
      final roomID = data['roomID'];
      print('Messages stream update for roomID: $roomID');
      if (data['messages'] != null) {
        _userMessages[roomID] = (data['messages'] as List)
            .map((msg) => MessagesModel.fromMap(msg))
            .toList();
        notifyListeners();
      } else if (data['message'] != null) {
        final message = MessagesModel.fromMap(data['message']);
        final messages = _userMessages[roomID] ?? [];
        if (!messages.any((msg) => msg.messageID == message.messageID)) {
          _userMessages[roomID] = [...messages, message];
          final userIndex = _chatUsers.indexWhere((user) {
            final ids = [user.userID, message.senderID, message.receiverID];
            ids.sort();
            return 'chat:${ids[0]}:${ids[1]}' == roomID;
          });
          if (userIndex != -1) {
            _chatUsers[userIndex] = _chatUsers[userIndex].copyWith(lastMessage: message);
          }
          if (message.senderID != _currentUserID && !_isSoundPlayedForMessage) {
            _playSound();
            _isSoundPlayedForMessage = true;
            Future.delayed(Duration(seconds: 1), () {
              _isSoundPlayedForMessage = false;
            });
          }
          notifyListeners();
        }
      }
    });

    _errorSubscription = _messageServices.errorStream.listen((message) {
      print('Error stream update: $message');
      _errorMessage = message;
      notifyListeners();
    });

    _successSubscription = _messageServices.successStream.listen((data) {
      print('Success stream update: $data');
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
        final previousStatus = _userStatuses[roomID]![data['userID']];
        if (previousStatus != data['status']) {
          print('Updating user status: userID=${data['userID']}, status=${data['status']}, roomID=$roomID');
          _userStatuses[roomID]![data['userID']] = data['status'];
          notifyListeners();
        }
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
      } else if (data['event'] == 'messageDeleted' && data['messageID'] != null) {
        if (_userMessages[roomID] != null) {
          final messages = _userMessages[roomID]!;
          final index = messages.indexWhere((msg) => msg.messageID == data['messageID']);
          if (index != -1) {
            _userMessages[roomID]!.removeAt(index);
            final userIndex = _chatUsers.indexWhere((user) {
              final ids = [user.userID, messages[index].senderID, messages[index].receiverID];
              ids.sort();
              return 'chat:${ids[0]}:${ids[1]}' == roomID;
            });
            if (userIndex != -1 && _chatUsers[userIndex].lastMessage?.messageID == data['messageID']) {
              _chatUsers[userIndex] = _chatUsers[userIndex].copyWith(
                lastMessage: _userMessages[roomID]!.isNotEmpty ? _userMessages[roomID]!.last : null,
              );
            }
            notifyListeners();
          }
        }
      }
    });

    _usersSubscription = _messageServices.usersStream.listen((users) {
      print('Users stream update: ${users.map((u) => u.userID).toList()}');
      for (var user in users) {
        final existingIndex = _chatUsers.indexWhere((u) => u.userID == user.userID);
        if (existingIndex != -1) {
          _chatUsers[existingIndex] = _chatUsers[existingIndex].copyWith(
            status: user.status ?? _chatUsers[existingIndex].status,
            firstName: user.firstName.isNotEmpty ? user.firstName : _chatUsers[existingIndex].firstName,
            lastName: user.lastName.isNotEmpty ? user.lastName : _chatUsers[existingIndex].lastName,
            userName: user.userName.isNotEmpty ? user.userName : _chatUsers[existingIndex].userName,
            image: user.image.isNotEmpty ? user.image : _chatUsers[existingIndex].image,
            lastMessage: user.lastMessage ?? _chatUsers[existingIndex].lastMessage,
          );
        } else {
          _chatUsers.add(user);
        }
        _messageServices.requestUserStatus(user.userID);
      }
      notifyListeners();
    });
  }

  int getTotalUnreadMessages({required String currentUserID}) {
    int totalUnread = 0;
    _userMessages.forEach((roomID, messages) {
      totalUnread += messages
          .where((msg) => !msg.isRead && msg.senderID != currentUserID && msg.receiverID == currentUserID)
          .length;
    });
    return totalUnread;
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setAsset('sounds/new-notification-014-363678.mp3');
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> joinChat(String receiverID) async {
    print('Joining chat with receiverID: $receiverID');
    await _messageServices.joinChat(receiverID);
    await _messageServices.requestUserStatus(receiverID);
  }

  Future<void> fetchChatUsers() {
    print('Loading chat users');
    return _messageServices.fetchChatUsers();
  }

  Future<void> requestUserStatus(String receiverID) {
    print('Requesting user status for receiverID: $receiverID');
    return _messageServices.requestUserStatus(receiverID);
  }

  Future<void> sendMessage({required String receiverID, required String content, required List<String> images, required String senderID, required String replyTo}) async {
    final roomID = _getRoomID(senderID, receiverID);
    _userTypingStatuses.putIfAbsent(roomID, () => {});
    _userTypingStatuses[roomID]![receiverID] = false;
    notifyListeners();
    print('Sending message to receiverID: $receiverID');
    return _messageServices.sendMessage(receiverID, content, images: images, replyTo: replyTo);
  }

  Future<void> addMessageReaction(String messageID, String reaction) {
    print('Adding message reaction for messageID: $messageID');
    notifyListeners();
    return _messageServices.addMessageReaction(messageID, reaction);
  }

  Future<void> deleteMessage(String messageID) async {
    print('Deleting message for messageID: $messageID');
    notifyListeners();
    return _messageServices.deleteMessage(messageID);
  }

  Future<void> removeMessageReaction(String messageID, String reactionID) {
    print('Removing message reaction for messageID: $messageID');
    return _messageServices.removeMessageReaction(messageID, reactionID);
  }

  Future<void> markMessageAsRead(String messageID) {
    print('Marking message as read for messageID: $messageID');
    return _messageServices.markMessageAsRead(messageID);
  }

  Future<void> sendTypingStatus(String receiverID, bool isTyping, {required String senderID}) async {
    final roomID = _getRoomID(senderID, receiverID);
    _userTypingStatuses.putIfAbsent(roomID, () => {});
    print('Sending typing status: isTyping=$isTyping for receiverID: $receiverID');
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

  void handleNewMessage(MessagesModel message, String currentUserID) {
    final roomID = _getRoomID(message.senderID, message.receiverID);
    final messages = _userMessages[roomID] ?? [];
    if (!messages.any((msg) => msg.messageID == message.messageID)) {
      _userMessages[roomID] = [...messages, message];
      final userIndex = _chatUsers.indexWhere((user) {
        final ids = [user.userID, message.senderID, message.receiverID];
        ids.sort();
        return 'chat:${ids[0]}:${ids[1]}' == roomID;
      });
      if (userIndex != -1) {
        _chatUsers[userIndex] = _chatUsers[userIndex].copyWith(lastMessage: message);
      }
      if (message.senderID != currentUserID && !_isSoundPlayedForMessage) {
        _playSound();
        _isSoundPlayedForMessage = true;
        Future.delayed(Duration(seconds: 1), () {
          _isSoundPlayedForMessage = false;
        });
      }
      notifyListeners();
    }
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      debugPrint('Sound played for new message');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    print('Disposing MessagesSocketProvider');
    _messagesSubscription?.cancel();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    _usersSubscription?.cancel();
    _messageServices.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}