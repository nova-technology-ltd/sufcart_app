import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:sufcart_app/utilities/socket/socket_config.dart';

class SocketConfigProvider extends ChangeNotifier {
  final SocketConfigService _socketConfigServices = SocketConfigService();
  bool _isConnected = false;
  StreamSubscription<bool>? _connectionStatusSubscription;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStatus => _socketConfigServices.connectionStatus; // Expose connectionStatus
  Stream<Map<String, dynamic>> get eventStream => _socketConfigServices.eventStream;

  SocketConfigProvider() {
    _init();
  }

  void _init() {
    _connectionStatusSubscription = _socketConfigServices.connectionStatus.listen((status) {
      _isConnected = status;
      notifyListeners();
    });

    _socketConfigServices.connect();
  }

  void emit(String event, dynamic data) {
    _socketConfigServices.emit(event, data);
  }

  void disconnect() {
    _socketConfigServices.disconnect();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionStatusSubscription?.cancel();
    _eventSubscription?.cancel();
    _socketConfigServices.dispose();
    super.dispose();
  }
}

extension SocketConfigProviderExtension on BuildContext {
  SocketConfigProvider get socketProvider => read<SocketConfigProvider>();
}