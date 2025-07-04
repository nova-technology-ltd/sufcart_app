import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/repost/socket/repost_socket_services.dart';
import 'dart:async';
import '../../../../../utilities/socket/socket_config_provider.dart';

class RepostSocketProvider extends ChangeNotifier {
  final RepostSocketServices _repostServices;
  final Map<String, List<dynamic>> _repostContent = {};
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<Map<String, dynamic>>? _repostSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<Map<String, dynamic>>? _successSubscription;

  List<dynamic> getRepost(String postID) => _repostContent[postID] ?? [];
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  RepostSocketProvider({required SocketConfigProvider socketConfigProvider})
      : _repostServices = RepostSocketServices(socketConfigProvider: socketConfigProvider) {
    _init();
  }

  void _init() {
    _repostSubscription = _repostServices.repostStream.listen((data) {
      final postID = data['postID'];
      _repostContent[postID] = data['reposts'] ?? [];
      notifyListeners();
    });

    _errorSubscription = _repostServices.errorStream.listen((message) {
      _errorMessage = message;
      notifyListeners();
    });

    _successSubscription = _repostServices.successStream.listen((data) {
      _successMessage = data['message'];
      notifyListeners();
    });
  }

  Future<void> joinPost(String postID) => _repostServices.joinPost(postID);
  @override
  void dispose() {
    _repostSubscription?.cancel();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    _repostServices.dispose();
    super.dispose();
  }
}

extension RepostSocketProviderExtension on BuildContext {
  RepostSocketProvider get repostSocketProvider => read<RepostSocketProvider>();
}