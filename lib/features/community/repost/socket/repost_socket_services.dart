import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../utilities/socket/socket_config_provider.dart';

import 'dart:async';
import 'package:flutter/material.dart';

class RepostSocketServices {
  final SocketConfigProvider _socketConfigProvider;
  final StreamController<Map<String, dynamic>> _repostController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _successController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get repostStream => _repostController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>> get successStream => _successController.stream;

  RepostSocketServices({required SocketConfigProvider socketConfigProvider})
      : _socketConfigProvider = socketConfigProvider {
    _init();
  }

  void _init() {
    _socketConfigProvider.eventStream.listen((eventData) {
      final event = eventData['event'];
      final data = eventData['data'];
      switch (event) {
        case 'repost:initial':
        case 'repost:updated':
          _repostController.add(data);
          break;
        case 'repost:success':
          _successController.add(data);
          break;
        case 'repost:error':
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

  Future<void> joinPost(String postID) async {
    try {
      await _ensureConnected();
      _socketConfigProvider.emit('joinPost', {'postID': postID});
    } catch (e) {
      _errorController.add('Socket is not connected');
    }
  }

  void dispose() {
    _repostController.close();
    _errorController.close();
    _successController.close();
  }
}