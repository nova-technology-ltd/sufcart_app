import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';


class SocketConfigService {
  IO.Socket? _socket;
  final String _serverUrl = AppStrings.serverUrl;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  Future<void> connect() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwtToken = prefs.getString("Authorization");

      _socket = IO.io(
        _serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': jwtToken})
            .build(),
      );

      _socket!.onConnect((_) {
        print('Connected to socket server: ${_socket!.id}');
        _connectionStatusController.add(true);
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from socket server');
        _connectionStatusController.add(false);
      });

      _socket!.onError((error) {
        print('Socket error: $error');
        _connectionStatusController.add(false);
      });

      _socket!.onAny((event, data) {
        print('Received event: $event with data: $data');
        _eventController.add({'event': event, 'data': data});
      });

      _socket!.connect();
    } catch (e) {
      print('Socket connection failed: $e');
      _connectionStatusController.add(false);
    }
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
      print('Emitted event: $event with data: $data');
    } else {
      print('Cannot emit event: Socket is not connected');
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _connectionStatusController.add(false);
      print('Socket disconnected');
    }
  }

  bool isConnected() {
    return _socket != null && _socket!.connected;
  }

  void dispose() {
    disconnect();
    _connectionStatusController.close();
    _eventController.close();
  }
}



