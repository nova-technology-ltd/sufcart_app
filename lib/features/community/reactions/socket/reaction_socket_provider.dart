import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/reactions/socket/reaction_socket_services.dart';
import 'dart:async';
import '../../../../../utilities/socket/socket_config_provider.dart';

class ReactionSocketProvider extends ChangeNotifier {
  final ReactionSocketServices _reactionServices;
  final Map<String, List<dynamic>> _postReactions = {};
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<Map<String, dynamic>>? _reactionSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<Map<String, dynamic>>? _successSubscription;

  List<dynamic> getReactions(String postID) => _postReactions[postID] ?? [];
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  ReactionSocketProvider({required SocketConfigProvider socketConfigProvider})
      : _reactionServices = ReactionSocketServices(socketConfigProvider: socketConfigProvider) {
    _init();
  }

  void _init() {
    _reactionSubscription = _reactionServices.reactionStream.listen((data) {
      final postID = data['postID'];
      _postReactions[postID] = data['reactions'] ?? [];
      notifyListeners();
    });

    _errorSubscription = _reactionServices.errorStream.listen((message) {
      _errorMessage = message;
      notifyListeners();
    });

    _successSubscription = _reactionServices.successStream.listen((data) {
      _successMessage = data['message'];
      notifyListeners();
    });
  }

  Future<void> joinPost(String postID) => _reactionServices.joinPost(postID);
  Future<void> addReaction(String postID, String reaction) => _reactionServices.addReaction(postID, reaction);
  Future<void> removeReaction(String postID, String likeID) => _reactionServices.removeReaction(postID);

  @override
  void dispose() {
    _reactionSubscription?.cancel();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    _reactionServices.dispose();
    super.dispose();
  }
}

extension ReactionSocketProviderExtension on BuildContext {
  ReactionSocketProvider get reactionSocketProvider => read<ReactionSocketProvider>();
}