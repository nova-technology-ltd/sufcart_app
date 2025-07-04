import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../utilities/socket/socket_config_provider.dart';
import 'follows_socket_service.dart';

class FollowsSocketProvider extends ChangeNotifier {
  final FollowsSocketService _followsServices;
  final Map<String, List<dynamic>> _userFollows = {}; // Stores followers for a user
  final Map<String, List<dynamic>> _userFollowing = {}; // Stores users being followed
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<Map<String, dynamic>>? _followsSubscription;
  StreamSubscription<Map<String, dynamic>>? _followingSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<Map<String, dynamic>>? _successSubscription;

  List<dynamic> getFollows(String userId) => _userFollows[userId] ?? [];
  List<dynamic> getFollowing(String userId) => _userFollowing[userId] ?? [];
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  FollowsSocketProvider({required SocketConfigProvider socketConfigProvider})
      : _followsServices = FollowsSocketService(socketConfigProvider: socketConfigProvider) {
    _init();
  }

  void _init() {
    // Listen to followStream for follower updates (follow:initial, follow:updated)
    _followsSubscription = _followsServices.followStream.listen((data) {
      final userId = data['userId']?.toString();
      if (userId != null) {
        _userFollows[userId] = data['follows'] ?? [];
        notifyListeners();
      }
    });

    // Listen to followingStream for following updates (follow:initialFollowing)
    _followingSubscription = _followsServices.followingStream.listen((data) {
      final userId = data['userId']?.toString();
      if (userId != null) {
        _userFollowing[userId] = data['following'] ?? [];
        notifyListeners();
      }
    });

    // Listen to errorStream for error messages
    _errorSubscription = _followsServices.errorStream.listen((message) {
      _errorMessage = message;
      notifyListeners();
    });

    // Listen to successStream for success messages
    _successSubscription = _followsServices.successStream.listen((data) {
      _successMessage = data['message']?.toString();
      notifyListeners();
    });
  }

  Future<void> joinCommunity(String userId) => _followsServices.joinCommunity(userId);
  Future<void> addFollower(String followerId) => _followsServices.addFollower(followerId);
  Future<void> removeFollower(String followerId) => _followsServices.removeFollower(followerId);

  @override
  void dispose() {
    _followsSubscription?.cancel();
    _followingSubscription?.cancel();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    _followsServices.dispose();
    super.dispose();
  }
}

extension FollowsSocketProviderExtension on BuildContext {
  FollowsSocketProvider get followsSocketProvider => read<FollowsSocketProvider>();
}