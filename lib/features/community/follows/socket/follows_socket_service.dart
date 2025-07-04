import 'dart:async';
import '../../../../../utilities/socket/socket_config_provider.dart';

class FollowsSocketService {
  final SocketConfigProvider _socketConfigProvider;
  final StreamController<Map<String, dynamic>> _followController = StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _successController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _followingController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get followingStream => _followingController.stream;
  Stream<Map<String, dynamic>> get followStream => _followController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>> get successStream => _successController.stream;

  FollowsSocketService({required SocketConfigProvider socketConfigProvider})
      : _socketConfigProvider = socketConfigProvider {
    _init();
  }

  void _init() {
    _socketConfigProvider.eventStream.listen((eventData) {
      final event = eventData['event'];
      final data = eventData['data'];
      switch (event) {
        case 'follow:initial':
        case 'follow:updated':
          _followController.add(data);
          break;
        case 'follow:initialFollowing':
          _followingController.add(data);
          break;
        case 'follow:success':
          _successController.add(data);
          break;
        case 'follow:error':
          _errorController.add(data['message']);
          break;
      }
    });
  }

  Future<void> _ensureConnected() async {
    if (!_socketConfigProvider.isConnected) {
      await _socketConfigProvider.connectionStatus.firstWhere((status) => status == true, orElse: () => false);
      if (!_socketConfigProvider.isConnected) {
        throw Exception('Socket failed to connect');
      }
    }
  }

  Future<void> joinCommunity(String userId) async {
    try {
      await _ensureConnected();
      _socketConfigProvider.emit('joinCommunity', {'userId': userId});
    } catch (e) {
      _errorController.add('Socket is not connected');
    }
  }

  Future<void> addFollower(String followerId) async {
    try {
      await _ensureConnected();
      _socketConfigProvider.emit('addFollower', {
        'followerId': followerId,
      });
    } catch (e) {
      _errorController.add('Socket is not connected');
    }
  }

  Future<void> removeFollower(String followerId) async {
    try {
      await _ensureConnected();
      _socketConfigProvider.emit('removeFollower', {'followerId': followerId});
    } catch (e) {
      _errorController.add('Socket is not connected');
    }
  }

  void dispose() {
    _followController.close();
    _errorController.close();
    _successController.close();
    _followingController.close();
  }
}